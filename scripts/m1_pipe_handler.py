import csv
import datetime
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


class Instruction:
    def __init__(self, IopId, MnemonicValue, InstAddrLow32, DataAddrLow32, Pipe):
        self.IopId: int = IopId
        self.MnemonicValue: str = MnemonicValue
        self.InstAddrLow32: str = InstAddrLow32
        self.DataAddrLow32: str = DataAddrLow32
        self.EXE_Cycles: int = -1  # 执行周期数,-1代表当前片段未执行完该指令，无法统计指令执行周期
        self.inst_place: int = 0  # 当前Instruction是第几条
        self.Pipe = Pipe


class Trace(threading.Thread):
    def __init__(self, fname):
        super(Trace, self).__init__(name=fname)
        self.fname: str = fname
        self.instruction: dict[str, list[Instruction]] = {}
        self.lines: list[str] = []  # 流水线图的行
        self.cur_line = ""  # 当前处理的流水线图的行
        self.pattern = re.compile(
            r'^\|(?P<pipe>[\.\w]+)[\+\-\|\s]+(?P<iop_id>\d+)\s*\|\s*(?P<mnemonic_key>[\w\?\-]+)\s*(?P<mnemonic_value>[\w\,\.\(\)\?\+\-]*)\s*\|\s*(?P<inst_addr_low32>\w+)\s*\|\s*(?P<data_addr_low32>\w*)\s*\|$')

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
                # execycle = self.calculate_execycles(pipeline.group('pipe'))
                IopId = pipeline.group('iop_id')
                MnemonicKey = pipeline.group('mnemonic_key')
                MnemonicValue = pipeline.group('mnemonic_value')
                InstAddrLow32 = pipeline.group('inst_addr_low32')
                DataAddrLow32 = pipeline.group('data_addr_low32')
                Pipe = pipeline.group('pipe')
                new_inst = Instruction(IopId=IopId, MnemonicValue=MnemonicValue, InstAddrLow32=InstAddrLow32,
                                       DataAddrLow32=DataAddrLow32, Pipe=Pipe)
                haveSameInst = False
                # print(MnemonicKey)
                # print(IopId,MnemonicValue,InstAddrLow32,DataAddrLow32,Pipe)
                insts = self.instruction.setdefault(MnemonicKey, [])
                for index, inst in enumerate(insts):
                    if inst.MnemonicValue == MnemonicValue and inst.InstAddrLow32 == InstAddrLow32 and inst.DataAddrLow32 == DataAddrLow32:
                        if inst.IopId == IopId:
                            self.instruction[MnemonicKey][index].Pipe += Pipe
                            haveSameInst = True
                            break
                        else:
                            haveSameInst = False
                else:
                    pass

                if not haveSameInst:
                    # print(line)
                    self.instruction.setdefault(MnemonicKey, []).append(new_inst)
                    haveSameInst = False
                # print(line)
            else:
                # print("pipeline is empty")
                pass

    def calculate_execycles(self):
        exe_pattern = re.compile(r'(I*\.*E+\.*)\.*f\.*C')
        for this_key, this_insts in self.instruction.items():
            for index, val in enumerate(this_insts):
                exe = exe_pattern.search(val.Pipe)
                if exe:
                    # print(exe.group(0))
                    self.instruction[this_key][index].EXE_Cycles = exe.group(0).count('E')
                    # print(self.instruction[this_key][index].EXE_Cycles)

    # 精简的流水线图
    def tidy(self):
        new_insts: list[Instruction] = []
        new_inst = None
        for key, insts in self.instruction.items():
            new_insts.clear()
            for index, inst in enumerate(insts):
                for new_inst in new_insts:
                    if inst.EXE_Cycles == new_inst.EXE_Cycles or inst.EXE_Cycles == -1:
                        break
                else:
                    if inst.EXE_Cycles != -1:
                        new_insts.append(inst)
            self.instruction[key].clear()
            self.instruction[key].extend(new_insts)

    # 还原流水线图
    def calculate_place(self, iop_id):
        pass

    # 写入csv
    def wirte(self, file_type="txt"):
        this_fname = self.fname
        if self.fname[-4:] == ".txt":
            this_fname = self.fname[:-4] + "." + file_type
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
            for this_key, this_insts in self.instruction.items():
                # f.write(this_key + '\n')
                for i in this_insts:
                    f.write(format(this_key, "<20") +
                            format(str(i.IopId), "<20") + format(i.MnemonicValue, "<20") +
                            format(str(i.EXE_Cycles), "<20") + format(i.InstAddrLow32, "<20") +
                            format(i.DataAddrLow32, "<20") + i.Pipe +
                            '\n')

    # 多线程
    def run(self) -> str:
        # threadLock.acquire()
        # None
        # threadLock.release()
        self.m1pipe_grep(self.fname)
        self.calculate_execycles()
        self.tidy()
        self.wirte()
        # print(self.fname+" done")
        return self.fname

    def sort_after_merge(self, source_csv_file):
        with open(source_csv_file, "r", encoding='utf-8') as fr:
            csv_reader = csv.reader(fr)
            # headers=next(csv_reader)
            headers = ["MNEMONIC_L0", "MNEMONIC_L1", "MNEMONIC_L2", "STATUS", "VERSION", "CATEGORY", "PDF_SHOW",
                       "PDF_REAL", "DESC"]
            Summary_Inst = namedtuple('Summary_inst', headers)
            with open("../data/p8_insts.csv", 'w+', encoding="utf-8") as fw:
                p8_insts = csv.writer(fw)
                p8_insts.writerow(["MNEMONIC", "EXE_CYCLES", "STATUS", "CATEGORY", "VERSION", "PDF_REAL", "DESC"])
                for r in csv_reader:
                    row_info = Summary_Inst(*r)
                    # print(row_info)
                    exe_cycles = ""
                    this_insts = self.instruction.setdefault(row_info.MNEMONIC_L2, [])
                    if len(this_insts) == 1:
                        exe_cycles += str(this_insts[0].EXE_Cycles)
                    elif len(this_insts) > 1:
                        for inst in self.instruction[row_info.MNEMONIC_L2]:
                            exe_cycles += str(inst.EXE_Cycles) + ";"
                    else:
                        continue
                    p8_insts.writerow(
                        [row_info.MNEMONIC_L2, exe_cycles, row_info.STATUS, row_info.CATEGORY, row_info.VERSION,
                         row_info.PDF_REAL,
                         row_info.DESC])


