#判断选项
is_m1=false
is_gem5=false
is_host=false
is_myexe=false
is_spec2017=false
with_all_benchmarks=false
with_entire_all_benchmarks=false
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

cmd_control(){
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
  cmd_control
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
  cmd_control
  if [[ $pre == "--spec2017" ]];then
    options="502 999 538 523 557 526 525 511 500 519 544 503 520 554 507 541 505 510 531 521 549 508 548 527 --all_benchmarks --entire_all_benchmarks"
  elif [[ $pre == "--all_benchmarks" ]];then
    options="--q_jump --q_convert --r_pipe_begin --r_pipe_end"
  elif [[ $pre == "--entire_all_benchmarks" ]]; then
    options=""
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


cmd_hub(){
  COMPREPLY=()
  #判断选项
  is_m1=false
  is_gem5=false
  is_host=false
  is_myexe=false
  is_spec2017=false
  with_all_benchmarks=false
  with_entire_all_benchmarks=false
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
  local cur=${COMP_WORDS[COMP_CWORD]};
  local pre=${COMP_WORDS[COMP_CWORD-1]};

  case $COMP_CWORD in
    0)#$COMP_CWORD从1开始,代表将要输入的位置,${COMP_WORDS[0]}为脚本名
#      echo "${COMP_WORDS[@]}" >> len.txt
      ;;
    1)
      COMPREPLY=( $(compgen -W "--m1" -- ${cur}) )
      ;;
    2)
      COMPREPLY=( $(compgen -W "--myexe --spec2017" -- ${cur}) )
      ;;
    3|*)
      cmd_f="${COMP_WORDS[1]##*-}_${COMP_WORDS[2]##*-}"
      cmd_f="${cmd_f%%=*}"
      #echo "${cmd_f}"
      #1代表被调用脚本从COMP_WORDS的第几个下标开始
      eval cmd_"${cmd_f}"
      ;;
  esac
}

complete -F cmd_hub ./run.sh