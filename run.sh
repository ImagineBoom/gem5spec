
version="1.0.0"

#解析命令行选项<optstring>及参数<parameters>
#echo ${@}
getopt_cmd=$(getopt \
-o aiqrphvVc:b:e:j: \
--long m1,gem5,spec2017,myexe:,\
all,all_steps,entire,itrace,qtrace,run_timer,pipe_view,gen_txt,not_gen_txt,\
all_benchmarks,entire_all_benchmarks,max_insts,slice_len:,gem5_py_opt:,timeout:,build_gem5_j:,\
i_insts:,q_jump:,q_convert:,r_insts:,r_cpi_interval:,r_pipe_type:,r_pipe_begin:,r_pipe_end:,\
restore_case:,restore_all,restore_all_2,restore_all_4,restore_all_8,cpi_all,kill_restore_all_jobs,gen_restore_compare_excel,label:,\
control,add_job,reduce_job,del_job_pool,add_job_10,reduce_job_10,get_job_pool_size,\
version,verbose,help \
-n "$(basename "$0")" -- "$@"
)

[ $? -ne 0 ] && exit 1
eval set -- "${getopt_cmd}"
#echo ${getopt_cmd}
source ./scripts/params.sh
source ./scripts/utils.sh
source ./scripts/job_control.sh

FLOODGATE=$(cd "$(dirname "${0}")" && pwd )/running/run.fifo

func_set_job_pool "${FLOODGATE}"

#rm -rf nohup.log 2>/dev/null

#echo ${@}

case "${1#*=}" in
  -v|-h|--help|--verbose)
    func_help
    exit 0
    ;;
  -V|--version)
    echo "version=1.0.0"
    exit 0
    ;;
  *)
    :
    ;;
esac

# MAIN_OPTS 解析
case "${1#*=}" in
  --m1)
    is_m1=true
    shift
    ;;
  --gem5)
    is_gem5=true
    shift
    ;;
  --control)
    is_control=true
    WORK_DIR=$(cd "$(dirname "${0}")" && pwd )/runspec_gem5_power
    shift
    ;;
  --)
    shift
    ;;
  *)
    exit 1
    ;;
esac

# FIR_OPTS 解析
case "${1#*=}" in
  --myexe)
    is_myexe=true
    WORK_DIR=$(cd "$(dirname "${0}")" && pwd )
    EXE="${2#*=}"
    #OUTPUT="${WORK_DIR}"/$(basename "$EXE")
    EXE=$(dirname "$EXE")/$(basename "$EXE")
    shift 2
    ;;
  --spec2017)
    is_spec2017=true
    WORK_DIR=$(cd "$(dirname "${0}")" && pwd )/runspec_gem5_power
    shift
    ;;
  --add_job)
    with_add_job=true
    shift
    ;;
  --add_job_10)
    with_add_job_10=true
    shift
    ;;
  --reduce_job)
    with_reduce_job=true
    shift
    ;;
  --reduce_job_10)
    with_reduce_job_10=true
    shift
    ;;
  --del_job_pool)
    with_del_job_pool=true
    shift
    ;;
  --get_job_pool_size)
    with_get_job_pool_size=true
    shift
    ;;
  --kill_restore_all_jobs)
    with_kill_restore_all=true
    shift
    case "${1#*=}" in
      --m1)
        with_control_m1=true
        shift
        ;;
      --gem5)
        with_control_gem5=true
        shift
        ;;
      --)
        shift
        ;;
      *)
        exit 1
        ;;
    esac
    ;;
  --)
    shift
    ;;
  *)
    exit 1
    ;;
esac

#SEC_OPTS解析


case "${1#*=}" in
  502|999|538|523|557|526|525|511|500|519|544|503|520|554|507|541|505|510|531|521|549|508|548|527)
    spec2017_bm="${1#*=}"
    # echo $spec2017_bm
    shift 1
    ;;
  *)
    :
  ;;
esac