# def t():
#     a = [1, 2, 3, 4, 5, 6]
#     i = 0
#     for i in a:
#         if i == 6: break
#     else:
#         print("end:" + str(i))

def job_done(this_future: Future):
    sleep(1)
    job_name = this_future.result()
    print("RE-CONSTRUCTED : " + job_name)


start_time = datetime.datetime.now()

# 1. 并行
# pipe_list_temp = runcmd(["find ../runspec_gem5_power/*r/M1_result/*.txt"])
pipe_list_temp = runcmd(["find ../*.txt"])
# pipe_list_temp = ["../5_5000000_999.specrand_ir.txt","../6_5000000_999.specrand_ir.txt"]
pipe_list = list(sorted(set(pipe_list_temp)))
# [print(f) for f in pipe_list]
if "" in pipe_list:
    pipe_list.remove("")
# [print(f) for f in pipe_list]
threads = []

for p in pipe_list:
    t = Trace(fname=p)
    threads.append(t)
# [t.start() for t in threads]
# [t.join() for t in threads]

# 线程异步回调
threads_num = 10
threadpool = ThreadPoolExecutor(max_workers=threads_num)
for t in threads:
    future = threadpool.submit(t.run)
    future.add_done_callback(job_done)
threadpool.shutdown(wait=True)

# 2. 合并(按指令)
merge = Trace(fname="merge")
for t in threads:
    for key, insts in t.instruction.items():
        merge.instruction.setdefault(key, []).extend(insts)
merge.tidy()
merge.wirte()
print("MERGE-ENDED")
merge.sort_after_merge(source_csv_file="../data/scripts_csv_power-isa-implementation.csv")
print("SORT-ENDED")
end_time = datetime.datetime.now()

print("CONSUMED TIME", end_time - start_time)
