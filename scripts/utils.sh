func_help(){
  cat <<- EOF
  1.Desc: run some spec2017 benchmarks and custom programs help
  2.Notion: )表示输入的上一级命令, []内表示可选, |表示选择一个, <>内表示必填项
  3.Usage: ./run.sh  [MAIN_OPTS]  [FIR_OPTS]  [SEC_OPTS]

    [MAIN_OPTS]:
      --gem5                                                                            使用gem5模拟器
      --control                                                                         线程控制

    [FIR_OPTS]:
      --gem5)
              --spec2017                                                                使用spec2017全部
      --control)
              --add_job|--add_job_10                                                    增加可运行的线程数
              --reduce_job|--reduce_job_10                                              减少可运行的线程数
              --del_job_pool                                                            删除线程池
              --kill_restore_all_jobs                                                   kill restore_all 的任务

    [SEC_OPTS]:
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
    --gem5
      --gen_restore_compare_excel                                                       ST模式下生成表格
      --restore_case                                                                    ST模式下运行单个SPEC2017测例
      --restore_all                                                                     ST模式下运行SPEC2017 上述24个测例
      --restore_all_2                                                                   SMT2模式下运行SPEC2017 上述24个测例
      --restore_all_4                                                                   SMT4模式下运行SPEC2017 上述24个测例
      --restore_all_8                                                                   SMT8模式下运行SPEC2017 上述24个测例
      --build_gem5_j                                                                    运行gem5前编译指定的线程数，可选
      -j                                                                                restore时并行运行的gem5个数
  5.RUN:
    PATTERN-1: 完整参数模式

    * 运行gem5 restore
    配置runspec_gem5_power/common.mk
      ./run.sh --gem5 --spec2017 --restore_all --build_gem5_j 10 -j 20                  # ST
      ./run.sh --gem5 --spec2017 --restore_case 502 --build_gem5_j 10 -j 20             # ST case 502
      ./run.sh --gem5 --spec2017 --restore_all_2 --build_gem5_j 10 -j 20                # SMT2
      ./run.sh --gem5 --spec2017 --restore_all_4 --build_gem5_j 10 -j 20                # SMT4
      ./run.sh --gem5 --spec2017 --restore_all_8 --build_gem5_j 10 -j 20                # SMT8

    * kill restore_all_*(ctrl+C无效)
      ./run.sh --control --kill_restore_all_jobs --gem5

    PATTERN-2: 缺省参数模式

    * 运行gem5 restore
      ./run.sh --gem5 --spec2017 --restore_all -j 20                                    # ST
      ./run.sh --gem5 --spec2017 --restore_case 502 -j 20                               # ST case 502
      ./run.sh --gem5 --spec2017 --restore_all_2 -j 20                                  # SMT2
      ./run.sh --gem5 --spec2017 --restore_all_4 -j 20                                  # SMT4
      ./run.sh --gem5 --spec2017 --restore_all_8 -j 20                                  # SMT8

  :)END
EOF
    exit 0
}

