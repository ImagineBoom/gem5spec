repo:https://git.tsinghua.edu.cn/liuzhiwei/gem5spec/-/tree/trace

# m1

### 1. 全部执行

**脚本自动补全**

```bash
source auto_cmpl.sh
./run.sh [tab][tab]
```

==example==

```bash
./run.sh --m1 --spec2017 999 -b=1 -e=400 --not_gen_txt
./run.sh --m1 --myexe ./test -b=1 -e=400 --not_gen_txt
```

#### 1.1 m1-执行spec2017

##### 执行单个benchmark

- 以999为例, 运行m1的整个流程，生成前2000000条指令的itrace，转换[9999,19999]条指令的qtrace，执行10000条，查看qtrace中前400条指令的流水线

```bash
./run.sh --m1 --spec2017 999 --all_steps --i_insts=2000000 --q_jump=9999 --q_convert=10000 --r_insts=10000 --r_pipe_begin=1 --r_pipe_end=400
```

| 选项                                | 解释                                                            |
|:----------------------------------|---------------------------------------------------------------|
| --spec2017 999                    | 代表选择的benchmark                                                |
| --all_steps                       | 代表执行全部流程（itrace\qtrace\run_timer\pipeview）                    |
| --i_insts=2000000                 | 生成2000000条指令的itrace                                           |
| --q_jump=9999 --q_convert=10000   | 生成[9999,19999]指令区间的qtrace；qtrace区间为[jump,jump+convert]        |
| --r_insts=10000                   | 在qtrace区间中执行10000条指令                                          |
| --r_pipe_begin=1 --r_pipe_end=400 | 用于查看[10000,10399]指令区间的流水线图；流水线图指令区间为[jump+1,jump+400]，相对于jump |
| --gen_txt          | 生成流水线的文本文件                                    |
| --not_gen_txt           | 不生成流水线的文本文件                                        |

程序结果保存在.results文件中

**以上为完整参数模式，提供缺省参数模式**

- [缺省模式1]
- 运行m1的整个流程，执行并查看流水线区间[begin,end]，区间不超过5000条, 不生成流水线的文本文件

```bash
./run.sh --m1 --spec2017 999 --r_pipe_begin=1 --r_pipe_end=400 --not_gen_txt
```

#### 1.2 m1-执行自定义程序

**完整参数模式**

- 此处编译后程序为test-p8,使用步骤与1.1中运行benchmark相同
- 注意将 --spec2017 999 换成 --myexe test-p8

```bash
./run.sh --m1 --myexe ./test-p8 --all_steps --i_insts=2000000 --q_jump=9999 --q_convert=19999 --r_insts=10000 --r_pipe_begin=1 --r_pipe_end=400 --not_gen_txt
```

- 运行m1的整个流程，test-p8按最大指令数执行，超过700,000,000条指令的将按照700,000,000分段执行

```bash
./run.sh --m1 --myexe ./test-p8 --entire
```

**缺省参数模式**

- [缺省模式1]
- 运行m1的整个流程，执行并查看流水线区间[begin,end],区间不超过5000条

```bash
./run.sh --m1 --myexe ./test-p8 --r_pipe_begin=1 --r_pipe_end=400 --not_gen_txt
```

### 2. 单步骤执行

benchmark和自定义程序皆可

- 单步执行-itrace

```bash
./run.sh --m1 --myexe ./test-p8 --itrace --i_insts=2000000
```

- 单步执行-qtrace

```bash
./run.sh --m1 --myexe ./test-p8 --qtrace --q_jump=0 --q_convert=200000
```

- 单步执行-run_timer（设置流水线范围）

```bash
./run.sh --m1 --myexe ./test-p8 --run_timer --r_insts=10000 --r_pipe_begin=1 --r_pipe_end=400
```

- 单步执行-pipe_view（只能查看）

```bash
./run.sh --m1 --myexe ./test-p8 --pipe_view --not_gen_txt
```

### 3. NOTION

