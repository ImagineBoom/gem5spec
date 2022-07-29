import datetime
import subprocess
import re


def runcmd(command):
    ret = subprocess.run(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, encoding="utf-8",
                         timeout=1)
    if ret.returncode == 0:
        print(ret.stdout)
    else:
        print(ret)


class Instruction:
    def __init__(self, IopId, MnemonicValue, InstAddrLow32, DataAddrLow32, Pipe):
        self.IopId: int = IopId
        self.MnemonicValue: str = MnemonicValue
        self.InstAddrLow32: str = InstAddrLow32
        self.DataAddrLow32: str = DataAddrLow32
        self.EXE_Cycles: int = -1  # 执行周期数,-1代表当前片段未执行完该指令，无法统计指令执行周期
        self.inst_place: int = 0  # 当前Instruction是第几条
        self.Pipe = Pipe


class Trace:
    def __init__(self):
        self.instruction: dict[str, list[Instruction]] = {}
        self.lines: list[str] = []  # 流水线图的行
        self.cur_line = ""  # 当前处理的流水线图的行
        self.pattern = re.compile(
            r'^\|(?P<pipe>[\.\w]+)[\+\-\|\s]+(?P<iop_id>\d+)\s*\|\s*(?P<mnemonic_key>[\w\?\-]+)\s*(?P<mnemonic_value>[\w\,\.\(\)\?\+\-]*)\s*\|\s*(?P<inst_addr_low32>\w+)\s*\|\s*(?P<data_addr_low32>\w*)\s*\|$')

    def m1pipe_read(self, fname: str) -> list[str]:
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
                print("started")
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
                instruction = Instruction(IopId=IopId, MnemonicValue=MnemonicValue, InstAddrLow32=InstAddrLow32,
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
                    None

                if not haveSameInst:
                    # print(line)
                    self.instruction.setdefault(MnemonicKey, []).append(instruction)
                    haveSameInst = False
                # print(line)
            else:
                # print("pipeline is empty")
                None

    def calculate_execycles(self):
        exe_pattern = re.compile(r'(I*\.*E+\.*)\.*f\.*C')
        for key, insts in self.instruction.items():
            for index, val in enumerate(insts):
                exe = exe_pattern.search(val.Pipe)
                if exe:
                    # print(exe.group(0))
                    self.instruction[key][index].EXE_Cycles = exe.group(0).count('E')
                    # print(self.instruction[key][index].EXE_Cycles)

    def calculate_place(self, iop_id) -> int:
        None

    def test_grep(self):
        with open("pipe.txt", 'w', encoding='utf-8') as f:
            for key, insts in self.instruction.items():
                f.write(key + '\n')
                for i in insts:
                    f.write("            " +
                            format(str(i.IopId), "<20") + format(i.MnemonicValue, "<20") +
                            format(str(i.EXE_Cycles), "<20") + format(i.InstAddrLow32, "<20") +
                            format(i.DataAddrLow32, "<20") + i.Pipe +
                            '\n')


start_time = datetime.datetime.now()
t = Trace()
t.m1pipe_grep(fname="./999.txt")
t.calculate_execycles()
t.test_grep()

print("end")
end_time = datetime.datetime.now()
print("CONSUMED TIME",end_time - start_time)
