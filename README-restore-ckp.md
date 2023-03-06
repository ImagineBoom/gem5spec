## 前提：

gem5spec目录已有checkpoint数据

- 执行Simpoint 和 Checkpoint 部分(参见runspec_gem5_power/TRACE.mk中Simpoin和Checkpoint部分)
- 如果是从别人的目录拷贝过来的ckp，不是自己生成的，restore之前要预先运行`fix_ckp_output_path.sh`处理一下路径问题，替换成当前路径，否则520，511这两个需要写文件权限的部分ckp会出错。
- 运行`fix_ckp_output_path.sh`之前，要修改一下生成ckp的目录，也就是要替换的目标，否则错了就不能替换成功了。

## 以下命令全都在gem5spec目录下执行

- 获得自动补全功能

```bash
source auto_cmpl.sh
```
- gem5 restore checkpoint 的配置项在TRACE.mk中# gem5 ckp 配置部分

- 执行restore ckp, -j指定并行数, 执行完后会自动进行对比，得到与gem5与M1对比的Excel
    - 全部测例

      ```shell
      ./run.sh --gem5 --spec2017 --restore_all -j 10 --build_gem5_j 20
      ```

        - 全部测例，并且为data目录下数据备份目录及对比表格名打上标签(label)，便于区分每次的执行结果

          ```shell
          ./run.sh --gem5 --spec2017 --restore_all -j 10 --label "test"
          ```
        - 全部测例, 带标签，并且指定gem5 se.py后CPU的相关配置(会覆盖TRACE.mk中的GEM5_CKP_PY_OPT)

          ```shell
          ./run.sh --gem5 --spec2017 --restore_all -j 10 --gem5_ckp_py_opt "--cpu-clock=8GHz" --label "test"
          ```
        - 全部测例, 带标签，并且指定gem5 se.py后CPU的相关配置(会覆盖TRACE.mk中的GEM5_CKP_PY_OPT)

          ```shell
          ./run.sh --gem5 --spec2017 --restore_all -j 10 --gem5_ckp_py_opt "--cpu-clock=8GHz" --label "test"
          ```
        - 单个测例

          ```shell
          ./run.sh --gem5 --spec2017 --restore_case 502 -j 4
          ```
          ```shell
          ./run.sh --gem5 --spec2017 --restore_case 502 -j 6 --gem5_ckp_py_opt "--cpu-clock=8GHz" --label "test"
          ```
- 增加并行数

```bash
./run.sh --control --add_job_10
```

- kill所有restore ckp相关进程

```bash
./run.sh --control --kill_restore_all_jobs --gem5
```

- 获取当前已完成的ckp结果，得到与gem5与M1对比的Excel

```bash
./run.sh --gem5 --spec2017 --gen_restore_compare_excel
```

---


### 配置多次并连续运行
使用./runArray.sh, 配置后再运行
```shell
./runArray.sh
```

---

### gem5spec/data目录及文件说明

```bash
|-- 20221219213837-label1  #按日期-标签(label)备份的结果
|   |-- 500.perlbench_r
|   |   |-- 500.perlbench_r_Final_Result_0.691573.csv	#restore 的测例CPI数据汇总，文件名中的数字代表ckp加权CPI之和
|   |   |-- 500.perlbench_r_restore_ckp1.log  #restore 的每个ckp的日志
|   |   |-- 500.perlbench_r_restore_ckp2.log
|   |   |-- 500.perlbench_r_restore_ckp3.log
|   |   |-- 500.perlbench_r_restore_ckp4.log
|   |   |-- 500.perlbench_r_restore_ckp5.log
|   |   |-- 500.perlbench_r_restore_ckp6.log
|   |   `-- 500.perlbench_r_restore_ckp7.log									
|   |-- 502.gcc_r
|   |   |-- 502.gcc_r_Final_Result_1.61804.csv								
|   |   `-- 502.gcc_r_restore_ckp1.log
|   |-- Each_case_ckp_data.csv	#gem5的中间数据(不可删除)，汇总所有测例的所有ckp数据，用于生成对比表格
|   |-- nohup.log	#run.sh的运行过程记录
|   `-- restore_all_consumed_time.log	#每次restore ckp的时间记录
|-- 20221219213837-2-comparison_M1_gem5_SPEC2017_sampling_results.xlsx	#最终结果gem5 ckp metrics 对比表格
`-- M1_gem5_paste.csv	#M1的中间数据(不可删除)，汇总所有测例的所有ckp数据，用于生成对比表格
```

### gem5spec部分文件说明

```bash
.
├── auto_cmpl.sh
├── data
│   ├── gem5
│   ├── M1
│   └── meta
├── fix_ckp_output_path.sh
├── partition_run_spec2017_m1.sh
├── README.md
├── README-restore-ckp.md
├── runArray.sh
├── running
│   ├── run.fifo
│   └── runJobPoolSize_10.log
├── run.sh
├── runspec_gem5_power
│   ├── All_case_CKPS_CPI_Err.log
│   ├── All_case_CKPS_L2_MISS_ACCESS_Err.log
│   ├── consume_time.log
│   ├── Each_case_ckp_data.csv
│   ├── Find_IntervalSize.sh
│   ├── git_diff.log # 记录gem5当前运行的commit信息和本地代码的diff信息
│   ├── Makefile
│   ├── Makefile.inc
│   ├── Set_IntervalSize.sh
│   └── TRACE.mk
├── scripts
│   ├── gem5_data_handler.py
│   ├── gem5_exelatency_handler.py
│   ├── gem5_M1_host_results_compare.py
│   ├── job_control.sh
│   ├── m1_pipe_handler.py
│   ├── params.sh
│   ├── utils.py
│   └── utils.sh

```