```
1.Desc: run some spec2017 benchmarks and custom programs help
  2.Notion: )表示输入的上一级命令, []内表示可选, |表示选择一个, <>内表示必填项
  3.Usage: ./run.sh  [MAIN_OPTS]  [FIR_OPTS]  [SEC_OPTS]

    [MAIN_OPTS]:
              --m1,                                                                     使用power8模拟器
              --gem5                                                                    使用gem5模拟器
              --control                                                                 线程控制

    [FIR_OPTS]:
      --m1)
              --myexe <exepath>                                                         使用自定义的程序(编译后的)
              --spec2017                                                                使用spec2017某一个或者全部
      --gem5)
              --spec2017                                                                使用spec2017全部
      --control)
              --add_thread|--add_thread_10                                              增加可运行的线程数
              --reduce_thread|--reduce_thread_10                                        减少可运行的线程数
              --del_thread_pool                                                         删除线程池
              --kill_restore_all                                                        kill restore_all 的任务

    [SEC_OPTS]:
      --myexe)
              -a --i_insts=<num> -j=<num> -c=<num> --r_insts=<num> -b=<num> -e=<num>
              -i --i_insts=<num>                                                        生成i_insts条指令的itrace
              -q -j=<num> -c=<num>                                                      生成[j,j+c]指令区间的qtrace
              -r --r_insts=<num> -b=<num> -e=<num>                                      在qtrace区间中执行r_insts条指令,流水线图指令区间为[j+b,j+e-b+1]
              -p                                                                        查看流水线图
              -b=<num> -e=<num>                                                         缺省参数模式

      --spec2017)
              <benchmark num>                                                           [502|999|538|523|557|526|525|511|500|519|544|503|520|554|507|541|505|510|531|521|549|508|548|527]
              --restore_all                                                             run all benchmark checkpoints segments
              -a --i_insts=<num> -j=<num> -c=<num> --r_insts=<num> -b=<num> -e=<num>
              -i --i_insts=<num>                                                        生成i_insts条指令的itrace
              -q -j=<num> -c=<num>                                                      生成[j,j+c]指令区间的qtrace
              -r --r_insts=<num> -b=<num> -e=<num>                                      在qtrace区间中执行r_insts条指令,流水线图指令区间为[j+b,j+e-b+1]
              -p                                                                        查看流水线图
              -b=<num> -e=<num>                                                         缺省参数模式

  4.OPTS解释:
    --m1
      --all             | --all_steps             | -a                                  执行使用m1的所有步骤
      --itrace                                    | -i                                  只生成itrace
      --qtrace                                    | -q                                  只转换qtrace
      --run_timer                                 | -r                                  只执行run_timer
      --pipe_view                                 | -p                                  只查看流水线
      --i_insts         | --NUM_INSNS_TO_COLLECT                                        生成itrace指定的指令数
      --q_jump          | --JUMP_NUM              | -j                                  生成qtrace跳过的指令数
      --q_convert       | --CONVERT_NUM_Vgi_RECS  | -c                                  生成qtrace转换的指令数
      --r_insts         | --NUM_INST                                                    run_timer执行的指令数
      --r_cpi_interval  | --CPI_INTERVAL                                                可打印CPI的INTERVAL大小
      --r_reset_stats   | --RESET_STATS
      --r_pipe_type     | --SCROLL_PIPE                                                 流水线类型 1为architected inst, 2为internal instruction, 3为cycle count
      --r_pipe_begin    | --SCROLL_BEGIN          | -b                                  流水线图指令区间起始位置
      --r_pipe_end      | --SCROLL_END            | -e                                  流水线图指令区间结束位置

  5.RUN:
    PATTERN-1: 完整参数模式

    *  运行m1的整个流程,生成前2000000条指令的itrace,转换[9999,19999]条指令的qtrace,执行10000条,查看qtrace中前400条指令的流水线
       ./run.sh --m1 --spec2017 999 -a --i_insts=2000000 -j=9999 -c=10000 --r_insts=10000 -b=1 -e=400
       ./run.sh --m1 --myexe ./test -a --i_insts=2000000 -j=9999 -c=10000 --r_insts=10000 -b=1 -e=400

    *  所有的benchmark执行指令数均为5,000,000(q_convert\r_insts),itrace按最大指令数转换,流水线区间为[jump+1,jump+400]
       ./run.sh --m1 --spec2017 --all_benchmarks --q_jump=9999 --q_convert=5000000 --r_pipe_begin=1 --r_pipe_end=400

    PATTERN-2: 缺省参数模式【推荐】

    *  运行m1的整个流程,生成前最大指令数的itrace,qtrace区间为[begin,end],执行400条(end-begin+1),流水线区间为[begin,end]
       ./run.sh --m1 --spec2017 999 -b=1 -e=400
       ./run.sh --m1 --myexe ./test -b=1 -e=400

  :)END

```

