import csv
import datetime
import os
import subprocess
import re
import threading
from collections import namedtuple
from concurrent.futures import ProcessPoolExecutor
from concurrent.futures import ThreadPoolExecutor
from concurrent.futures import Future
from os import getpid as pid
from os.path import basename
from time import sleep


def runcmd(command):
    ret = subprocess.run(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, encoding="utf-8",
                         timeout=None)
    if ret.returncode == 0:
        # print("success:", ret)
        return ret.stdout.split('\n')
    else:
        # print("error:", ret)
        return ret.stderr.split('\n')


class ExeCycle:
    def __init__(self, exe_cycle_num=-1, exe_cycle_frequency=0.0, exe_cycle_count=0):
        self.exe_cycle_num = exe_cycle_num  # 执行周期数,-1代表当前片段未执行完该指令，无法统计指令执行周期
        self.exe_cycle_frequency = exe_cycle_frequency  # 对应执行周期数出现的频率
        self.exe_cycle_count = exe_cycle_count  # 对应执行周期数出现的次数


class instruction:
    def __init__(self, IopId, MnemonicValue, InstAddrLow32, DataAddrLow32, Pipe) -> None:
        self.IopId: int = IopId
        self.MnemonicValue: str = MnemonicValue
        self.InstAddrLow32: str = InstAddrLow32
        self.DataAddrLow32: str = DataAddrLow32
        self.exeCycle = ExeCycle()
        self.inst_place: int = 0  # 当前Instruction是第几条
        self.Pipe = Pipe


class Instruction:
    def __init__(self, count=0, frequency=0.0):
        self.list: list[instruction] = []
        self.count = count
        self.frequency = frequency


