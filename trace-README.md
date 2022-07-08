# Run benchmark

------

## Environment

**Arch**: ppc64le

**OS:** Ubuntu 20.04

## Run m1

### 1. Run SPEC2017

------

#### 1.1 分步执行

- **step1** 生成itrace

```bash
make itrace NUM_INSNS_TO_COLLECT=20m 
```

`NUM_INSNS_TO_COLLECT`-代表要采集的总指令数，不带单位或者k|m|g

- **step2** 将itrace转换为qtrace

```bash
make qtrace JUMP_NUM=0 CONVERT_NUM_Vgi_RECS=0
```

`JUMP_NUM`-生成qtrace时跳过的指令数,当指定为0时默认转换整个itrace

`CONVERT_NUM_Vgi_RECS`-生成qtrace的指令数

- **step3** run otimer

```bash
make m1 NUM_INST=20000 CPI_INTERVAL=20000 SCROLL_BEGIN=1 SCROLL_END=200
```

`NUM_INST`-m1执行的指令数(最大约700,000,000)

`CPI_INTERVAL`-据此大小划分NUM_INST，显示每段的CPI

`SCROLL_BEGIN`-指定起始位置（第XXX条指令）查看流水线

`SCROLL_END`-指定结束位置（第XXX条指令）查看流水线

- **step4** 查看流水线

```bash
make m1_pipeview
```

#### 1.2 一步到位

```bash
make trace \
NUM_INSNS_TO_COLLECT=20m \
JUMP_NUM=0 CONVERT_NUM_Vgi_RECS=0 \
NUM_INST=20000 CPI_INTERVAL=20000 SCROLL_BEGIN=1 SCROLL_END=200 
```

### 2. Run custom programs

------

```bash
./p8-m1.sh EXEPATH SCROLL_BEGIN SCROLL_END SIG
```

**example**：`./p8-m1.sh /home/lizongping/power8-m1test/test_power8_pipeline/test_power8_pipeline_loop_only_v1 1 500`

`EXEPATH`-程序的路径

`SCROLL_BEGIN`-指定起始位置（第XXX条指令）查看流水线

`SCROLL_END`-指定结束位置（第XXX条指令）查看流水线

`SIG`-表示执行哪几步

| SIG  | 对应步骤             | 说明                                   |
| ---- | -------------------- | -------------------------------------- |
| 0    | 全部执行             |                                        |
| 1    | 生成itrace           | 全部转换                               |
| 2    | 将itrace转换为qtrace | 全部转换                               |
| 3    | run otimer           |                                        |
| 4    | 查看流水线           | 由`SCROLL_BEGIN`和`SCROLL_END`指定范围 |

全部执行-输出文件保存在 basename EXEPATH

单步执行-输出文件保存在当前目录

## Run Simpoint