### 4. 输出文件/目录说明

gem5spec_v0_M1/runspec_gem5_power/*r/

1. pipe_result/目录下存放采集后处理为每条指令只输出一行的流水线文本图, 命名规则: 起始指令_结束指令_Simpts_intervalSize_benchmarkName.txt
2. M1_result/目录下存放M1的输出文件, 包括后缀为.result/.config/.qt/.pipe 的文件, 命名规则: Simpts_intervalSize_benchmarkName.后缀名
3. CPI_result/5000000_Calculate_WeightedCPI.log文件存放所有采样点的有效trace运行后对应的CPI结果，总共4列，分别表示：Simpts,Weights,CPI(Ckp M1),WeightedCPI(Ckp M1)

------

# Simpoint

### 1. 生成BBV文件并使用Simpoint分类

在使用Simpoint前，需要进入`runspec_gem5_power`目录下编辑`TRACE.mk`文件，指定`interval_size`、`maxK`、`Warmup`参数的值(第8-10行)。其中`maxK`的大小，默认设定为通过获取interval的个数，并对该值开根后设为`maxK`的值。如果不想使用该方式设定`maxK`，可以将`TRACK.mk`中的48、49注释掉，并将50行的注释取消，在第9行可以指定`maxK`的大小。

进入到某个spec2017测例的目录后，执行如下命令

```shell
make simpoint
```

该命令会自动完成使用Gem5的`NonCachingSimpleCPU`模型对程序分割片段生成Basic Block Vector(BBV)文件，Simpoint对该文件进行分类生成`.simpts`和`.weights`文件。同时脚本中还会对Simpoint结果进行合并排序操作，并将结果保存到`.merge`文件中，方便阅读Simpoint分类后的结果。

如果想一次对24个测例同时生成BBV文件，在`runspec_gem5_power`目录下执行如下命令

```bash
make simpoints_all_cases -j24
```

另外，对于一些不知道指令数目的程序，可以使用下面的命令，通过使用Valgrind获取程序的指令数，以便决定interval的大小，结果会保存到当前目录下的`xxx_inst_count.log`中。另外在`runspec_gem5_power`目录下的`inst_count.log`会记录各个测例指令数目的数据情况。

```shell
make inst_count
```

如果想查看每个测例有多少个片段，可以在`runspec_gem5_power`目录下执行如下命令

```shell
make collect_checkpoints_number
```

结果保存在`runspec_gem5_power`目录下的`Each_case_ckp_data.csv`文件中

### 2. 读取Simpoint结果使用Gem5生成Checkpoints

得到Simpoint的结果后，可以使用Gem5去生成对应的Checkpoints。在同一个测例的目录，执行如下命令

```shell
make checkpoints
```

该命令会使用Gem5读取`.simpts`和`.weights`文件，并使用Gem5的`AtomicSimpleCPU`模型完整执行完一遍程序后，生成对应的Checkpoints在`m5out`目录下。

如果想一次对24个测例同时生成Checkpoints文件，在`runspec_gem5_power`目录下执行如下命令

```shell
make checkpoints_all_cases -j24
```

如果使用4核模式生成24个测例的Checkpoints文件，在`runspec_gem5_power`目录下执行如下命令

```bash
make checkpoints_all_cases_4 -j24
```

### 3.使用Gem5恢复Checkpoints

#### 3.1恢复某一个Checkpoint

得到Checkpoints后，使用Gem5恢复某一个Checkpoint可以使用如下命令

```bash
make restore NUM_CKP=1 CPU_TYPE=O3CPU
```

参数`NUM_CKP`用于指定`restore`Checkpoint的序号，注意该参数的值从1开始，而`m5out`目录下的Checkpoint是从0开始，因此在指定该参数时需要加偏移量1。

参数`CPU_TYPE`用于指定`resotre` Checkpoint使用哪种类型的CPU模型。如果不指定，则会使用默认CPU类型`P8CPU`。*注意，这里不能使用`AtomicSimpleCPU`来恢复`Checkpoints`。*

恢复结束后的输出文件会重定向到当前目录下的`output_ckp'n'`目录下，其中`n`与`NUM_CKP`的值相同。

#### 3.2恢复某个测例全部的Checkpoints

进入`runspec_gem5_power`目录下某个测例的文件后，输入以下命令

```bash
make restore_case CPU_TYPE=XXXCPU
```

该命令会并行执行该测例中的所有Checkpoints，每恢复完成一个Checkpoint，会在`xxx_RS_NUM.log`中记录`Finshed_Restore_CKP_N`的信息（N代表Checkpoint的序号）。同时该命令也会完成各个Checkpoint的CPI统计功能，统计结果会保存在`xxx_CKPS_CPI.log`中。

由于该命令会将每个Checkpoint的`restore`操作压入后台运行，为方便查看所有的Checkpoints完成情况，可以使用命令

```bash
make restore_status
```

如果当前测例的所有Checkpoint都已完成`restore`，则Termianl会输出`All Checkpoints Restore Have Finshed!`

如果还有部分Checkpoint没有完成`restore`，则Termianl会输出`Some Checkpoints Are Restoring!`

#### 3.3恢复所有测例全部的Checkpoints

在`gem5spec`目录下输入以下命令可以对所有测例的所有Checkpoints进行`restore`操作

```bash
source auto_cmpl.sh #激活自动补全
./run.sh --gem5 --spec2017 --restore_all -j N
```

> 这里的N指定的是线程池最大的线程数量，可根据机器硬件情况和当前任务量决定

如果想要用4核模式restore checkpoints可以使用下面的命令(checkpoints需要是4核模式生成的)

```bash
./run.sh --gem5 --spec2017 --restore_all_4 -j N
```

执行该命令后，任务会放入后台执行，根据指定的线程数量循环restore所有测例的全部checkpoints。所有的checkpoints完成restore后，会自动生成存放统计数据表格的路径。

### 4.CPI统计

由于在步骤3.2中生成的`xxx_CKPS_CPI.log`中只有每个Checkpoint的CPI，没有与权重相乘，使用以下命令可以进行计算

```bash
make cpi
```

该命令会对`xxx_CKPS_CPI.log`中每一个Checkpoint的权重与CPI进行乘法运算，并将结果插入到第四列中，保存到`xxx_CKPS_Weighted_CPI.log`中。除此以外，该命令还会对每个带有权重的CPI的进行求和，得到该测例综合的CPI结果，并生成一个新的csv文件保存上述结果，文件名为`xxx_final_result_N.csv`(xxx为当前测例的名字；N为权重CPI的总和)。

如果需要一次让所有的测例生成`xxx_final_result_N.csv`数据记录，可以在`runspec_gem5_power`目录下使用以下命令

```bash
make cpi_all_cases
```

为方便后期根据CPI数据选择片段，可以在`runspec_gem5_power`目录下使用以下命令

```bash
make collect_all_checkpoints_data
```

该命令会遍历每个测例的综合权重CPI数据，并将统计结果保存到`All_case_weightedCPI.csv`中

```bash
make collect_checkpoints_number
```

该命令会遍历每个测例的`xxx_final_result_N.csv`文件，并将数据整合到文件`Each_case_ckp_data.csv`。因此该文件会记录所有测例的全部checkpoints的CPI数据信息

### 5.输出文件/目录说明

上述不同功能都会在当前测例目录下产生相应的输出文件/目录，以便查看和记录每个步骤的输出结果。

1. xxx_gem5_bbv.log: 使用gem5生成basic block vector(BBV)过程的输出信息
2. xxx_simpoints.log:使用Simpoint对BBV分类过程的输出信息
3. xxx_checkpoints.log: 使用gem5生成checkpoints过程的输出信息
4. xxx_restore.log: 使用gem5恢复checkpoint过程的输出信息
5. xxx_trace.log: 记录执行过的命令以及部分命令的输出信息
6. xxx_trace_error.log: 记录发生错误的命令
7. xxx_bbv: 保存通过gem5生成的BBV文件，以及生成过程的仿真数据(stats.txt)
8. m5out: 保存生成的checkpoints的与生成checkpoints过程的仿真数据(stats.txt)
9. out_ckpN: 保存恢复某个checkpoint过程的仿真数据(stats.txt)与模拟器的配置信息(config)，N表示第N个checkpoint
