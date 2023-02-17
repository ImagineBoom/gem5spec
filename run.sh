
version="1.0.0"

#解析命令行选项<optstring>及参数<parameters>
#echo ${@}
getopt_cmd=$(getopt \
-o aiqrphvVc:b:e:j: \
--long m1,gem5,spec2017,myexe:,\
all,all_steps,entire,itrace,qtrace,run_timer,pipe_view,gen_txt,not_gen_txt,\
all_benchmarks,entire_all_benchmarks,max_insts,slice_len:,gem5_ckp_py_opt:,timeout:,build_gem5_j:,\
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

#rm -rf nohup.out 2>/dev/null

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
  --entire)
    with_entire=true
    target=entire
    shift 1
    func_m1_args_parser $@
    ;;
  -a|--all|--all_steps)
    with_all_steps=true
    if [[ $is_m1 == true ]]; then
      target=all
    elif [[ $is_spec2017 == true ]]; then
      target=trace
    else
      exit 1
    fi
    shift 1
    func_m1_args_parser $@
    ;;
  -i|--itrace)
    with_itrace=true
    target=itrace
    shift 1
    func_m1_args_parser $@
    ;;
  -q|--qtrace)
    with_qtrace=true
    target=qtrace
    shift 1
    func_m1_args_parser $@
    ;;
  -r|--run_timer)
    with_run_timer=true
    if [[ $is_m1 == true ]]; then
      target=run_timer
    elif [[ $is_spec2017 == true ]]; then
      target=m1
    else
      exit 1
    fi
    shift 1
    func_m1_args_parser $@
    ;;
  -p|--pipe_view)
    with_pipe_view=true
    target=m1_pipeview
    shift 1
    func_m1_args_parser $@
    ;;
  --all_benchmarks)
    with_all_benchmarks=true
    shift 1
    func_m1_args_parser $@
    ;;
  --entire_all_benchmarks) #用于查看整体CPI等数据
    with_entire_all_benchmarks=true
    shift 1
    while [ -n "${1#*=}" ]; do
      case "${1#*=}" in
        --max_insts)
          with_max_insts=true
          shift
          ;;
        --slice_len)
          slice_len="${2#*=}"
          with_slice_len=true
          shift 2
          ;;
        --)
          shift
          ;;
        *)
          break
          ;;
      esac
    done
    ;;
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
        --gem5_ckp_py_opt)
          gem5_ckp_py_opt=${2}
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
        --gem5_ckp_py_opt)
          gem5_ckp_py_opt=${2}
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
  -b|--r_pipe_begin|--SCROLL_BEGIN|-e|--r_pipe_end|--SCROLL_END|--gen_txt|--not_gen_txt) #缺省参数模式
    # echo "225"
    func_m1_args_parser $@
    # echo $args
    ;;
  --)
    shift 1
    ;;
  *)
    exit 1
    ;;
esac