case "${1#*=}" in
  --restore_case)
    with_restore_case=true
    shift
    while [ -n "${1#*=}" ]; do
      case "${1#*=}" in
        502|999|538|523|557|526|525|511|500|519|544|503|520|554|507|541|505|510|531|521|549|508|548|527)
          spec2017_bm="${1#*=}"
          # echo $spec2017_bm
          shift 1
          ;;
        -j)
          if [[ ${2} =~ ^[0-9]+$ ]];then
            parallel_jobs=${2#*=}
            shift 2
          else
            shift 1
          fi
          ;;
        --build_gem5_j)
          with_build_gem5=true
          if [[ ${2} =~ ^[0-9]+$ ]];then
            build_gem5_j=${2}
            shift 2
          else
            shift 1
          fi
          ;;
        --gem5_py_opt)
          gem5_py_opt=${2}
          shift 2
          ;;
        --label)
          label=${2}
          shift 2
          ;;
        --timeout)
          timeout=${2}
          shift 2
          ;;
        --)
          shift
          ;;
        *)
          exit 1
          ;;
      esac
    done
    ;;
  --restore_all)
    with_restore_all=true
    shift
    while [ -n "${1#*=}" ]; do
      case "${1#*=}" in
        -j)
          if [[ ${2} =~ ^[0-9]+$ ]];then
            parallel_jobs=${2#*=}
            shift 2
          else
            shift 1
          fi
          ;;
        --build_gem5_j)
          with_build_gem5=true
          if [[ ${2} =~ ^[0-9]+$ ]];then
            build_gem5_j=${2}
            shift 2
          else
            shift 1
          fi
          ;;
        --gem5_py_opt)
          gem5_py_opt=${2}
          shift 2
          ;;
        --label)
          label=${2}
          shift 2
          ;;
        --timeout)
          timeout=${2}
          shift 2
          ;;       
        --)
          shift
          ;;
        *)
          echo "275,exit"
          exit 1
          ;;
      esac
    done
    ;;
  --restore_all_2)
    with_restore_all_2=true
    shift
    while [ -n "${1#*=}" ]; do
      case "${1#*=}" in
        -j)
          if [[ ${2} =~ ^[0-9]+$ ]];then
            parallel_jobs=${2#*=}
            shift 2
          else
            shift 1
          fi
          ;;
        --build_gem5_j)
          with_build_gem5=true
          if [[ ${2} =~ ^[0-9]+$ ]];then
            build_gem5_j=${2}
            shift 2
          else
            shift 1
          fi
          ;;      
        --)
          shift
          ;;
        *)
          exit 1
          ;;
      esac
    done
    ;;
  --restore_all_4)
    with_restore_all_4=true
    shift
    while [ -n "${1#*=}" ]; do
      case "${1#*=}" in
        -j)
          if [[ ${2} =~ ^[0-9]+$ ]];then
            parallel_jobs=${2#*=}
            shift 2
          else
            shift 1
          fi
          ;;
        --build_gem5_j)
          with_build_gem5=true
          if [[ ${2} =~ ^[0-9]+$ ]];then
            build_gem5_j=${2}
            shift 2
          else
            shift 1
          fi
          ;;      
        --)
          shift
          ;;
        *)
          exit 1
          ;;
      esac
    done
    ;;
  --restore_all_8)
    with_restore_all_8=true
    shift
    while [ -n "${1#*=}" ]; do
      case "${1#*=}" in
        -j)
          if [[ ${2} =~ ^[0-9]+$ ]];then
            parallel_jobs=${2#*=}
            shift 2
          else
            shift 1
          fi
          ;;
        --build_gem5_j)
          with_build_gem5=true
          if [[ ${2} =~ ^[0-9]+$ ]];then
            build_gem5_j=${2}
            shift 2
          else
            shift 1
          fi
          ;;     
        --)
          shift
          ;;
        *)
          exit 1
          ;;
      esac
    done
    ;;
  --gen_restore_compare_excel)
    with_func_gen_restore_compare_excel=true
    shift
    ;;
  --cpi_all)
    with_cpi_all=true
    shift
    ;;
  --)
    shift 1
    ;;
  *)
    exit 1
    ;;
esac

