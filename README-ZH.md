
---

[English](./README.md) | 简体中文

---

## 项目配置

所有的配置项都在`runspec_gem5_power/params.mk`文件中指定

✅ 确保已经成功[编译SPEC2017](https://github.com/griffin-warrior/gem5spec)
- 配置`SPEC_HOME`，确保`SPEC_HOME`所在路径符合`$(SPEC_HOME)/benchspec/CPU/541.leela_r`的类似规则
- 根据编译平台设置`LABEL`,`LABEL`的值需在编译SPEC时设置为可执行文件的后缀

✅ 确保gem5已经build成功，确认执行的选项和参数
- `GEM5_REPO_PATH`配置为gem5仓库的根路径
- `GEM5`配置为gem5编译结果所在的路径
- `BUILD_GEM5_J`若通过此脚本编译gem5，需要指定并行编译数
- `GEM5_OPT`gem5.opt的直接参数
- `GEM5_PY`se.py所在路径
- `GEM5_PY_OPT`se.py的选项和参数

✅ 确保已经成功安装Simpoint·`version: 3.2`
- `SIMPOINT_EXE`simpoint可执行文件的路径
- INTERVAL_SIZE
- WARMUP_LENGTH
- `NUM_CKP`: 使用make restore只运行一个checkpoint时，指定的checkpoint编号

- [ ] 可选：Valgrind，统计指令数

- `VALGRIND_EXE`valgrind可执行文件的路径

## Simpoint

### 1. 生成BBV文件并使用Simpoint分类

其中`maxK`的大小，默认为interval的个数开根后的值。

在单个spec2017测例的目录下执行如下命令

```shell
make simpoint
```

此命令会使用gem5的`NonCachingSimpleCPU`模型对程序分割片段，生成Basic Block Vector(BBV)文件。然后使用Simpoint对该文件进行分类生成`.simpts`和`.weights`文件。为了方便解析，脚本随后会对这两个文件进行合并排序(按指令顺序由小到大)操作，并将结果保存到`.merge`文件中。

如果想一次对24个测例同时生成BBV文件，在`runspec_gem5_power`目录下执行如下命令

```bash
make simpoints_all_cases -j24
```

> - 对于一些不知道指令数目的程序，可以修改下面的命令，通过使用Valgrind获取程序的指令数，以便决定interval的大小
>
>   ```sh
>   $VALGRIND_EXE --tool=exp-bbv --instr-count-only=yes --bb-out-file=/dev/null $EXECUTABLE $ARGS
>   ```
>
> - 如果想查看每个测例有多少个片段，可以在`runspec_gem5_power`目录下执行如下命令，结果保存在Checkpoint_Num.csv中
>
>   ```sh
>   make collect_checkpoints_number
>   ```

- *_gem5_bbv.log：gem5生成bbv的运行日志
- *_simpoint.log：simpoint的运行日志
- *_trace.log：记录target开始和结束的时间

## Checkpoint

### 2. 读取Simpoint结果使用gem5生成Checkpoints

得到Simpoint的结果后，可以使用gem5去生成对应的Checkpoints。在同一个测例的目录，执行如下命令

```shell
make checkpoints
```

此命令会使用gem5读取`.simpts`和`.weights`文件，并使用gem5的`AtomicSimpleCPU`模型完整执行完一遍程序后，生成对应的Checkpoints在`m5out`目录下

如果想一次对24个测例同时生成Checkpoints文件，在`runspec_gem5_power`目录下执行如下命令

```shell
make checkpoints_all_cases -j24
```

如果使用多核模式生成24个测例的Checkpoints文件，在`runspec_gem5_power`目录下执行如下命令

```bash
make checkpoints_all_cases_X -j24
```

其中X可以指定为2、4、8，分别代表双核、四核、八核

- *_checkpoints.log: gem5生成checkpoints的运行日志

## Restore

### 3. 使用gem5恢复Checkpoints

#### 3.1 恢复某一个Checkpoint

得到Checkpoints后，使用gem5恢复某一个Checkpoint，可以在测例的目录下使用如下命令

```bash
make restore NUM_CKP=1
```

参数`NUM_CKP`用于指定`restore`Checkpoint的序号，注意该参数的值从1开始，而`m5out`目录下的Checkpoint是从0开始，因此在指定该参数时需要加偏移量1

默认CPU类型`P8CPU`。*注意，这里不能使用`AtomicSimpleCPU`来恢复`Checkpoints`*

gem5的输出文件会重定向到当前目录下的`output_ckp'n'`目录下，其中`n`与`NUM_CKP`的值相同

- *_restore_ckp'n'.log: gem5 restore第n 个checkpoint 的运行日志

#### 3.2 恢复某个测例全部的Checkpoints

在`gem5spec`目录下输入以下命令可以对某个测例的所有Checkpoint进行`restore`操作

```bash
source auto_cmpl.sh 
./run.sh --gem5 --spec2017 --restore_case XXX -j N
```

> - XXX表示需要被restore的测例号，例：500
>
> - 这里的N指定的是最大并行数，可根据机器硬件情况和当前任务量决定
>
> - `source auto_cmpl.sh`命令用于自动补全提示，后续用到`run.sh`的地方都可以使用自动补全来加速命令输入
>
> - 使用run.sh的方式进行restore的操作，数据将被备份在`${GEM5_REPO_PATH}/data/gem5/${restore_begin_time}`的目录下

可以使用`make restore_status`查看当前测例是否执行完毕所有的checkpoints

- *_RS_NUM.log: 保存已运行完的checkpoint Number。每运行完一个checkpoint就会将对应的Num追加到此文件中，通过对比此文件和.merge的行数判断是否全部执行完。（注：不支持下述X=2,4,8的方式）
- `runspec_gem5_power`/git_diff.log: 每次使用run.sh执行restore操作时，保存git diff信息
- *_CKPS_CPI.log: 总共4列，分别是checkpoint num, simpts, weights, cpi。（注：不支持下述X=2,4,8的方式）

> 使用run.sh时可以动态调节同时并行的数量
>
> - 增加并行数
>
>   ```sh
>   ./run.sh --control --add_job_10
>   ```
>
> - 减少并行数。（⚠️竞争式减少，目前没有优先级划分，只有当有的checkpoint结束时，会竞争执行权，竞争成功后即释放，以此达到减少并行数的目的。不会杀死已经执行或等待执行的任务）
>
>   ```sh
>   ./run.sh --control --reduce_job_10
>   ```
>
> - kill所有restore ckp相关进程(执行或等待执行的任务)
>
>   ```sh
>   ./run.sh --control --kill_restore_all_jobs --gem5
>   ```

#### 3.3 恢复所有测例全部的Checkpoints

在`gem5spec`目录下输入以下命令可以对全部测例的每个Checkpoint进行`restore`操作

```bash
./run.sh --gem5 --spec2017 --restore_all -j N
```

> 这里的N指定的是线程池最大的线程数量，可根据机器硬件情况和当前任务量决定

如果想要用多核模式restore checkpoints可以使用下面的命令(Checkpoints也需要对应的多核模式生成)

```bash
./run.sh --gem5 --spec2017 --restore_all_X -j N
```

执行此命令后，任务会放入后台执行，根据指定的线程数量循环restore所有测例的全部checkpoints

其中X可以指定为2、4、8，分别代表双核、四核、八核

- 如果需要在运行前自动编译gem5，可以使用`--build_gem5_j` N 的方式

- 如果需要从命令行修改gem5的参数，可是使用例如`--gem5_py_opt "--cpu-clock=8GHz"`的方式（注：不支持X=2,4,8的方式）

- 如果需要将data目录下的备份目录添加一些区别的标识，可以使用例如`--label "test"`的方式，此方式会将备份目录修改为`${GEM5_REPO_PATH}/data/gem5/${restore_begin_time}-${label}`（注：不支持X=2,4,8的方式）

#### 3.4 配置多次可连续运行

使用`./runArray.sh`, 配置后再运行

#### 3.5 支持slurm方式运行

使用`./runSlurm`，配置后再运行

> #SBATCH --job-name=JOBNAME      %指定作业名称   
> #SBATCH --partition=debug       %指定分区   
> #SBATCH --nodes=2               %指定节点数量   
> #SBATCH --cpus-per-task=1       %指定每个进程使用核数，不指定默认为1   
> #SBATCH -n 32                   %指定总进程数；不使用cpus-per-task，可理解为进程数即为核数   
> #SBATCH --ntasks-per-node=16    %指定每个节点进程数/核数,使用-n参数（优先级更高），变为每个节点最多运行的任务数   
> #SBATCH --nodelist=node[3,4]    %指定优先使用节点   
> #SBATCH --exclude=node[1,5-6]   %指定避免使用节点   

## 统计信息

### 4. CPI统计

由于在步骤3.2中生成的`xxx_CKPS_CPI.log`中只有每个Checkpoint的CPI，没有与权重相乘，使用以下命令可以进行计算

```bash
make cpi
```

此命令会对`xxx_CKPS_CPI.log`中每一个Checkpoint的权重与CPI进行乘法运算，并将结果插入到第四列中，保存到`xxx_CKPS_Weighted_CPI.log`中。

除此以外，此命令还会对每个带有权重的CPI的进行求和，得到该测例综合的CPI结果，并生成一个新的csv文件保存上述结果，文件名为`xxx_final_result_N.csv`(xxx为当前测例的名字；N为权重CPI的总和)

如果需要一次让所有的测例生成`xxx_final_result_N.csv`数据记录，可以在`runspec_gem5_power`目录下使用以下命令

```bash
make cpi_all_cases
```

为方便后期根据CPI数据选择片段，可以在`runspec_gem5_power`目录下使用如下命令

```bash
make collect_all_cases_CPI -j24
```

此命令会遍历每个测例的综合权重CPI数据，并将统计结果保存到`All_case_weightedCPI.csv`中

使用如下命令会遍历每个测例的`xxx_final_result_N.csv`文件，并将数据整合到文件`Each_case_ckp_data.csv`

```bash
make collect_checkpoints_number
```

因此`Each_case_ckp_data.csv`会记录所有测例的全部checkpoints的CPI数据信息

### 5. IPC统计

#### 5.1 单核模式

由于IPC统计时不能直接将IPC结果与Checkpoint的权重一起计算，需要先生成带权重的CPI数据，因此在`runspec_gem5_power`目录下先执行如下命令生成每个测例带权重的CPI数据

```bash
make cpi_all_cases -j24
```

然后使用下面的命令来获取每个测例的IPC数据，统计结果会保存到`All_case_IPC_st.csv`文件中

```bash
make collect_all_cases_IPC
```

#### 5.2 多核模式

与单核模式过程相同，需要先汇总多核模式下带权重的CPI数据，可以使用如下面命令（其中X可以指定为2、4、8，分别代表双核、四核、八核）

```bash
make cpi_all_cases_X -j24
```

然后使用如下命令统计多核模式下的IPC数据，统计结果会保存到`All_case_IPC_smtX.csv`文件中

```bash
make collect_all_cases_IPC_X
```

> 目前IPC数据统计只支持全部测例的数据汇总，不支持单个测例的IPC统计

### 6. L2 Cache MissRate & MPKI统计

统计每个测例中L2 Cache的Miss#、Weighted Miss#、Access#、Weighted Access#可以使用如下命令

```bash
make mpki_l2_all_cases -j 24
```

然后在使用如下命令来统计每个测例的L2 Cache Miss Rate和MPKI，统计结果会保存到`All_case_L2_MPKI_st.csv`文件中

```bash
make collect_all_cases_MPKI_L2
```

如果需要统计多核模式下的IPC数据使用如下命令（其中X可以指定为2、4、8，分别代表双核、四核、八核），统计结果会保存到`All_case_L2_MPKI_smtX.csv`文件中

```bash
make collect_all_cases_MPKI_L2_X
```

### 7.输出文件/目录说明

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
10. xxx_CKPS_CPI_Err.log: 记录在执行make cpi, cpi_2, cpi_4, cpi_8 时发现的异常ckp信息
11. xxx_CKPS_L2_MISS_ACCESS_Err.log: 记录在执行make mkpi 时发现的异常ckp信息