# 检查当前后台restore运行情况
func_detect_restore_bg(){
  detect_task_regex=${1}
  is_print=${2}
  # seconds,如果设置了timeout，则在超过timeout秒之后的ckp会被kill
  timeout=${3}
  if [[ ${is_print} == true ]];then
    echo "DETECTING background tasks..."
  fi

  while : ; do
    # kill run job
    if [[ ${timeout} =~ ^[0-9]+$ ]];then
      # echo "utils.sh 380"
      ps -o pid,etime,command -u $(whoami)|grep -P "$detect_task_regex" | grep -v grep|awk '{print $1, $2, $5}'| while read pid runtime cmd
      do
          if [[ ${cmd} =~ .*output_ckp.* ]];then
            # echo "pid {$pid} has run {$runtime}, ${cmd}"

            time_field_count=`echo $runtime | awk -F[-:] '{print NF}'`

            day=0
            hour=0
            min=0
            sec=0

            if [[ $time_field_count == 2 ]];then
              min=$(echo $runtime|awk '{print int(substr($0,1,2))}')
              sec=$(echo $runtime|awk '{print int(substr($0,4,2))}')
            elif [[ $time_field_count == 3 ]];then
              hour=$(echo $runtime|awk '{print int(substr($0,1,2))}')
              min=$(echo $runtime|awk '{print int(substr($0,4,2))}')
              sec=$(echo $runtime|awk '{print int(substr($0,7,2))}')
            elif [[ $time_field_count == 4 ]];then
              day=$(echo $runtime|awk '{print int(substr($0,1,2))}')
              hour=$(echo $runtime|awk '{print int(substr($0,4,2))}')
              min=$(echo $runtime|awk '{print int(substr($0,7,2))}')
              sec=$(echo $runtime|awk '{print int(substr($0,10,2))}')
            fi

            # echo "substring {$runtime} get day: {$day} hour: {$hour}  min: {$min} sec: {$sec}"

            c=$(($day * 3600* 24+ $hour*3600 + $min * 60 + $sec))
            #echo "运行时间（秒）: "$c

            if [ "$c" -ge "$timeout" ]
            then
                kill ${pid} >/dev/null 2>&1
                grep ${cmd} ./ckps.log >/dev/null || echo "${cmd} was killed {$runtime}, pid ${pid}" >> ./ckps.log 2>&1
                # wait
            fi
          fi
      done
    fi

    run_names=(`ps -o pid,time,command -u $(whoami) | grep -oP "${1}" | grep -oP "/[\/\w\.]+/output_ckp\d+"|sort -u`)
    run_nums=(`ps -o pid,time,command -u $(whoami) | grep -P "${detect_task_regex}" | grep -v grep| awk '{print \$1}'`)
    if [[ ${#run_nums[@]} -gt 0 ]]; then
      :
      sleep 1s
      for run_name in ${run_names[@]}; do
        if [[ ${run_name} =~ .*output_ckp.* ]]; then
          if [[ ${is_print} == true ]];then
            echo "RUNNING: ${run_name}..."
          fi
        fi
      done
    else
      break
    fi
  done
}

# gem5spec目录下调用
# 统计restore数据, 生成对比表格
func_gen_restore_compare_excel(){
  begin_time="${1}"
  echo "python3  ${begin_time} done @ $(date +"%Y-%m-%d %H:%M:%S.%N"| cut -b 1-23)" >>nohup.log 2>&1
}

# 在24个case的上级目录执行
# target_path必须已经存在
# source_path的子目录及文件将被拷贝到target_path
func_backup_gem5_data(){
  source_path="${1}"
  target_path="${2}"
  find "${source_path}" -not -path "./*r/m5out/*" -not -type l -type f -exec cp --parent {} "${target_path}" \;
}

#gem5spec目录下执行
func_with_restore_case(){
  bm=(
    "500.perlbench_r" "502.gcc_r" "505.mcf_r" "520.omnetpp_r" "523.xalancbmk_r" "525.x264_r" "531.deepsjeng_r" "541.leela_r" "548.exchange2_r" "557.xz_r"
    "503.bwaves_r" "507.cactuBSSN_r" "508.namd_r" "510.parest_r" "511.povray_r" "519.lbm_r" "521.wrf_r" "526.blender_r" "527.cam4_r" "538.imagick_r" "544.nab_r" "549.fotonik3d_r" "554.roms_r" "999.specrand_ir"
  )
  FLOODGATE=${1}
  begin_time=${2}
  WORK_DIR=${3}
  parallel_jobs=${4}
  FILE=${5}
  gem5_py_opt=${6}
  label=${7}
  # seconds
  timeout=${8}
  date1=$(date +"%Y-%m-%d %H:%M:%S")
  echo > ./ckps.log
  if [[ $is_gem5 == true ]]; then
    if [[ ${label} == ""  ]]; then
      mkdir -p ./data/gem5/"${begin_time}"/
    else
      mkdir -p ./data/gem5/"${begin_time}-${label}"/
    fi
    # 运行前 git diff 
    make git_diff -C runspec_gem5_power >/dev/null 2>&1 
    make print_config -C runspec_gem5_power/500.perlbench_r |tee -a ./runspec_gem5_power/git_diff.log
    mkdir -p ./data/gem5/"${begin_time}"/
    # cp -r ./runspec_gem5_power/git_diff.log ./data/gem5/"${begin_time}"/ 2>/dev/null

    if [[ $gem5_py_opt == "" ]];then
      make restore_all -C runspec_gem5_power/${FILE} FLOODGATE=${FLOODGATE} WORK_DIR=${WORK_DIR} >>nohup.log 2>&1
    else
      make restore_all -C runspec_gem5_power/${FILE} FLOODGATE=${FLOODGATE} WORK_DIR=${WORK_DIR} GEM5_PY_OPT="${gem5_py_opt}" >>nohup.log 2>&1
    fi
    # 每运行完一个benchmark做出统计
    # wait
    func_detect_restore_bg "gem5.\w+ .*-d ${WORK_DIR}/${FILE}/output_ckp\d+" false ${timeout}
    # opt="make cpi -C runspec_gem5_power/${FILE} FLOODGATE=${FLOODGATE} WORK_DIR=${WORK_DIR}"
    # ${opt} >/dev/null 2>&1
  elif [[ $is_m1 == true ]]; then
    mkdir -p ./data/M1/"${begin_time}"/"${FILE}"
    opt="make find_interval_size -C runspec_gem5_power/${FILE} BACKUP_PATH=$(cd "$(dirname "${0}")" && pwd )/data/M1/${begin_time}/${FILE}/ FLOODGATE=${FLOODGATE}"
    ${opt} >>nohup.log 2>&1
  fi
  # wait

  # 检测是否被中断，如果被中断则不存在FLOODGATE，程序退出
  if [[ ! -p ${FLOODGATE} ]];then
    exit 1
  fi

  func_detect_restore_bg "gem5.\w+ .*-d ${WORK_DIR}/[\/\w\.]+/output_ckp\d+" false ${timeout}
  echo "func_with_restore_case_${FILE} ${FLOODGATE} ${begin_time} done @ $(date +"%Y-%m-%d %H:%M:%S.%N"| cut -b 1-23)" >>nohup.log 2>&1
  date2=$(date +"%Y-%m-%d %H:%M:%S")
  sys_date1=$(date -d "$date1" +%s)
  sys_date2=$(date -d "$date2" +%s)
  seconds=`expr $sys_date2 - $sys_date1`
  hour=$(( $seconds/3600 ))
  min=$(( ($seconds-${hour}*3600)/60 ))
  sec=$(( $seconds-${hour}*3600-${min}*60 ))
  HMS=`echo ${hour}:${min}:${sec}`
  echo "restore_case ${FILE} finished!"
  echo "restore_case ${FILE} consumed time : ${HMS} at ${date1} "|tee ./runspec_gem5_power/restore_all_consumed_time.log
  # backup
  if [[ $is_gem5 == true ]]; then
    # 备份数据
    if [[ ${label} == ""  ]]; then
      func_gen_restore_compare_excel "${begin_time}"
      func_backup_gem5_data "./runspec_gem5_power" "./data/gem5/${begin_time}"
      cp --parent ./runspec_gem5_power/Makefile ./data/gem5/"${begin_time}"/
      cp --parent ./runspec_gem5_power/params.mk ./data/gem5/"${begin_time}"/
      cp --parent ./runspec_gem5_power/common.mk ./data/gem5/"${begin_time}"/
      cp --parent ./*.log ./data/gem5/"${begin_time}"/
      ( cd data/gem5/"${begin_time}"/runspec_gem5_power/${FILE}/; ln -s ../../../../../runspec_gem5_power/${FILE}/m5out ./ )
    else
      func_gen_restore_compare_excel "${begin_time}-${label}"
      func_backup_gem5_data "./runspec_gem5_power" "./data/gem5/${begin_time}-${label}"
      cp --parent ./runspec_gem5_power/Makefile ./data/gem5/"${begin_time}-${label}"/
      cp --parent ./runspec_gem5_power/params.mk ./data/gem5/"${begin_time}-${label}"/
      cp --parent ./runspec_gem5_power/common.mk ./data/gem5/"${begin_time}-${label}"/
      cp --parent ./*.log ./data/gem5/"${begin_time}-${label}"/
      ( cd data/gem5/"${begin_time}-${label}"/runspec_gem5_power/${FILE}/; ln -s ../../../../../runspec_gem5_power/${FILE}/m5out ./ )
    fi
  fi
  exec 6>&-
  exec 6<&-
  # delete job pool
  rm -rf $(dirname ${FLOODGATE})
}

func_with_restore_all_benchmarks(){
  bm=(
    "500.perlbench_r" "502.gcc_r" "505.mcf_r" "520.omnetpp_r" "523.xalancbmk_r" "525.x264_r" "531.deepsjeng_r" "541.leela_r" "548.exchange2_r" "557.xz_r"
    "503.bwaves_r" "507.cactuBSSN_r" "508.namd_r" "510.parest_r" "511.povray_r" "519.lbm_r" "521.wrf_r" "526.blender_r" "527.cam4_r" "538.imagick_r" "544.nab_r" "549.fotonik3d_r" "554.roms_r" "999.specrand_ir"
  )
  FLOODGATE=${1}
  begin_time=${2}
  WORK_DIR=${3}
  parallel_jobs=${4}
  gem5_py_opt=${5}
  label=${6}
  timeout=${7}
  date1=$(date +"%Y-%m-%d %H:%M:%S")
  echo > ./ckps.log

  # 运行前 git diff 
  make git_diff -C runspec_gem5_power >/dev/null 2>&1 
  make print_config -C runspec_gem5_power/500.perlbench_r |tee -a ./runspec_gem5_power/git_diff.log
  mkdir -p ./data/gem5/"${begin_time}"/
  # cp -r ./runspec_gem5_power/git_diff.log ./data/gem5/"${begin_time}"/ 2>/dev/null

  for FILE in ${bm[@]}
  do
    read -u6
    {
      echo >&6
      if [[ $is_gem5 == true ]]; then
        if [[ ${label} == ""  ]]; then
          mkdir -p ./data/gem5/"${begin_time}"/
        else
          mkdir -p ./data/gem5/"${begin_time}-${label}"/
        fi      
        if [[ $gem5_py_opt == "" ]]; then
          make restore_all -C runspec_gem5_power/${FILE} FLOODGATE=${FLOODGATE} WORK_DIR=${WORK_DIR} >>nohup.log 2>&1
        else
          make restore_all -C runspec_gem5_power/${FILE} FLOODGATE=${FLOODGATE} WORK_DIR=${WORK_DIR} GEM5_PY_OPT="${gem5_py_opt}" >>nohup.log 2>&1
        fi
        # 每运行完一个benchmark做出统计
        # wait
        func_detect_restore_bg "gem5.\w+ .*-d ${WORK_DIR}/${FILE}/output_ckp\d+" false ${timeout}
        # opt="make cpi -C runspec_gem5_power/${FILE} FLOODGATE=${FLOODGATE} WORK_DIR=${WORK_DIR}"
        # ${opt} >/dev/null 2>&1
      fi
    }&
  done
  # wait

  # 检测是否被中断，如果被中断则不存在FLOODGATE，程序退出
  if [[ ! -p ${FLOODGATE} ]]; then
    exit 1
  fi
  func_detect_restore_bg "gem5.\w+ .*-d ${WORK_DIR}/[\/\w\.]+/output_ckp\d+" false ${timeout}
  echo "func_with_restore_all_benchmarks ${FLOODGATE} ${begin_time} done @ $(date +"%Y-%m-%d %H:%M:%S.%N"| cut -b 1-23)" >>nohup.log 2>&1
  date2=$(date +"%Y-%m-%d %H:%M:%S")
  sys_date1=$(date -d "$date1" +%s)
  sys_date2=$(date -d "$date2" +%s)
  seconds=`expr $sys_date2 - $sys_date1`
  hour=$(( $seconds/3600 ))
  min=$(( ($seconds-${hour}*3600)/60 ))
  sec=$(( $seconds-${hour}*3600-${min}*60 ))
  HMS=`echo ${hour}:${min}:${sec}`
  echo "restore_all finished!"
  echo "restore_all consumed time : ${HMS} at ${date1} "|tee ./runspec_gem5_power/restore_all_consumed_time.log
  # backup
  if [[ $is_gem5 == true ]]; then
    # 备份数据
    if [[ ${label} == ""  ]]; then
      func_gen_restore_compare_excel "${begin_time}"
      func_backup_gem5_data "./runspec_gem5_power" "./data/gem5/${begin_time}"
      cp --parent ./runspec_gem5_power/Makefile ./data/gem5/"${begin_time}"/
      cp --parent ./runspec_gem5_power/params.mk ./data/gem5/"${begin_time}"/
      cp --parent ./runspec_gem5_power/common.mk ./data/gem5/"${begin_time}"/
      cp --parent ./*.log ./data/gem5/"${begin_time}"/
      for FILE in ${bm[@]}
      do
        ( cd data/gem5/"${begin_time}"/runspec_gem5_power/${FILE}/; ln -s ../../../../../runspec_gem5_power/${FILE}/m5out ./ )
      done
    else
      func_gen_restore_compare_excel "${begin_time}-${label}"
      func_backup_gem5_data "./runspec_gem5_power" "./data/gem5/${begin_time}-${label}"
      cp --parent ./runspec_gem5_power/Makefile ./data/gem5/"${begin_time}-${label}"/
      cp --parent ./runspec_gem5_power/params.mk ./data/gem5/"${begin_time}-${label}"/
      cp --parent ./runspec_gem5_power/common.mk ./data/gem5/"${begin_time}-${label}"/
      cp --parent ./*.log ./data/gem5/"${begin_time}-${label}"/
      for FILE in ${bm[@]}
      do
        ( cd data/gem5/"${begin_time}-${label}"/runspec_gem5_power/${FILE}/; ln -s ../../../../../runspec_gem5_power/${FILE}/m5out ./ )
      done
    fi
  fi
  exec 6>&-
  exec 6<&-
  # delete job pool
  rm -rf $(dirname ${FLOODGATE})
}

func_with_restore_all_benchmarks_n2(){
  bm=(
    "500.perlbench_r" "502.gcc_r" "505.mcf_r" "520.omnetpp_r" "523.xalancbmk_r" "525.x264_r" "531.deepsjeng_r" "541.leela_r" "548.exchange2_r" "557.xz_r"
    "503.bwaves_r" "507.cactuBSSN_r" "508.namd_r" "510.parest_r" "511.povray_r" "519.lbm_r" "521.wrf_r" "526.blender_r" "527.cam4_r" "538.imagick_r" "544.nab_r" "549.fotonik3d_r" "554.roms_r" "999.specrand_ir"
  )
  FLOODGATE=${1}
  begin_time=${2}
  WORK_DIR=${3}
  parallel_jobs=${4}
  date1=$(date +"%Y-%m-%d %H:%M:%S")

  # 运行前 git diff 
  make git_diff -C runspec_gem5_power >/dev/null 2>&1 
  make print_config -C runspec_gem5_power/500.perlbench_r |tee -a ./runspec_gem5_power/git_diff.log
  mkdir -p ./data/gem5/"${begin_time}"/
  # cp -r ./runspec_gem5_power/git_diff.log ./data/gem5/"${begin_time}"/ 2>/dev/null

  for FILE in ${bm[@]}
  do
    read -u6
    {
      echo >&6
      if [[ $is_gem5 == true ]]; then
        opt="make restore_all_2 -C runspec_gem5_power/${FILE} FLOODGATE=${FLOODGATE} WORK_DIR=${WORK_DIR}"
        ${opt} >>nohup.log 2>&1
        # 每运行完一个benchmark做出统计
        wait
        func_detect_restore_bg "gem5.\w+ .*-d ${WORK_DIR}/${FILE}/output_ckp\d+" false
        # opt="make cpi -C runspec_gem5_power/${FILE} FLOODGATE=${FLOODGATE} WORK_DIR=${WORK_DIR}"
        # ${opt} >/dev/null 2>&1
      fi
    }&
  done
  wait

  # 检测是否被中断，如果被中断则不存在FLOODGATE，程序退出
  if [[ ! -p ${FLOODGATE} ]];then
    exit 1
  fi

  func_detect_restore_bg "gem5.\w+ .*-d ${WORK_DIR}/[\/\w\.]+/output_ckp\d+" true
  echo "func_with_restore_all_benchmarks_n2 ${FLOODGATE} ${begin_time} done @ $(date +"%Y-%m-%d %H:%M:%S.%N"| cut -b 1-23)" >>nohup.log 2>&1
  date2=$(date +"%Y-%m-%d %H:%M:%S")
  sys_date1=$(date -d "$date1" +%s)
  sys_date2=$(date -d "$date2" +%s)
  seconds=`expr $sys_date2 - $sys_date1`
  hour=$(( $seconds/3600 ))
  min=$(( ($seconds-${hour}*3600)/60 ))
  sec=$(( $seconds-${hour}*3600-${min}*60 ))
  HMS=`echo ${hour}:${min}:${sec}`
  echo "restore_all_2 finished!"
  echo "restore_all_2 consumed time : ${HMS} at ${date1} "|tee ./runspec_gem5_power/restore_all_consumed_time.log
  # backup
  if [[ $is_gem5 == true ]]; then
    # 备份数据
    if [[ ${label} == ""  ]]; then
      # func_gen_restore_compare_excel "${begin_time}"
      func_backup_gem5_data "./runspec_gem5_power" "./data/gem5/${begin_time}"
      cp --parent ./runspec_gem5_power/Makefile ./data/gem5/"${begin_time}"/
      cp --parent ./runspec_gem5_power/params.mk ./data/gem5/"${begin_time}"/
      cp --parent ./runspec_gem5_power/common.mk ./data/gem5/"${begin_time}"/
      cp --parent ./*.log ./data/gem5/"${begin_time}"/
      for FILE in ${bm[@]}
      do
        ( cd data/gem5/"${begin_time}"/runspec_gem5_power/${FILE}/; ln -s ../../../../../runspec_gem5_power/${FILE}/m5out ./ )
      done
    else
      # func_gen_restore_compare_excel "${begin_time}-${label}"
      func_backup_gem5_data "./runspec_gem5_power" "./data/gem5/${begin_time}-${label}"
      cp --parent ./runspec_gem5_power/Makefile ./data/gem5/"${begin_time}-${label}"/
      cp --parent ./runspec_gem5_power/params.mk ./data/gem5/"${begin_time}-${label}"/
      cp --parent ./runspec_gem5_power/common.mk ./data/gem5/"${begin_time}-${label}"/
      cp --parent ./*.log ./data/gem5/"${begin_time}-${label}"/
      for FILE in ${bm[@]}
      do
        ( cd data/gem5/"${begin_time}-${label}"/runspec_gem5_power/${FILE}/; ln -s ../../../../../runspec_gem5_power/${FILE}/m5out ./ )
      done
    fi
  fi
  exec 6>&-
  exec 6<&-
  # delete job pool
  rm -rf $(dirname ${FLOODGATE})
}

func_with_restore_all_benchmarks_n4(){
  bm=(
    "500.perlbench_r" "502.gcc_r" "505.mcf_r" "520.omnetpp_r" "523.xalancbmk_r" "525.x264_r" "531.deepsjeng_r" "541.leela_r" "548.exchange2_r" "557.xz_r"
    "503.bwaves_r" "507.cactuBSSN_r" "508.namd_r" "510.parest_r" "511.povray_r" "519.lbm_r" "521.wrf_r" "526.blender_r" "527.cam4_r" "538.imagick_r" "544.nab_r" "549.fotonik3d_r" "554.roms_r" "999.specrand_ir"
  )
  FLOODGATE=${1}
  begin_time=${2}
  WORK_DIR=${3}
  parallel_jobs=${4}
  date1=$(date +"%Y-%m-%d %H:%M:%S")

  # 运行前 git diff 
  make git_diff -C runspec_gem5_power >/dev/null 2>&1 
  make print_config -C runspec_gem5_power/500.perlbench_r |tee -a ./runspec_gem5_power/git_diff.log
  mkdir -p ./data/gem5/"${begin_time}"/
  # cp -r ./runspec_gem5_power/git_diff.log ./data/gem5/"${begin_time}"/ 2>/dev/null

  for FILE in ${bm[@]}
  do
    read -u6
    {
      echo >&6
      if [[ $is_gem5 == true ]]; then
        opt="make restore_all_4 -C runspec_gem5_power/${FILE} FLOODGATE=${FLOODGATE} WORK_DIR=${WORK_DIR}"
        ${opt} >>nohup.log 2>&1
        # 每运行完一个benchmark做出统计
        wait
        func_detect_restore_bg "gem5.\w+ .*-d ${WORK_DIR}/${FILE}/output_ckp\d+" false
        # opt="make cpi -C runspec_gem5_power/${FILE} FLOODGATE=${FLOODGATE} WORK_DIR=${WORK_DIR}"
        # ${opt} >/dev/null 2>&1
      fi
    }&
  done
  wait

  # 检测是否被中断，如果被中断则不存在FLOODGATE，程序退出
  if [[ ! -p ${FLOODGATE} ]];then
    exit 1
  fi

  func_detect_restore_bg "gem5.\w+ .*-d ${WORK_DIR}/[\/\w\.]+/output_ckp\d+" true
  echo "func_with_restore_all_benchmarks_n4 ${FLOODGATE} ${begin_time} done @ $(date +"%Y-%m-%d %H:%M:%S.%N"| cut -b 1-23)" >>nohup.log 2>&1
  date2=$(date +"%Y-%m-%d %H:%M:%S")
  sys_date1=$(date -d "$date1" +%s)
  sys_date2=$(date -d "$date2" +%s)
  seconds=`expr $sys_date2 - $sys_date1`
  hour=$(( $seconds/3600 ))
  min=$(( ($seconds-${hour}*3600)/60 ))
  sec=$(( $seconds-${hour}*3600-${min}*60 ))
  HMS=`echo ${hour}:${min}:${sec}`
  echo "restore_all_4 finished!"
  echo "restore_all_4 consumed time : ${HMS} at ${date1} "|tee ./runspec_gem5_power/restore_all_consumed_time.log
  
  # backup
  if [[ $is_gem5 == true ]]; then
    # 备份数据
    if [[ ${label} == ""  ]]; then
      # func_gen_restore_compare_excel "${begin_time}"
      func_backup_gem5_data "./runspec_gem5_power" "./data/gem5/${begin_time}"
      cp --parent ./runspec_gem5_power/Makefile ./data/gem5/"${begin_time}"/
      cp --parent ./runspec_gem5_power/params.mk ./data/gem5/"${begin_time}"/
      cp --parent ./runspec_gem5_power/common.mk ./data/gem5/"${begin_time}"/
      cp --parent ./*.log ./data/gem5/"${begin_time}"/
      for FILE in ${bm[@]}
      do
        ( cd data/gem5/"${begin_time}"/runspec_gem5_power/${FILE}/; ln -s ../../../../../runspec_gem5_power/${FILE}/m5out ./ )
      done
    else
      # func_gen_restore_compare_excel "${begin_time}-${label}"
      func_backup_gem5_data "./runspec_gem5_power" "./data/gem5/${begin_time}-${label}"
      cp --parent ./runspec_gem5_power/Makefile ./data/gem5/"${begin_time}-${label}"/
      cp --parent ./runspec_gem5_power/params.mk ./data/gem5/"${begin_time}-${label}"/
      cp --parent ./runspec_gem5_power/common.mk ./data/gem5/"${begin_time}-${label}"/
      cp --parent ./*.log ./data/gem5/"${begin_time}-${label}"/
      for FILE in ${bm[@]}
      do
        ( cd data/gem5/"${begin_time}-${label}"/runspec_gem5_power/${FILE}/; ln -s ../../../../../runspec_gem5_power/${FILE}/m5out ./ )
      done
    fi
  fi
  exec 6>&-
  exec 6<&-
  # delete job pool
  rm -rf $(dirname ${FLOODGATE})
}

func_with_restore_all_benchmarks_n8(){
  bm=(
    "500.perlbench_r" "502.gcc_r" "505.mcf_r" "520.omnetpp_r" "523.xalancbmk_r" "525.x264_r" "531.deepsjeng_r" "541.leela_r" "548.exchange2_r" "557.xz_r"
    "503.bwaves_r" "507.cactuBSSN_r" "508.namd_r" "510.parest_r" "511.povray_r" "519.lbm_r" "521.wrf_r" "526.blender_r" "527.cam4_r" "538.imagick_r" "544.nab_r" "549.fotonik3d_r" "554.roms_r" "999.specrand_ir"
  )
  FLOODGATE=${1}
  begin_time=${2}
  WORK_DIR=${3}
  parallel_jobs=${4}
  date1=$(date +"%Y-%m-%d %H:%M:%S")

  # 运行前 git diff
  make git_diff -C runspec_gem5_power >/dev/null 2>&1 
  make print_config -C runspec_gem5_power/500.perlbench_r |tee -a ./runspec_gem5_power/git_diff.log
  mkdir -p ./data/gem5/"${begin_time}"/
  # cp -r ./runspec_gem5_power/git_diff.log ./data/gem5/"${begin_time}"/ 2>/dev/null

  for FILE in ${bm[@]}
  do
    read -u6
    {
      echo >&6
      if [[ $is_gem5 == true ]]; then
        opt="make restore_all_8 -C runspec_gem5_power/${FILE} FLOODGATE=${FLOODGATE} WORK_DIR=${WORK_DIR}"
        ${opt} >>nohup.log 2>&1
        # 每运行完一个benchmark做出统计
        wait
        func_detect_restore_bg "gem5.\w+ .*-d ${WORK_DIR}/${FILE}/output_ckp\d+" false
        # opt="make cpi -C runspec_gem5_power/${FILE} FLOODGATE=${FLOODGATE} WORK_DIR=${WORK_DIR}"
        # ${opt} >/dev/null 2>&1
      fi
    }&
  done
  wait

  # 检测是否被中断，如果被中断则不存在FLOODGATE，程序退出
  if [[ ! -p ${FLOODGATE} ]];then
    exit 1
  fi

  func_detect_restore_bg "gem5.\w+ .*-d ${WORK_DIR}/[\/\w\.]+/output_ckp\d+" true
  echo "func_with_restore_all_benchmarks_n8 ${FLOODGATE} ${begin_time} done @ $(date +"%Y-%m-%d %H:%M:%S.%N"| cut -b 1-23)" >>nohup.log 2>&1
  date2=$(date +"%Y-%m-%d %H:%M:%S")
  sys_date1=$(date -d "$date1" +%s)
  sys_date2=$(date -d "$date2" +%s)
  seconds=`expr $sys_date2 - $sys_date1`
  hour=$(( $seconds/3600 ))
  min=$(( ($seconds-${hour}*3600)/60 ))
  sec=$(( $seconds-${hour}*3600-${min}*60 ))
  HMS=`echo ${hour}:${min}:${sec}`
  echo "restore_all_8 finished!"
  echo "restore_all_8 consumed time : ${HMS} at ${date1} "|tee ./runspec_gem5_power/restore_all_consumed_time.log
  
  # backup
  if [[ $is_gem5 == true ]]; then
    # 备份数据
    if [[ ${label} == ""  ]]; then
      # func_gen_restore_compare_excel "${begin_time}"
      func_backup_gem5_data "./runspec_gem5_power" "./data/gem5/${begin_time}"
      cp --parent ./runspec_gem5_power/Makefile ./data/gem5/"${begin_time}"/
      cp --parent ./runspec_gem5_power/params.mk ./data/gem5/"${begin_time}"/
      cp --parent ./runspec_gem5_power/common.mk ./data/gem5/"${begin_time}"/
      cp --parent ./*.log ./data/gem5/"${begin_time}"/
      for FILE in ${bm[@]}
      do
        ( cd data/gem5/"${begin_time}"/runspec_gem5_power/${FILE}/; ln -s ../../../../../runspec_gem5_power/${FILE}/m5out ./ )
      done
    else
      # func_gen_restore_compare_excel "${begin_time}-${label}"
      func_backup_gem5_data "./runspec_gem5_power" "./data/gem5/${begin_time}-${label}"
      cp --parent ./runspec_gem5_power/Makefile ./data/gem5/"${begin_time}-${label}"/
      cp --parent ./runspec_gem5_power/params.mk ./data/gem5/"${begin_time}-${label}"/
      cp --parent ./runspec_gem5_power/common.mk ./data/gem5/"${begin_time}-${label}"/
      cp --parent ./*.log ./data/gem5/"${begin_time}-${label}"/
      for FILE in ${bm[@]}
      do
        ( cd data/gem5/"${begin_time}-${label}"/runspec_gem5_power/${FILE}/; ln -s ../../../../../runspec_gem5_power/${FILE}/m5out ./ )
      done
    fi
  fi
  
  exec 6>&-
  exec 6<&-
  # delete job pool
  rm -rf $(dirname ${FLOODGATE})
}

func_with_cpi_all_benchmarks(){
  if [[ $is_gem5 == true ]]; then
    opts=(
      "make cpi -C runspec_gem5_power/${bm[502]} "
      "make cpi -C runspec_gem5_power/${bm[999]} "
      "make cpi -C runspec_gem5_power/${bm[538]} "
      "make cpi -C runspec_gem5_power/${bm[523]} "
      "make cpi -C runspec_gem5_power/${bm[557]} "
      "make cpi -C runspec_gem5_power/${bm[526]} "
      "make cpi -C runspec_gem5_power/${bm[525]} "
      "make cpi -C runspec_gem5_power/${bm[511]} "
      "make cpi -C runspec_gem5_power/${bm[500]} "
      "make cpi -C runspec_gem5_power/${bm[519]} "
      "make cpi -C runspec_gem5_power/${bm[544]} "
      "make cpi -C runspec_gem5_power/${bm[503]} "
      "make cpi -C runspec_gem5_power/${bm[520]} "
      "make cpi -C runspec_gem5_power/${bm[554]} "
      "make cpi -C runspec_gem5_power/${bm[507]} "
      "make cpi -C runspec_gem5_power/${bm[541]} "
      "make cpi -C runspec_gem5_power/${bm[505]} "
      "make cpi -C runspec_gem5_power/${bm[510]} "
      "make cpi -C runspec_gem5_power/${bm[531]} "
      "make cpi -C runspec_gem5_power/${bm[521]} "
      "make cpi -C runspec_gem5_power/${bm[549]} "
      "make cpi -C runspec_gem5_power/${bm[508]} "
      "make cpi -C runspec_gem5_power/${bm[548]} "
      "make cpi -C runspec_gem5_power/${bm[527]} "
    )
    for opt in "${opts[@]}" ;do
      read -u6
      {
        ${opt} >>nohup.log 2>&1
        echo >&6
      }&
    done
    wait
    make cpi_all -C runspec_gem5_power
  fi

}

# kill 之后会删除线程池
# 每次kill 8个job，直到全部kill，由于top 命令延迟，所以看起来好像一瞬间全部启动了，其实每次只新启动8个随后立刻被kill
func_kill_restore_all_jobs(){
  FLOODGATE=${2}
  while : ; do
    # check job run
    if [[ ! -p ${FLOODGATE} ]];then
      mkfifo ${FLOODGATE}
      rm -rf runJobPoolSize*.log
      touch "$(dirname ${FLOODGATE})"/runJobPoolSize_0.log
    fi
    exec 6<>${FLOODGATE}
    echo >&6;echo >&6;echo >&6;echo >&6;echo >&6;echo >&6;echo >&6;echo >&6;
    max_jobs=$(find $(dirname ${FLOODGATE})/runJobPoolSize_*.log -exec basename {} \;|grep -oP "\d+")
    ((max_jobs+=8))
    if [[ -p ${FLOODGATE} ]];then
      rename "s/runJobPoolSize_\d+/runJobPoolSize_${max_jobs}/" "$(dirname ${FLOODGATE})"/runJobPoolSize_*.log
    fi
    # kill run job
    run_names=(`ps -o pid,time,command -u $(whoami) | grep -oP "${1}" | grep -oP "/[\/\w\.]+/output_ckp\d+"|sort -u`)
    run_nums=(`ps -o pid,time,command -u $(whoami) | grep -P "${1}" | grep -v grep| awk '{print \$1}'`)
    if [[ ${#run_nums[@]} -gt 0 ]]; then
      for run_name in ${run_names[@]}; do
        if [[ ${run_name} =~ .*output_ckp.* ]]; then
          echo "RUNNING: kill ${run_name}..."
        fi
      done
      echo ${run_nums[@]}|xargs kill
    else
      break
    fi
  done
  # delete job pool
  rm -rf $(dirname ${FLOODGATE})
}