#根据解析的参数判断执行
if [[ $is_m1 == true ]]; then
  if [[ $is_myexe == true ]]; then
    #完整参数模式
    if [[ $with_all_steps == true || $with_itrace == true || $with_qtrace == true || $with_run_timer == true || $with_pipe_view == true || $with_entire == true ]] ; then
      if [[ "${CPI_INTERVAL}" == "-1" ]];then
        CPI_INTERVAL="${NUM_INST}"
      fi
    ./p8-m1.sh "${EXE}" --${target} "${NUM_INSNS_TO_COLLECT}" "${JUMP_NUM}" "${CONVERT_NUM_Vgi_RECS}" "${NUM_INST}" "${CPI_INTERVAL}" "${RESET_STATS}" "${SCROLL_PIPE}" "${SCROLL_BEGIN}" "${SCROLL_END}" "$with_gen_txt"
    #缺省参数模式1
    elif [[ $with_r_pipe_begin == true && $with_r_pipe_end == true ]]; then
      (( SCROLL_BEGIN = SCROLL_BEGIN - 1 ))
      (( insts = SCROLL_END - SCROLL_BEGIN ))
      JUMP_NUM=${SCROLL_BEGIN}
      CONVERT_NUM_Vgi_RECS=${insts}
      NUM_INST=${insts}
      CPI_INTERVAL="${NUM_INST}"
      SCROLL_BEGIN=1
      SCROLL_END=${insts}
      ./p8-m1.sh "${EXE}" -- "${NUM_INSNS_TO_COLLECT}" "${JUMP_NUM}" "${CONVERT_NUM_Vgi_RECS}" "${NUM_INST}" "${CPI_INTERVAL}" "${RESET_STATS}" "${SCROLL_PIPE}" "${SCROLL_BEGIN}" "${SCROLL_END}" "$with_gen_txt"
    fi
  elif [[ $is_spec2017 == true ]]; then
    if [[ $with_all_benchmarks == true ]]; then
      (func_with_all_benchmarks >>nohup.out 2>&1 &)
    elif [[ $with_entire_all_benchmarks == true ]]; then
      (func_with_entire_all_benchmarks >>nohup.out 2>&1 &)
    elif [[ $with_restore_all == true ]]; then
      func_set_job_n_default 5
      (func_with_restore_all_benchmarks "${FLOODGATE}" >>nohup.out 2>&1 &)
    elif [[ $with_cpi_all == true ]]; then
      (func_with_cpi_all_benchmarks >>nohup.out 2>&1 &)
    else
      #完整参数模式
      if [[ $with_all_steps == true ]] ; then
        if [[ ${CPI_INTERVAL} == -1 ]];then
          CPI_INTERVAL=${NUM_INST}
        fi
        make trace -C runspec_gem5_power/"${bm[${spec2017_bm}]}" NUM_INSNS_TO_COLLECT=${NUM_INSNS_TO_COLLECT} JUMP_NUM=${JUMP_NUM} CONVERT_NUM_Vgi_RECS=${CONVERT_NUM_Vgi_RECS} NUM_INST=${NUM_INST} CPI_INTERVAL=${CPI_INTERVAL} RESET_STATS=${RESET_STATS} SCROLL_PIPE=${SCROLL_PIPE} SCROLL_BEGIN=${SCROLL_BEGIN} SCROLL_END=${SCROLL_END}
        make m1_pipeview -C runspec_gem5_power/"${bm[${spec2017_bm}]}" ${args}
      elif [[ $with_itrace == true || $with_qtrace == true || $with_run_timer == true || $with_pipe_view == true  ]]; then
        make ${target} -C runspec_gem5_power/"${bm[${spec2017_bm}]}" ${args}
      #缺省参数模式1
      elif [[ $with_r_pipe_begin == true && $with_r_pipe_end == true ]]; then
        #args=("${args}")
        #pipe_b="${args[0]##*=}"
        #pipe_e="${args[1]##*=}"
        pipe_b=$(echo "${args[@]}" | grep -oP "SCROLL_BEGIN=\d+" | grep -oP "\d+")
        (( pipe_b=pipe_b-1 ))
        pipe_e=$(echo "${args[@]}" | grep -oP "SCROLL_END=\d+" | grep -oP "\d+")
        (( insts = pipe_e - pipe_b ))
        # make trace -C runspec_gem5_power/"${bm[${spec2017_bm}]}" NUM_INSNS_TO_COLLECT=${bm_insts[${spec2017_bm}]} JUMP_NUM=${pipe_b} CONVERT_NUM_Vgi_RECS=${insts} NUM_INST=${insts} CPI_INTERVAL=${insts} RESET_STATS=1 SCROLL_PIPE=1 SCROLL_BEGIN=1 SCROLL_END=${insts}
        if [[ ! -e runspec_gem5_power/"${bm[${spec2017_bm}]}"/"${bm[${spec2017_bm}]}".vgi ]]; then
          make itrace -C runspec_gem5_power/"${bm[${spec2017_bm}]}" NUM_INSNS_TO_COLLECT=${bm_insts[${spec2017_bm}]} JUMP_NUM=${pipe_b} CONVERT_NUM_Vgi_RECS=${insts} NUM_INST=${insts} CPI_INTERVAL=${insts} RESET_STATS=1 SCROLL_PIPE=1 SCROLL_BEGIN=1 SCROLL_END=${insts}
        fi
        make qtrace -C runspec_gem5_power/"${bm[${spec2017_bm}]}" NUM_INSNS_TO_COLLECT=${bm_insts[${spec2017_bm}]} JUMP_NUM=${pipe_b} CONVERT_NUM_Vgi_RECS=${insts} NUM_INST=${insts} CPI_INTERVAL=${insts} RESET_STATS=1 SCROLL_PIPE=1 SCROLL_BEGIN=1 SCROLL_END=${insts}
        make m1 -C runspec_gem5_power/"${bm[${spec2017_bm}]}" NUM_INSNS_TO_COLLECT=${bm_insts[${spec2017_bm}]} JUMP_NUM=${pipe_b} CONVERT_NUM_Vgi_RECS=${insts} NUM_INST=${insts} CPI_INTERVAL=${insts} RESET_STATS=1 SCROLL_PIPE=1 SCROLL_BEGIN=1 SCROLL_END=${insts}
        make m1_pipeview -C runspec_gem5_power/"${bm[${spec2017_bm}]}"
      fi
    fi
  else
    exit 1
  fi