#根据解析的参数判断执行
if [[ $is_gem5 == true ]]; then
  if [[ $is_spec2017 == true ]];then
    if [[ $with_restore_case == true ]]; then
      # echo "PIDIS $$"
      # 清空
      echo >nohup.log
      func_delete_job_pool >/dev/null 2>&1
      make clean-restore -C runspec_gem5_power/${bm[${spec2017_bm}]} >/dev/null 2>&1
      begin_time=$(date +"%Y%m%d%H%M%S")
      echo "func_with_restore_case_${bm[${spec2017_bm}]} ${FLOODGATE} ${begin_time} start @ $(date +"%Y-%m-%d %H:%M:%S.%N"| cut -b 1-23)" >>nohup.log 2>&1
      if [[ $parallel_jobs -gt 5 ]]; then
        func_set_job_n_quiet 5
        (( add_job = parallel_jobs-5 ))
      elif [[ $parallel_jobs -gt 0 && $parallel_jobs -le 5 ]]; then
        read -p "WARNING: -j <= 5. Do you want to use the default -j 5? [Y/n]" para
        case $para in
          [yY]|"")
            # echo "use default -j 5"
            add_job=5
            ;;
          [nN])
            add_job=$parallel_jobs
            ;;
          *)
            read -p "Invalid input, please enter any key to exit" _
            exit 0
        esac # end case
      else
        echo "ERROR: -j must > 0 & integer"
        exit 1
      fi
      func_set_job_n_default ${add_job}

      # 运行前 build gem5
      if [[ $with_build_gem5 == true ]];then
        make build_gem5 -C runspec_gem5_power BUILD_GEM5_J=${build_gem5_j}
      fi

      if [[ $gem5_py_opt == "" ]];then
        #echo $timeout
        #echo "450, gem5_py_opt=${gem5_py_opt},label=${label}"
        func_with_restore_case "${FLOODGATE}" "${begin_time}" "${WORK_DIR}" "${add_job}" "${bm[${spec2017_bm}]}" "${gem5_py_opt}" "${label}" ${timeout} 2>&1
      else
        #echo $timeout
        #echo "453, gem5_py_opt=${gem5_py_opt},label=${label}"
        func_with_restore_case "${FLOODGATE}" "${begin_time}" "${WORK_DIR}" "${add_job}" "${bm[${spec2017_bm}]}" "${gem5_py_opt}" "${label}" ${timeout} 2>&1
      fi

    elif [[ $with_restore_all == true ]]; then
      # echo "PIDIS $$"
      # 清空
      echo >nohup.log
      func_delete_job_pool >/dev/null 2>&1
      make clean-restore -C runspec_gem5_power >/dev/null 2>&1
      begin_time=$(date +"%Y%m%d%H%M%S")
      echo "func_with_restore_all_benchmarks ${FLOODGATE} ${begin_time} start @ $(date +"%Y-%m-%d %H:%M:%S.%N"| cut -b 1-23)" >>nohup.log 2>&1
      if [[ $parallel_jobs -gt 5 ]]; then
        func_set_job_n_quiet 5
        (( add_job = parallel_jobs-5 ))
      elif [[ $parallel_jobs -gt 0 && $parallel_jobs -le 5 ]]; then
        read -p "WARNING: -j <= 5. Do you want to use the default -j 5? [Y/n]" para
        case $para in
          [yY]|"")
            # echo "use default -j 5"
            add_job=5
            ;;
          [nN])
            add_job=$parallel_jobs
            ;;
          *)
            read -p "Invalid input, please enter any key to exit" _
            exit 0
        esac # en end case
      else
        echo "ERROR: -j must > 0 & integer"
        exit 1
      fi
      func_set_job_n_default ${add_job}

      # 运行前 build gem5
      if [[ $with_build_gem5 == true ]];then
        make build_gem5 -C runspec_gem5_power BUILD_GEM5_J=${build_gem5_j}
      fi

      if [[ $gem5_py_opt == "" ]];then
        #echo $timeout
        #echo "489, gem5_py_opt=${gem5_py_opt},label=${label}"
        func_with_restore_all_benchmarks "${FLOODGATE}" "${begin_time}" "${WORK_DIR}" "${add_job}" "${gem5_py_opt}" "${label}" ${timeout} 2>&1
      else
        #echo $timeout
        #echo "492, gem5_py_opt=${gem5_py_opt},label=${label}"
        func_with_restore_all_benchmarks "${FLOODGATE}" "${begin_time}" "${WORK_DIR}" "${add_job}" "${gem5_py_opt}" "${label}" ${timeout} 2>&1
      fi
    elif [[ $with_restore_all_2 == true ]]; then
      # echo "PIDIS $$"
      # 清空
      echo >nohup.log
      func_delete_job_pool >/dev/null 2>&1
      make clean-restore -C runspec_gem5_power >/dev/null 2>&1
      begin_time=$(date +"%Y%m%d%H%M%S")
      echo "func_with_restore_all_benchmarks_n2 ${FLOODGATE} ${begin_time} start @ $(date +"%Y-%m-%d %H:%M:%S.%N"| cut -b 1-23)" >>nohup.log 2>&1
      if [[ $parallel_jobs -gt 5 ]]; then
        func_set_job_n_quiet 5
        (( add_job = parallel_jobs-5 ))
      elif [[ $parallel_jobs -gt 0 && $parallel_jobs -le 5 ]]; then
        read -p "WARNING: -j <= 5. Do you want to use the default -j 5? [Y/n]" para
        case $para in
          [yY]|"")
            # echo "use default -j 5"
            add_job=5
            ;;
          [nN])
            add_job=$parallel_jobs
            ;;
          *)
            read -p "Invalid input, please enter any key to exit" _
            exit 0
        esac # end case
      else
        echo "ERROR: -j must > 0 & integer"
        exit 1
      fi
      func_set_job_n_default ${add_job}

      # 运行前 build gem5
      if [[ $with_build_gem5 == true ]];then
        make build_gem5 -C runspec_gem5_power BUILD_GEM5_J=${build_gem5_j}
      fi
            
      (func_with_restore_all_benchmarks_n2 "${FLOODGATE}" "${begin_time}" "${WORK_DIR}" "${add_job}" 2>&1 &)
    elif [[ $with_restore_all_4 == true ]]; then
      # echo "PIDIS $$"
      # 清空
      echo >nohup.log
      func_delete_job_pool >/dev/null 2>&1
      make clean-restore -C runspec_gem5_power >/dev/null 2>&1
      begin_time=$(date +"%Y%m%d%H%M%S")
      echo "func_with_restore_all_benchmarks_n4 ${FLOODGATE} ${begin_time} start @ $(date +"%Y-%m-%d %H:%M:%S.%N"| cut -b 1-23)" >>nohup.log 2>&1
      if [[ $parallel_jobs -gt 5 ]]; then
        func_set_job_n_quiet 5
        (( add_job = parallel_jobs-5 ))
      elif [[ $parallel_jobs -gt 0 && $parallel_jobs -le 5 ]]; then
        read -p "WARNING: -j <= 5. Do you want to use the default -j 5? [Y/n]" para
        case $para in
          [yY]|"")
            # echo "use default -j 5"
            add_job=5
            ;;
          [nN])
            add_job=$parallel_jobs
            ;;
          *)
            read -p "Invalid input, please enter any key to exit" _
            exit 0
        esac # end case
      else
        echo "ERROR: -j must > 0 & integer"
        exit 1
      fi
      func_set_job_n_default ${add_job}

      # 运行前 build gem5
      if [[ $with_build_gem5 == true ]];then
        make build_gem5 -C runspec_gem5_power BUILD_GEM5_J=${build_gem5_j}
      fi
      
      (func_with_restore_all_benchmarks_n4 "${FLOODGATE}" "${begin_time}" "${WORK_DIR}" "${add_job}" 2>&1 &)
    elif [[ $with_restore_all_8 == true ]]; then
      # echo "PIDIS $$"
      # 清空
      echo >nohup.log
      func_delete_job_pool >/dev/null 2>&1
      make clean-restore -C runspec_gem5_power >/dev/null 2>&1
      begin_time=$(date +"%Y%m%d%H%M%S")
      echo "func_with_restore_all_benchmarks_n8 ${FLOODGATE} ${begin_time} start @ $(date +"%Y-%m-%d %H:%M:%S.%N"| cut -b 1-23)" >>nohup.log 2>&1
      if [[ $parallel_jobs -gt 5 ]]; then
        func_set_job_n_quiet 5
        (( add_job = parallel_jobs-5 ))
      elif [[ $parallel_jobs -gt 0 && $parallel_jobs -le 5 ]]; then
        read -p "WARNING: -j <= 5. Do you want to use the default -j 5? [Y/n]" para
        case $para in
          [yY]|"")
            # echo "use default -j 5"
            add_job=5
            ;;
          [nN])
            add_job=$parallel_jobs
            ;;
          *)
            read -p "Invalid input, please enter any key to exit" _
            exit 0
        esac # end case
      else
        echo "ERROR: -j must > 0 & integer"
        exit 1
      fi
      func_set_job_n_default ${add_job}

      # 运行前 build gem5
      if [[ $with_build_gem5 == true ]];then
        make build_gem5 -C runspec_gem5_power BUILD_GEM5_J=${build_gem5_j}
      fi
            
      (func_with_restore_all_benchmarks_n8 "${FLOODGATE}" "${begin_time}" "${WORK_DIR}" "${add_job}" 2>&1 &)
    elif [[ $with_cpi_all == true ]]; then
      (func_with_cpi_all_benchmarks >>nohup.log 2>&1 &)
    elif [[ $with_func_gen_restore_compare_excel == true ]]; then
      (func_gen_restore_compare_excel "$(date +"%Y%m%d%H%M%S")" 2>&1)
    else
      exit 1
    fi
  else
    exit 1
  fi
elif [[ $is_control == true ]]; then
  if [[ $with_add_job == true ]]; then
    func_add_job
  elif [[ $with_add_job_10 == true ]]; then
    func_add_job_10
  elif [[ $with_reduce_job == true ]]; then
    func_reduce_job
  elif [[ $with_reduce_job_10 == true ]]; then
    func_reduce_job_10
  elif [[ $with_del_job_pool == true ]]; then
    func_delete_job_pool
  elif [[ $with_get_job_pool_size == true ]]; then
    func_get_job_pool_size
  elif [[ $with_kill_restore_all == true ]]; then
    killobj=""
    if [[ $with_control_gem5 == true ]]; then
      killobj="gem5.\w+ .*-d ${WORK_DIR}/[\/\w\.]+/output_ckp\d+"
    elif [[ $with_control_m1 == true ]]; then
      killobj="valgrind|simpoint|vgi2qt|run_timer|otimer|itrace|ScrollPipeViewer"
    fi
#    echo "${killobj}" "${FLOODGATE}"
    func_kill_restore_all_jobs "${killobj}" "${FLOODGATE}"
  else
    exit 1
  fi
else
  exit 1
fi
exit 0