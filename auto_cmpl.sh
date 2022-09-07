#判断选项
is_m1=false
is_gem5=false
is_host=false
is_myexe=false
is_spec2017=false
is_control=false
with_all_benchmarks=false
with_entire_all_benchmarks=false
with_entire=false

#判断参数个数选择不同模式
with_all_steps=false
with_itrace=false
with_qtrace=false
with_run_timer=false
with_pipe_view=false
with_i_insts=false
with_q_jump=false
with_q_convert=false
with_r_insts=false
with_r_cpi_interval=false
with_r_reset_stats=false
with_r_pipe_type=false
with_r_pipe_begin=false
with_r_pipe_end=false
with_max_insts=false
with_slice_len=false

with_restore_all=false
with_cpi_all=false
with_kill_restore_all=false
with_control_gem5=false
with_control_m1=false

with_add_thread=false
with_add_thread_10=false
with_reduce_thread=false
with_reduce_thread_10=false
with_del_thread_pool=false
with_get_thread_pool_size=false
with_func_gen_restore_compare_excel=false

cmd_gem5_m1_control(){
  for option in "${COMP_WORDS[@]}";do
    case "${option}" in
      --m1)
        is_m1=true
        ;;
      --myexe)
        is_myexe=true
        ;;
      --spec2017)
        is_spec2017=true
        ;;
      --all_benchmarks)
        with_all_benchmarks=true
        ;;
      --entire_all_benchmarks)
        with_entire_all_benchmarks=true
        ;;
      --entire)
        with_entire=true
        ;;
      --all_steps)
        with_all_steps=true
        ;;
      --itrace)
        with_itrace=true
        ;;
      --qtrace)
        with_qtrace=true
        ;;
      --run_timer)
        with_run_timer=true
        ;;
      --pipe_view)
        with_pipe_view=true
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
      --cpi_all)
        with_cpi_all=true
        ;;
      *)
        ;;
    esac
  done
}

