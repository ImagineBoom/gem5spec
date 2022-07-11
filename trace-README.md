repo:https://git.tsinghua.edu.cn/liuzhiwei/gem5spec/-/tree/trace

### 1. 全部执行

#### 1.1 m1-执行spec2017

##### 执行单个benchmark

- 以999为例, 运行m1的整个流程，生成前2000000条指令的itrace，转换[9999,19999]条指令的qtrace，执行10000条，查看[0,400]条指令的流水线

```bash
./run.sh --m1 --spec2017 999 --all --i_insts=2000000 --q_jump=9999 --q_convert=10000 --r_insts=10000 --r_pipe_begin=0 --r_pipe_end=400
```

| 选项                          | 解释                                                 |
| :---------------------------- | ---------------------------------------------------- |
| --spec2017 999                | 代表选择的benchmark                                  |
| all                           | 代表执行全部流程（itrace\qtrace\run_timer\pipeview） |
| i_insts=2000000               | 转换2000000条指令的itrace                            |
| q_jump=9999                   | 跳过前9999条指令开始转换为qtrace                     |
| q_convert=10000               | 转换10000条指令的qtrace                              |
| r_insts=10000                 | run_timer执行10000条指令                             |
| r_pipe_begin=0 r_pipe_end=400 | 生成从[0,400]条指令区间的流水线文件.pipe .config     |

程序结果保存在.results文件中

##### 执行全部benchmark

- 所有的benchmark执行指令数均为5,000,000（i_insts\r_insts）,流水线区间为[0,400]

```bash
./run.sh --m1 --spec2017 --all_benchmarks --insts=5000000 --r_pipe_begin=0 --r_pipe_end=400
```

- 所有的benchmark按最大指令数执行，超过700,000,000条指令的将按照700,000,000分段执行

```bash
./run.sh --m1 --spec2017 --entire_all_benchmarks
```

#### 1.2 m1-执行自定义程序

- 此处编译后程序为test-p8,使用步骤与1.1中运行benchmark相同，生成前2000000条指令的itrace，转换[9999,19999]条指令的qtrace，执行10000条，查看[0,400]条指令的流水线
- 注意将 --spec2017 999 换成 --myexe test-p8

```bash
./run.sh --m1 --myexe --test-p8 --all --i_insts=2000000 --q_jump=9999 --q_convert=19999 --r_insts=10000 --r_pipe_begin=0 --r_pipe_end=400
```

### 2. 单步执行

- 单步执行-itrace

```bash
./run.sh --m1 --spec2017 999 --itrace --i_insts=2000000
```

- 单步执行-qtrace

```bash
./run.sh --m1 --spec2017 999 --qtrace --q_jump=0 --q_convert=200000
```

- 单步执行-run_timer（设置流水线范围）

```bash
./run.sh --m1 --spec2017 999 --run_timer --r_insts=10000 --r_pipe_begin=0 --r_pipe_end=400
```

- 单步执行-pipe_view（只能查看）

```bash
./run.sh --m1 --spec2017 999 --pipe_view
```

## 