class Trace:
    def __init__(self, fname, existed_files):
        # super(Trace, self).__init__(name=fname)
        self.fname: str = fname
        self.instruction_dict: dict[str, Instruction] = {}
        self.inst_count = 0  # 所有遍历的指令数
        self.lines: list[str] = []  # 流水线图的行
        self.cur_line = ""  # 当前处理的流水线图的行
        self.pattern = re.compile(
            r'^\|(?P<pipe>.*)[\+\-\|]+\s+(?P<iop_id>\d+)\s*\|\s*(?P<mnemonic_key>[\w\?\-]+)\s*(?P<mnemonic_value>[\w\,\.\(\)\?\+\-]*)\s*\|\s*(?P<inst_addr_low32>\w+)\s*\|\s*(?P<data_addr_low32>\w*)\s*\|$')
        self.existed_files = existed_files

    def m1pipe_read(self, fname: str):
        with open(fname, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        return lines

    def fwrite(self, fname: str):
        with open(fname, 'w', encoding='utf-8') as f:
            f.write('test')

    def m1pipe_grep(self, fname: str):
        self.lines = self.m1pipe_read(fname)
        start = False
        for line in self.lines:
            if "| Scrollpipe Data |" in line:
                start = True
                # print(self.name + "-started")
                # print(line)
            if not start:
                # print("not start")
                continue
            # print("start")
            pipeline = self.pattern.search(line)
            if pipeline:
                # print(pipeline.group(0))
                # place = self.calculate_place(pipeline.group('iop_id'))
                IopId = pipeline.group('iop_id')
                MnemonicKey = pipeline.group('mnemonic_key')
                MnemonicValue = pipeline.group('mnemonic_value')
                InstAddrLow32 = pipeline.group('inst_addr_low32')
                DataAddrLow32 = pipeline.group('data_addr_low32')
                Pipe = pipeline.group('pipe')
                new_inst = instruction(IopId=IopId, MnemonicValue=MnemonicValue, InstAddrLow32=InstAddrLow32,
                                       DataAddrLow32=DataAddrLow32, Pipe=Pipe)
                haveSameInst = False
                # print(MnemonicKey)
                # print(IopId,MnemonicValue,InstAddrLow32,DataAddrLow32,Pipe)
                insts = self.instruction_dict.setdefault(MnemonicKey, Instruction())
                for index, inst in enumerate(insts.list):
                    if inst.MnemonicValue == MnemonicValue and inst.InstAddrLow32 == InstAddrLow32 and inst.DataAddrLow32 == DataAddrLow32:
                        if inst.IopId == IopId:
                            self.instruction_dict[MnemonicKey].list[index].Pipe += Pipe
                            haveSameInst = True
                            break
                        else:
                            haveSameInst = False
                else:
                    pass

                if not haveSameInst:
                    # print(line)
                    self.instruction_dict.setdefault(MnemonicKey, Instruction()).list.append(new_inst)
                    haveSameInst = False
                # print(line)
            else:
                # print("pipeline is empty")
                pass

    def calculate_exe_cycles(self):
        exe_pattern = re.compile(r'.(E+)[^EI]*f\.*C')
        for this_key, this_insts in self.instruction_dict.items():
            for index, val in enumerate(this_insts.list):
                exe = exe_pattern.search(val.Pipe)
                if exe:
                    # print(exe.group(0))
                    self.instruction_dict[this_key].list[index].exeCycle = ExeCycle(exe.group(0).count('E'), 1, 1)

    def calculate_count_inst_before_merge(self):
        for key, insts in self.instruction_dict.items():
            self.instruction_dict.setdefault(key, Instruction()).count = len(insts.list)

    def calculate_frequency_inst(self):
        pass

    # 精简的流水线图,去除每种指令中执行周期数相同的出现，并计算每指令每个执行周期的出现的次数
    def tidy(self):
        new_insts: list[instruction] = []
        new_inst = None
        for key, insts in self.instruction_dict.items():
            new_insts.clear()
            for index, inst in enumerate(insts.list):
                for new_inst_index, new_inst in enumerate(new_insts):
                    if inst.exeCycle.exe_cycle_num == new_inst.exeCycle.exe_cycle_num:
                        new_insts[new_inst_index].exeCycle.exe_cycle_count += 1
                        break
                    elif inst.exeCycle.exe_cycle_num == -1:
                        break
                else:
                    if inst.exeCycle.exe_cycle_num != -1:
                        new_insts.append(inst)
            self.instruction_dict[key].list.clear()
            self.instruction_dict[key].list.extend(new_insts)

    # 还原流水线图
    def calculate_place(self, iop_id):
        pass

    # 写入文本
    def wirte(self, file_type="txt"):
        tup_path = os.path.splitext(self.fname)
        this_fname = self.fname
        if tup_path[1] == ".txt":
            this_fname = tup_path[0] + "." + file_type
        if "." not in this_fname:
            this_fname += "." + file_type
        # this_fname = self.fname.removesuffix(".txt") + "."+file_type
        # print("basename: "+basename(this_fname))
        with open("../data/" + basename(this_fname), 'w', encoding='utf-8') as f:
            f.write(format("MNEMONIC-L", "<20") +
                    format("IOP-ID", "<20") + format("MNEMONIC-R", "<20") +
                    format("EXE-CYCLES", "<20") + format("INST-ADDR-LOW-32", "<20") +
                    format("DATA-ADDR-LOW-32", "<20") + "PIPE-JOBS" +
                    '\n')
            for this_key, this_insts in self.instruction_dict.items():
                # f.write(this_key + '\n')
                for i in this_insts.list:
                    f.write(format(this_key, "<20") +
                            format(str(i.IopId), "<20") + format(i.MnemonicValue, "<20") +
                            format(str(i.exeCycle.exe_cycle_num), "<20") + format(i.InstAddrLow32, "<20") +
                            format(i.DataAddrLow32, "<20") + i.Pipe +
                            '\n')

    # 多线程
    def run(self):
        tup_path = os.path.splitext(basename(self.fname))
        for f in self.existed_files:
            if tup_path[0] in f:
                # print("EXISTED: " + self.fname)
                return {"name": self.fname, "state": "EXISTED"}
        self.m1pipe_grep(self.fname)
        self.calculate_exe_cycles()
        self.calculate_count_inst_before_merge()
        self.wirte()
        self.tidy()
        # sleep(10)
        # print(self.instruction_dict.setdefault("addi", Instruction()).list[0].MnemonicValue)
        print(self.fname + " done")
        return {"name": self.fname, "state": "RE-CONSTRUCTED", "thread": self}

    # exe_cycle编码
    def marshal(self, exe_cycle_list):
        s = ""
        for e in exe_cycle_list:
            s += str(e.exe_cycle_num) + "(" + str(e.exe_cycle_frequency) + "," + str(e.exe_cycle_count) + ")"
        return s

    # exe_cycle解码
    def unmarshal(self, exe_cycles):
        exe_cycle_list = []
        exe_cycles_iter = re.finditer(
            r'(?P<exe_cycle_num>\d+)\((?P<exe_cycle_frequency>0\.\d+),(?P<exe_cycle_count>\d+)\)', exe_cycles
        )
        for exe_cycle in exe_cycles_iter:
            e = ExeCycle(
                exe_cycle.group("exe_cycle_num"),
                exe_cycle.group("exe_cycle_frequency"),
                exe_cycle.group("exe_cycle_count")
            )
            exe_cycle_list.append(e)
        return exe_cycle_list

    # 根据exe_cycles_old 如 2(0.3,10),3(0.7,5) ,计算出添加exe_cycle_new_num后的周期数和频率
    def merge_exe_cycle(self, exe_cycle_list_old, exe_cycle_list_new):
        merge = []
        for e_old in exe_cycle_list_old:
            for e_new in exe_cycle_list_new:
                pass

    def calculate_exe_cycle_frequency(self):
        new_insts: list[Instruction] = []
        new_inst = None
        exe_cycle_count_sum = 0
        for key, insts in self.instruction_dict.items():
            exe_cycle_count_sum = 0
            for index, inst in enumerate(insts.list):
                exe_cycle_count_sum += inst.exeCycle.exe_cycle_count
            for index, inst in enumerate(insts.list):
                self.instruction_dict[key].list[
                    index].exeCycle.exe_cycle_frequency = inst.exeCycle.exe_cycle_count / exe_cycle_count_sum

    def sort(self, source_csv_file):
        p8_insts_headers = ["MNEMONIC", " FREQUENCY", "EXE_CYCLES", "STATUS", "CATEGORY", "VERSION", "PDF_REAL", "DESC"]
        exe_cycle_set = set()
        exe_cycle = ""
        # if os.path.isfile("../data/p8_insts.csv"):
        #     p8_insts_class = namedtuple('p8_insts_class', p8_insts_headers)
        #     with open("../data/p8_insts.csv", "r", encoding='utf-8') as fr:
        #         with open("../data/_p8_insts.csv", "w+", encoding='utf-8') as fw:
        #             csv_reader = csv.reader(fr)
        #             _p8_insts_csv = csv.writer(fw)
        #             for r in csv_reader:
        #                 row_info = p8_insts_class(*r)
        #                 new_insts = self.instruction.setdefault(row_info.MNEMONIC, [])
        #                 if len(new_insts) == 1:
        #                     row_info.EXE_CYCLES += str(new_insts[0].exeCycle.exe_cycle_num)
        #                 elif len(new_insts) > 1:
        #                     for inst in self.instruction[row_info.MNEMONIC]:
        #                         row_info.EXE_CYCLES += str(inst.EXE_Cycles) + ";"
        #                 else:
        #                     pass
        #                 # _p8_insts_csv.writerow(
        #                 #     [row_info.MNEMONIC, row_info.EXE_CYCLES, row_info.STATUS, row_info.CATEGORY,
        #                 #      row_info.VERSION, row_info.PDF_REAL, row_info.DESC])
        # else:
        with open(source_csv_file, "r", encoding='utf-8') as fr:
            csv_reader = csv.reader(fr)
            # headers=next(csv_reader)
            headers = ["MNEMONIC_L0", "MNEMONIC_L1", "MNEMONIC_L2", "STATUS", "VERSION", "CATEGORY", "PDF_SHOW",
                       "PDF_REAL", "DESC"]
            p8_insts_class = namedtuple('p8_insts_class', headers)
            with open("../data/p8_insts.csv", 'w+', encoding="utf-8") as fw:
                p8_insts_csv = csv.writer(fw)
                p8_insts_csv.writerow(p8_insts_headers)
                for r in csv_reader:
                    row_info = p8_insts_class(*r)
                    # print(row_info)
                    exe_cycles = ""
                    new_insts = self.instruction_dict.setdefault(row_info.MNEMONIC_L2, Instruction())
                    if len(new_insts.list) == 1:
                        exe_cycles = str(new_insts.list[0].exeCycle.exe_cycle_num) + "(" + \
                                     str(new_insts.list[0].exeCycle.exe_cycle_frequency) + "," + \
                                     str(new_insts.list[0].exeCycle.exe_cycle_count) + "/" + str(
                            new_insts.list[0].exeCycle.exe_cycle_count) + ")"
                    elif len(new_insts.list) > 1:
                        # print(new_insts)
                        exe_cycles_list = [[]]
                        exe_cycles_list.clear()
                        for inst in self.instruction_dict[row_info.MNEMONIC_L2].list:
                            exe_cycles_list.append(
                                [
                                    inst.exeCycle.exe_cycle_num,
                                    inst.exeCycle.exe_cycle_frequency,
                                    inst.exeCycle.exe_cycle_count,
                                    int(inst.exeCycle.exe_cycle_count / inst.exeCycle.exe_cycle_frequency)
                                ]
                            )
                        exe_cycles_list.sort(key=lambda x: (-x[1], -x[2]))
                        for e in exe_cycles_list:
                            # print(e)
                            exe_cycles += (
                                    str(e[0]) + "(" +
                                    format(e[1], ".3f") + "," +
                                    str(e[2]) + "/" + str(e[3]) +
                                    ")" + ";"
                            )
                    else:
                        # continue
                        exe_cycles = ""
                    p8_insts_csv.writerow(
                        [
                            row_info.MNEMONIC_L2,
                            "(" + format(new_insts.frequency, ".3f") + "," + str(new_insts.count) + "/" + str(
                                self.inst_count) + ")",
                            exe_cycles, row_info.STATUS, row_info.CATEGORY,
                            row_info.VERSION, row_info.PDF_REAL, row_info.DESC
                        ]
                    )

    @staticmethod
    def get_existed():
        existed_files = []
        for root, dirs, files in os.walk("../data", topdown=False):
            for name in files:
                existed_files.append(os.path.join(root, name))
        return existed_files


# def t():
#     a = [1, 2, 3, 4, 5, 6]
#     i = 0
#     for i in a:
#         if i == 6: break
#     else:
#         print("end:" + str(i))

new_threads = []
threadLock = threading.Lock()


def job_done(this_future: Future):
    # sleep(5)
    job = this_future.result()
    threadLock.acquire()
    new_threads.append(job["thread"])
    threadLock.release()
    print(job["state"] + " : " + job["name"])


def pd():
    pass


if __name__ == '__main__':
    threads = []
    start_time = datetime.datetime.now()
    # 0. 检查
    existed_files = Trace.get_existed()
    # 1. 并行
    pipe_list_temp = runcmd(["find ../runspec_gem5_power/*r/ -name '*.txt'"])
    # pipe_list_temp = runcmd(["find ../*.txt"])
    # pipe_list_temp = ["../114_5000000_554.roms_r.txt"]
    pipe_list = list(sorted(set(pipe_list_temp)))
    # [print(f) for f in pipe_list]
    if "" in pipe_list:
        pipe_list.remove("")
    # [print(f) for f in pipe_list]

    for p in pipe_list:
        t = Trace(fname=p, existed_files=existed_files)
        threads.append(t)

    # 线程异步回调
    threads_num = 10
    process_pool = ProcessPoolExecutor(max_workers=threads_num)
    todo = []
    for index, t in enumerate(threads):
        future = process_pool.submit(threads[index].run)
        todo.append(future)
        future.add_done_callback(job_done)
    process_pool.shutdown(wait=True)
    for t in new_threads:
        pass

# 2. 合并(按指令)
    merge = Trace(fname="merge", existed_files=existed_files)
    for t in new_threads:
        inst_count = 0
        for key, insts in t.instruction_dict.items():
            merge.inst_count += insts.count
            merge.instruction_dict.setdefault(key, Instruction()).count += insts.count
            merge.instruction_dict.setdefault(key, Instruction()).list.extend(insts.list)
            # print(key)
    # 计算指令频率
    for key, insts in merge.instruction_dict.items():
        merge.instruction_dict.setdefault(key, Instruction()).frequency = \
            merge.instruction_dict.setdefault(key, Instruction()).count / merge.inst_count

    merge.tidy()
    print("TIDY-ENDED")
    merge.wirte()
    print("MERGE-ENDED")
    merge.calculate_exe_cycle_frequency()
    merge.sort(source_csv_file="../data/scripts_csv_power-isa-implementation.csv")
    print("SORT-ENDED")
    end_time = datetime.datetime.now()

    print("CONSUMED TIME", end_time - start_time)