cmd_m1_steps(){
    if [[ $with_all_benchmarks == true ]];then
      options="--q_jump --q_convert --r_pipe_begin --r_pipe_end"
      for (( i=0;i<${#COMP_WORDS[@]}-1;i++ ));do
        option=${COMP_WORDS[i]}
        options=${options/${option}/}
      done
    elif [[ $with_entire_all_benchmarks == true ]]; then
      options=""
    elif [[ $with_all_steps == true ]]; then
      options="--i_insts --q_jump --q_convert --r_insts --r_pipe_type --r_pipe_begin --r_pipe_end"
      for (( i=0;i<${#COMP_WORDS[@]}-1;i++ ));do
        option=${COMP_WORDS[i]}
        options=${options/${option}/}
      done
    elif [[ $with_itrace == true ]]; then
      options="--i_insts"
      for (( i=0;i<${#COMP_WORDS[@]}-1;i++ ));do
        option=${COMP_WORDS[i]}
        options=${options/${option}/}
      done
    elif [[ $with_qtrace == true ]]; then
      options="--q_jump --q_convert"
      for (( i=0;i<${#COMP_WORDS[@]}-1;i++ ));do
        option=${COMP_WORDS[i]}
        options=${options/${option}/}
      done
    elif [[ $with_run_timer == true ]]; then
      options="--r_insts --r_pipe_type --r_pipe_begin --r_pipe_end"
      for (( i=0;i<${#COMP_WORDS[@]}-1;i++ ));do
        option=${COMP_WORDS[i]}
        options=${options/${option}/}
      done
    elif [[ $with_pipe_view == true ]]; then
        options=""
    elif [[ $with_entire == true || $with_restore_all == true || $with_cpi_all = true ]]; then
        options=""
    else
      options="-b -e"
      for (( i=0;i<${#COMP_WORDS[@]}-1;i++ ));do
        option=${COMP_WORDS[i]}
        options=${options/${option}/}
      done
    fi
}

cmd_m1_myexe(){
  local cur=${COMP_WORDS[COMP_CWORD]};
  local pre=${COMP_WORDS[COMP_CWORD-1]};
  cmd_gem5_m1_control
  if [[ $pre == "--myexe" ]];then
    COMPREPLY=( $(compgen -f -- ${cur} ) )
    return
  elif [[ ${COMP_WORDS[COMP_CWORD-2]} == "--myexe" ]];then
    options="--entire --all_steps --itrace --qtrace --run_timer --pipe_view -b -e"
  elif [[ $pre == -a || $pre == --all || $pre == --all_steps ]]; then
    options="--i_insts --q_jump --q_convert --r_insts --r_pipe_type --r_pipe_begin --r_pipe_end"
  elif [[ $pre == -i || $pre == --itrace ]]; then
    options="--i_insts"
  elif [[ $pre == -q || $pre == --qtrace ]]; then
    options="--q_jump --q_convert"
  elif [[ $pre == -r || $pre == --run_timer ]]; then
    options="--r_insts  --r_pipe_type --r_pipe_begin --r_pipe_end"
  elif [[ $pre == -p || $pre == --pipe_view ]]; then
    options=""
    #缺省模式
#  elif [[ $with_all_benchmarks == false && $with_entire_all_benchmarks == false && $with_all_steps == false && $with_itrace == false && $with_qtrace == false && $with_run_timer == false && $with_pipe_view == false ]];then
#    options="-b -e"
#    COMPREPLY=( $(compgen -W "${options}" -- ${cur}) )
  else
    cmd_m1_steps
  fi
  COMPREPLY=( $(compgen -W "${options}" -- ${cur}) )
}

cmd_m1_spec2017(){
  local cur=${COMP_WORDS[COMP_CWORD]};
  local pre=${COMP_WORDS[COMP_CWORD-1]};
  cmd_gem5_m1_control
  if [[ $pre == "--spec2017" ]];then
    options="502 999 538 523 557 526 525 511 500 519 544 503 520 554 507 541 505 510 531 521 549 508 548 527 --restore_all"
  elif [[ $pre == "--all_benchmarks" ]];then
    options="--q_jump --q_convert --r_pipe_begin --r_pipe_end"
  elif [[ $pre == "--entire_all_benchmarks" ]]; then
    options="--max_insts --slice_len"
  elif [[ $pre == [0-9][0-9][0-9] ]]; then
    if [[ ${COMP_WORDS[COMP_CWORD-2]} == "--spec2017" ]];then
      options="--all_steps --itrace --qtrace --run_timer --pipe_view -b -e"
    fi
  elif [[ $pre == -a || $pre == --all || $pre == --all_steps ]]; then
    options="--i_insts --q_jump --q_convert --r_insts --r_pipe_type --r_pipe_begin --r_pipe_end"
  elif [[ $pre == -i || $pre == --itrace ]]; then
    options="--i_insts"
  elif [[ $pre == -q || $pre == --qtrace ]]; then
    options="--q_jump --q_convert"
  elif [[ $pre == -r || $pre == --run_timer ]]; then
    options="--r_insts  --r_pipe_type --r_pipe_begin --r_pipe_end"
  elif [[ $pre == -p || $pre == --pipe_view ]]; then
    options=""
    #缺省模式
#  elif [[ $with_all_benchmarks == false && $with_entire_all_benchmarks == false && $with_all_steps == false && $with_itrace == false && $with_qtrace == false && $with_run_timer == false && $with_pipe_view == false ]];then
#    options="-b -e"
#    COMPREPLY=( $(compgen -W "${options}" -- ${cur}) )
  else
    cmd_m1_steps
  fi
  COMPREPLY=( $(compgen -W "${options}" -- ${cur}) )
}

cmd_gem5_spec2017(){
  local cur=${COMP_WORDS[COMP_CWORD]};
  local pre=${COMP_WORDS[COMP_CWORD-1]};
  cmd_gem5_m1_control
  if [[ $pre == "--spec2017" ]];then
    options="--restore_all --gen_restore_compare_excel"
  elif [ $pre == "--restore_all" ]; then
    options="-j"
  else
    options=""
  fi
  COMPREPLY=( $(compgen -W "${options}" -- ${cur}) )
}

cmd_control(){
  local cur=${COMP_WORDS[COMP_CWORD]};
  local pre=${COMP_WORDS[COMP_CWORD-1]};
  if [[ $pre == "--kill_restore_all" ]];then
    options="--gem5 --m1"
  else
    options=""
  fi
  COMPREPLY=( $(compgen -W "${options}" -- ${cur}) )
}

cmd_hub(){
  COMPREPLY=()
  #判断选项
  is_m1=false
  is_gem5=false
  is_control=false

  is_host=false
  is_myexe=false
  is_spec2017=false
  with_all_benchmarks=false
  with_entire_all_benchmarks=false
  with_entire=false

  #判断参数个数选择不同模式
  with_all_steps=false
  with_itrace=false
  with_qtrace=false
  with_run_timer=false
  with_pipe_view=false
  with_i_insts=false
  with_q_jump=false
  with_q_convert=false
  with_r_insts=false
  with_r_cpi_interval=false
  with_r_reset_stats=false
  with_r_pipe_type=false
  with_r_pipe_begin=false
  with_r_pipe_end=false
  with_max_insts=false
  with_slice_len=false
  with_restore_all=false
  with_cpi_all=false
  with_kill_restore_all=false
  with_control_gem5=false
  with_control_m1=false

  with_add_thread=false
  with_add_thread_10=false
  with_reduce_thread=false
  with_reduce_thread_10=false
  with_del_thread_pool=false
  with_get_thread_pool_size=false
  with_func_gen_restore_compare_excel=false

  local cur=${COMP_WORDS[COMP_CWORD]};
  local pre=${COMP_WORDS[COMP_CWORD-1]};

  case $COMP_CWORD in
    0)#$COMP_CWORD从1开始,代表将要输入的位置,${COMP_WORDS[0]}为脚本名
#      echo "${COMP_WORDS[@]}" >> len.txt
      ;;
    1)
      COMPREPLY=( $(compgen -W "--m1 --gem5 --control" -- ${cur}) )
      ;;
    2)
      if [[ ${pre} == "--gem5" ]]; then
        COMPREPLY=( $(compgen -W "--spec2017" -- ${cur}) )
      elif [[ ${pre} == "--m1" ]]; then
        COMPREPLY=( $(compgen -W "--myexe --spec2017" -- ${cur}) )
      elif [[ ${pre} == "--control" ]]; then
        COMPREPLY=( $(compgen -W "--add_thread --reduce_thread --add_thread_10 --reduce_thread_10 --get_thread_pool_size --del_thread_pool --kill_restore_all" -- ${cur}) )
      else
        exit 1
      fi
      ;;
    3|*)
      if [[ ${COMP_WORDS[1]} == "--m1" || ${COMP_WORDS[1]} == "--gem5" ]]; then
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