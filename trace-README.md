repo:https://git.tsinghua.edu.cn/liuzhiwei/gem5spec/-/tree/trace

# m1

### 1. 全部执行

#### 1.1 m1-执行spec2017

##### 执行单个benchmark

- 以999为例, 运行m1的整个流程，生成前2000000条指令的itrace，转换[9999,19999]条指令的qtrace，执行10000条，查看qtrace中前400条指令的流水线

```bash
./run.sh --m1 --spec2017 999 --all_steps --i_insts=2000000 --q_jump=9999 --q_convert=10000 --r_insts=10000 --r_pipe_begin=1 --r_pipe_end=400
```

| 选项                              | 解释                                                         |
| :-------------------------------- | ------------------------------------------------------------ |
| --spec2017 999                    | 代表选择的benchmark                                          |
| --all_steps                       | 代表执行全部流程（itrace\qtrace\run_timer\pipeview）         |
| --i_insts=2000000                 | 生成2000000条指令的itrace                                    |
| --q_jump=9999 --q_convert=10000   | 生成[9999,19999]指令区间的qtrace；qtrace区间为[jump,jump+convert] |
| --r_insts=10000                   | 在qtrace区间中执行10000条指令                                |
| --r_pipe_begin=1 --r_pipe_end=400 | 用于查看[10000,10399]指令区间的流水线图；流水线图指令区间为[jump+1,jump+400]，相对于jump |

程序结果保存在.results文件中

**以上为完整参数模式，提供缺省参数模式**

- [缺省模式1]
- 运行m1的整个流程，生成前最大指令数的itrace，qtrace区间为[begin,end]，执行400条（end-begin+1），流水线区间为[begin,end]

```bash
./run.sh --m1 --spec2017 999 --r_pipe_begin=1 --r_pipe_end=400
```

##### 执行全部benchmark

- 所有的benchmark执行指令数均为5,000,000（q_convert\r_insts）,itrace按最大指令数转换，流水线区间为[jump+1,jump+400]

```bash
./run.sh --m1 --spec2017 --all_benchmarks --q_jump=9999 --q_convert=5000000 --r_pipe_begin=1 --r_pipe_end=400
```

- 所有的benchmark按最大指令数执行，超过700,000,000条指令的将按照700,000,000分段执行

```bash
./run.sh --m1 --spec2017 --entire_all_benchmarks
```

#### 1.2 m1-执行自定义程序

- 此处编译后程序为test-p8,使用步骤与1.1中运行benchmark相同，生成前2000000条指令的itrace，转换[9999,19999]条指令的qtrace，执行10000条，查看[1,400]条指令的流水线
- 注意将 --spec2017 999 换成 --myexe test-p8

```bash
./run.sh --m1 --myexe test-p8 --all_steps --i_insts=2000000 --q_jump=9999 --q_convert=19999 --r_insts=10000 --r_pipe_begin=1 --r_pipe_end=400
```

### 2. 单步骤执行

benchmark和自定义程序皆可

- 单步执行-itrace

```bash
./run.sh --m1 --myexe test-p8 --itrace --i_insts=2000000
```

- 单步执行-qtrace

```bash
./run.sh --m1 --myexe test-p8 --qtrace --q_jump=0 --q_convert=200000
```

- 单步执行-run_timer（设置流水线范围）

```bash
./run.sh --m1 --myexe test-p8 --run_timer --r_insts=10000 --r_pipe_begin=1 --r_pipe_end=400
```

- 单步执行-pipe_view（只能查看）

```bash
./run.sh --m1 --myexe test-p8 --pipe_view
```




------
# Simpoint

### 1. 生成BBV文件并使用Simpoint分类

在使用simpoint前，需要进入`runspec_gem5_power`目录下编辑`TRACE.mk`文件，指定`interval_size`、`maxK`、`Warmup`参数的值(第8-10行)。其中`maxK`的大小，默认设定为通过获取interval的个数，并对该值开根后设为`maxK`的值。如果不想使用该方式设定`maxK`，可以将`TRACK.mk`中的48、49注释掉，并将50行的注释取消，在第9行可以指定`maxK`的大小。

进入到某个spec2017测例的目录后，执行如下命令

```shell
make simpoint
```

该命令会自动完成使用Valgrind对程序分割片段生成BBV文件，Simpoint对该文件进行分类生成.simpts和.weights文件。同时脚本中还会对Simpoint结果进行合并排序操作，并将结果保存到.merge文件中，方便阅读Simpoint分类后的结果。

另外，对于一些不知道指令数目的程序，可以使用下面的命令，通过使用Valgrind获取程序的指令数，以便决定interval的大小。

```shell
make inst_count
```

### 2. 读取Simpoint结果使用Gem5生成Checkpoints

得到Simpoint的结果后，可以使用Gem5去生成对应的checkpoints。在同一个测例的目录，执行如下命令

```shell
make checkpoints
```

该命令会使用Gem5读取.simpts和.weights文件，Gem5在完整执行完一遍程序后，会生成对应的checkpoints在m5out目录下。

### 3. 使用Gem5恢复Checkpoints

得到checkpoints后，使用Gem5恢复某一个checkpoint可以使用如下命令

```shell
make restore NUM_CKP=1 CPU_TYPE=O3CPU
```

参数`NUM_CKP`用于指定restore哪一个checkpoint，注意该参数的值从1开始，而m5out目录下的checkpoint是从0开始，因此在指定该参数时需要加偏移量1。

参数`CPU_TYPE`用于指定resotre checkpoint使用哪种类型的CPU模型，默认类型是O3CPU。注意，这里不能使用AtomicSimpleCPU来恢复Checkpoints。

恢复结束后的输出文件会重定向到当前目录下的`output_ckp'n'`目录下，其中`n`与`NUM_CKP`的值相同。