elif [[ $is_gem5 == true ]]; then
  if [[ $is_spec2017 == true ]];then
    if [[ $with_restore_case == true ]]; then
      # echo "PIDIS $$"
      # 清空
      echo >nohup.out
      func_delete_job_pool >/dev/null 2>&1
      make clean-restore -C runspec_gem5_power/${bm[${spec2017_bm}]} >/dev/null 2>&1
      begin_time=$(date +"%Y%m%d%H%M%S")
      echo "func_with_restore_case_${bm[${spec2017_bm}]} ${FLOODGATE} ${begin_time} start @ $(date +"%Y-%m-%d %H:%M:%S.%N"| cut -b 1-23)" >>nohup.out 2>&1
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

      if [[ $gem5_ckp_py_opt == "" ]];then
        #echo $timeout
        #echo "450, gem5_ckp_py_opt=${gem5_ckp_py_opt},label=${label}"
        func_with_restore_case "${FLOODGATE}" "${begin_time}" "${WORK_DIR}" "${add_job}" "${bm[${spec2017_bm}]}" "${gem5_ckp_py_opt}" "${label}" ${timeout} 2>&1
      else
        #echo $timeout
        #echo "453, gem5_ckp_py_opt=${gem5_ckp_py_opt},label=${label}"
        func_with_restore_case "${FLOODGATE}" "${begin_time}" "${WORK_DIR}" "${add_job}" "${bm[${spec2017_bm}]}" "${gem5_ckp_py_opt}" "${label}" ${timeout} 2>&1
      fi

    elif [[ $with_restore_all == true ]]; then
      # echo "PIDIS $$"
      # 清空
      echo >nohup.out
      func_delete_job_pool >/dev/null 2>&1
      make clean-restore -C runspec_gem5_power >/dev/null 2>&1
      begin_time=$(date +"%Y%m%d%H%M%S")
      echo "func_with_restore_all_benchmarks ${FLOODGATE} ${begin_time} start @ $(date +"%Y-%m-%d %H:%M:%S.%N"| cut -b 1-23)" >>nohup.out 2>&1
      if [[ $parallel_jobs -gt 5 ]]; then
        func_set_job_n_quiet 5
        (( add_job = parallel_jobs-5 ))
      elif [[ $parallel_jobs -gt 0 && $parallel_jobs -le 5 ]]; then
        read -p "WARNING: -j <= 5. Do you want to use the default -j 5? [Y/n]" para
        case $para in
          [yY|""])
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

      if [[ $gem5_ckp_py_opt == "" ]];then
        #echo $timeout
        #echo "489, gem5_ckp_py_opt=${gem5_ckp_py_opt},label=${label}"
        func_with_restore_all_benchmarks "${FLOODGATE}" "${begin_time}" "${WORK_DIR}" "${add_job}" "${gem5_ckp_py_opt}" "${label}" ${timeout} 2>&1
      else
        #echo $timeout
        #echo "492, gem5_ckp_py_opt=${gem5_ckp_py_opt},label=${label}"
        func_with_restore_all_benchmarks "${FLOODGATE}" "${begin_time}" "${WORK_DIR}" "${add_job}" "${gem5_ckp_py_opt}" "${label}" ${timeout} 2>&1
      fi
    elif [[ $with_restore_all_2 == true ]]; then
      # echo "PIDIS $$"
      # 清空
      echo >nohup.out
      func_delete_job_pool >/dev/null 2>&1
      make clean-restore -C runspec_gem5_power >/dev/null 2>&1
      begin_time=$(date +"%Y%m%d%H%M%S")
      echo "func_with_restore_all_benchmarks_n2 ${FLOODGATE} ${begin_time} start @ $(date +"%Y-%m-%d %H:%M:%S.%N"| cut -b 1-23)" >>nohup.out 2>&1
      if [[ $parallel_jobs -gt 5 ]]; then
        func_set_job_n_quiet 5
        (( add_job = parallel_jobs-5 ))
      elif [[ $parallel_jobs -gt 0 && $parallel_jobs -le 5 ]]; then
        read -p "WARNING: -j <= 5. Do you want to use the default -j 5? [Y/n]" para
        case $para in
          [yY|""])
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
      echo >nohup.out
      func_delete_job_pool >/dev/null 2>&1
      make clean-restore -C runspec_gem5_power >/dev/null 2>&1
      begin_time=$(date +"%Y%m%d%H%M%S")
      echo "func_with_restore_all_benchmarks_n4 ${FLOODGATE} ${begin_time} start @ $(date +"%Y-%m-%d %H:%M:%S.%N"| cut -b 1-23)" >>nohup.out 2>&1
      if [[ $parallel_jobs -gt 5 ]]; then
        func_set_job_n_quiet 5
        (( add_job = parallel_jobs-5 ))
      elif [[ $parallel_jobs -gt 0 && $parallel_jobs -le 5 ]]; then
        read -p "WARNING: -j <= 5. Do you want to use the default -j 5? [Y/n]" para
        case $para in
          [yY|""])
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
      echo >nohup.out
      func_delete_job_pool >/dev/null 2>&1
      make clean-restore -C runspec_gem5_power >/dev/null 2>&1
      begin_time=$(date +"%Y%m%d%H%M%S")
      echo "func_with_restore_all_benchmarks_n8 ${FLOODGATE} ${begin_time} start @ $(date +"%Y-%m-%d %H:%M:%S.%N"| cut -b 1-23)" >>nohup.out 2>&1
      if [[ $parallel_jobs -gt 5 ]]; then
        func_set_job_n_quiet 5
        (( add_job = parallel_jobs-5 ))
      elif [[ $parallel_jobs -gt 0 && $parallel_jobs -le 5 ]]; then
        read -p "WARNING: -j <= 5. Do you want to use the default -j 5? [Y/n]" para
        case $para in
          [yY|""])
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
      (func_with_cpi_all_benchmarks >>nohup.out 2>&1 &)
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