source ./scripts/params.sh

cmd_gem5_control(){
  for (( i=0;i<${#COMP_WORDS[@]}-1;i++ ));do
    option=${COMP_WORDS[i]}
    case "${option}" in
      --spec2017)
        is_spec2017=true
        ;;
      --all_benchmarks)
        with_all_benchmarks=true
        ;;
      --max_insts)
        with_max_insts=true
        ;;
      --slice_len)
        with_slice_len=true
        ;;
      --control)
        is_control=true
        ;;
      --gem5)
        is_gem5=true
        ;;
      --restore_all)
        with_restore_all=true
        ;;
      --restore_case)
        with_restore_case=true
        ;;
      --restore_all_2)
        with_restore_all_2=true
        ;;
      --restore_all_4)
        with_restore_all_4=true
        ;;
      --restore_all_8)
        with_restore_all_8=true
        ;;
      --cpi_all)
        with_cpi_all=true
        ;;
      -j)
        if [[ ${COMP_WORDS[i+1]} =~ ^[0-9]+$ ]];then
          parallel_jobs=${COMP_WORDS[i+1]}
        fi
        ;;
      --build_gem5_j)
        if [[ ${COMP_WORDS[i+1]} =~ ^[0-9]+$ ]];then
          build_gem5_j=${COMP_WORDS[i+1]}
        fi
        ;;
      *)
        ;;
    esac
  done
}

cmd_gem5_spec2017(){
  local cur=${COMP_WORDS[COMP_CWORD]};
  local pre=${COMP_WORDS[COMP_CWORD-1]};
  cmd_gem5_control
  if [[ $pre == "--spec2017" ]];then
    options="--restore_case --restore_all --restore_all_2 --restore_all_4 --restore_all_8 --gen_restore_compare_excel"
  elif [[ $pre == "--restore_case" ]];then
    options="502 999 538 523 557 526 525 511 500 519 544 503 520 554 507 541 505 510 531 521 549 508 548 527"
  elif [[ $pre == [0-9][0-9][0-9] ]]; then
    if [[ ${COMP_WORDS[COMP_CWORD-2]} == "--restore_case" ]];then
      options="-j --build_gem5_j"
    fi
  elif [[ $with_restore_case || $with_restore_all || $with_restore_all_2 || $with_restore_all_4 || $with_restore_all_8 ]]; then
    options="-j --build_gem5_j"
    for (( i=0;i<${#COMP_WORDS[@]}-1;i++ ));do
      option=${COMP_WORDS[i]}
      if [[ $option == -j && $parallel_jobs == -1 ]];then
        # echo 1
        options=""
      elif [[ $option == --build_gem5_j && $build_gem5_j == -1 ]];then
        # echo 2
        options=""
      else
        # echo $build_gem5_j
        options=${options/${option}/}
      fi
    done 

  else
    options=""
  fi
  COMPREPLY=( $(compgen -W "${options}" -- ${cur}) )
}

cmd_control(){
  local cur=${COMP_WORDS[COMP_CWORD]};
  local pre=${COMP_WORDS[COMP_CWORD-1]};
  if [[ $pre == "--kill_restore_all_jobs" ]];then
    options="--gem5"
  else
    options=""
  fi
  COMPREPLY=( $(compgen -W "${options}" -- ${cur}) )
}

cmd_hub(){
  COMPREPLY=()
  source ./scripts/params.sh

  local cur=${COMP_WORDS[COMP_CWORD]};
  local pre=${COMP_WORDS[COMP_CWORD-1]};

  case $COMP_CWORD in
    0)#$COMP_CWORD从1开始,代表将要输入的位置,${COMP_WORDS[0]}为脚本名
#      echo "${COMP_WORDS[@]}" >> len.txt
      ;;
    1)
      COMPREPLY=( $(compgen -W "--gem5 --control" -- ${cur}) )
      ;;
    2)
      if [[ ${pre} == "--gem5" ]]; then
        COMPREPLY=( $(compgen -W "--spec2017" -- ${cur}) )
      elif [[ ${pre} == "--control" ]]; then
        COMPREPLY=( $(compgen -W "--add_job --reduce_job --add_job_10 --reduce_job_10 --get_job_pool_size --del_job_pool --kill_restore_all_jobs" -- ${cur}) )
      else
        exit 1
      fi
      ;;
    3|*)
      if [[ ${COMP_WORDS[1]} == "--gem5" ]]; then
        cmd_f="${COMP_WORDS[1]##*-}_${COMP_WORDS[2]##*-}"
        cmd_f="${cmd_f%%=*}"
        #echo "${cmd_f}"
        #1代表被调用脚本从COMP_WORDS的第几个下标开始
        eval cmd_"${cmd_f}"
      elif [[ ${COMP_WORDS[1]} == "--control" ]]; then
        cmd_f="${COMP_WORDS[1]##*-}"
        cmd_f="${cmd_f%%=*}"
        eval cmd_"${cmd_f}"
      fi
      ;;
  esac
}

complete -F cmd_hub ./run.sh