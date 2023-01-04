
version="1.0.0"

# =========================================================================================================== #
# gem5_ckp_py_opts是一个数组，数组中的一项代表一次任务中gem5的参数配置。这里的一次任务，表示调用一次./run.sh。
# 默认只需要填充gem5_ckp_py_opts数组即可，然后运行此脚本。
# 没有修改的部分保持默认配置，默认配置见gem5spec/runspec_gem5_power/TRACE.mk 中"# gem5配置部分"
gem5_ckp_py_opts=(
  "--cpu-clock=4GHz"
  "--cpu-type=P8CPU --cpu-clock=8GHz"
)
# =========================================================================================================== #

date1=$(date +"%Y-%m-%d %H:%M:%S")
for ((i=0; i<${#gem5_ckp_py_opts[@]}; i++))
do
    gem5_ckp_py_opt=${gem5_ckp_py_opts[$i]}

    echo "the $[i+1] times begin"
    echo "gem5_ckp_py_opt= '${gem5_ckp_py_opt}'"
    # label的值会影响Excel表格的命名，日期之后插入。可以自定义一个名称来区分当前这一组gem5_ckp_py_opts定义的任务。默认是数组长度。
    ./run.sh --gem5 --spec2017 --restore_all -j 24 --gem5_ckp_py_opt "${gem5_ckp_py_opt}" --label "${#gem5_ckp_py_opts[@]}"
    # ./run.sh --gem5 --spec2017 --restore_case 502 -j 6 --gem5_ckp_py_opt "${gem5_ckp_py_opt}" --label "${#gem5_ckp_py_opts[@]}"
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
