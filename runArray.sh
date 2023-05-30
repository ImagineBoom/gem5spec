
version="1.0.0"

# =========================================================================================================== #
# override_gem5_py_opts是一个数组，数组中的一项代表一次任务中gem5的参数配置。这里的一次任务，表示调用一次./run.sh。
# 默认只需要填充 override_gem5_py_opts数组即可，然后运行此脚本。
# =========================================================================================================== #

# default jobs in parallel
JOB_NUM=30

# In this ARRAY mode, configurations in gem5spec/runspec_gem5_power/common.mk "# gem5配置部分" will not be effective anymore.
# Copy/Edit it here as the baseline configuration.
base_ckp_py_opts="--ruby-clock=4.0GHz --mem-size=16384MB --mem-type=DDR4_2933_16x4 --enable-mem-param-override=True --dram-addr-mapping=RoCoRaBaCh --dram-max-accesses-per-row=16 --dram-page-policy close_adaptive --dram-read-buffer-size=128 --dram-write-buffer-size=64 --mc-be-latency=10ns --mc-fe-latency=35ns --mc-mem-sched-policy=frfcfs"


# This is the param array for param exploration.
# Params listed here will overide the same params in BASE_CKP_PY_OPTS.
# 没有修改的部分保持默认 BASE_CKP_PY_OPTS 配置
# Example configurations:
override_gem5_py_opts=(
  # leave the first element empty for running the baseline configuraion
  ""
  "--dram-page-policy=open --dram-addr-mapping=RoRaBaChCo"
  "--dram-page-policy=open --dram-addr-mapping=RoRaBaCoCh"
  "--dram-page-policy=open_adaptive --dram-addr-mapping=RoRaBaChCo"
  "--dram-page-policy=open_adaptive -dram-addr-mapping=RoRaBaCoCh"
  "--dram-page-policy=close --dram-addr-mapping=RoCoRaBaCh"
  "--dram-page-policy=close_adaptive --dram-addr-mapping=RoCoRaBaCh"

#  "--dram-page-policy=open"
#  "--dram-page-policy=close"
#  "--dram-page-policy=open_adaptive"
#  "--dram-page-policy=close_adaptive"
  "--mc-fe-latency=95ns"
  "--mc-fe-latency=60ns"
  "--mc-fe-latency=35ns"
  "--mc-fe-latency=10ns"
#  "--mc-mem-sched-policy=frfcfs"
#  "--mc-mem-sched-policy=fcfs"
#  "--dram-addr-mapping=RoRaBaChCo"
#  "--dram-addr-mapping=RoRaBaCoCh"
#  "--dram-addr-mapping=RoCoRaBaCh"
#  "--dram-max-accesses-per-row=8"
#  "--dram-max-accesses-per-row=32"
#  "--dram-read-buffer-size=8"
#  "--dram-read-buffer-size=16"
#  "--dram-read-buffer-size=32"
#  "--dram-read-buffer-size=64"
#  "--dram-read-buffer-size=128"
#  "--dram-read-buffer-size=256"
#  "--dram-write-buffer-size=8"
#  "--dram-write-buffer-size=16"
#  "--dram-write-buffer-size=32"
#  "--dram-write-buffer-size=64"
#  "--dram-write-buffer-size=128"
#  "--dram-write-buffer-size=256"
)
# =========================================================================================================== #

date1=$(date +"%Y-%m-%d %H:%M:%S")
for ((i=0; i<${#override_gem5_py_opts[@]}; i++))
do
    override_gem5_py_opt=${override_gem5_py_opts[$i]}

    echo "the $[i+1] times begin"
    echo "gem5_py_opt= '${override_gem5_py_opt}'"
    # label的值会影响Excel表格的命名，日期之后插入。可以自定义一个名称来区分当前这一组 override_gem5_py_opts定义的任务。默认是数组长度。
    ./run.sh --gem5 --spec2017 --restore_all -j ${JOB_NUM} --gem5_py_opt "${base_ckp_py_opts} ${override_gem5_py_opt}" --label "${#override_gem5_py_opts[@]}"
    # ./run.sh --gem5 --spec2017 --restore_case 502 -j 6 --gem5_py_opt "${gem5_py_opt}" --label "${#override_gem5_py_opts[@]}"
    echo "the $[i+1] times end"
    echo
done

date2=$(date +"%Y-%m-%d %H:%M:%S")
sys_date1=$(date -d "$date1" +%s)
sys_date2=$(date -d "$date2" +%s)
seconds=`expr $sys_date2 - $sys_date1`
hour=$(( $seconds/3600 ))
min=$(( ($seconds-${hour}*3600)/60 ))
sec=$(( $seconds-${hour}*3600-${min}*60 ))
HMS=`echo ${hour}:${min}:${sec}`

echo "# ----------------------------------------- All Finished -----------------------------------------"
echo "runArray \"restore_all\"s finished!"
echo "runArray \"restore_all\"s consumed time : ${HMS} at ${date1} "|tee ./runspec_gem5_power/restore_all_consumed_time.log
echo "# ----------------------------------------- All Finished -----------------------------------------"
