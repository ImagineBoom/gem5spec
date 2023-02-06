
#任务控制
#FLOODGATE=$1
#FLOODGATE=./run-p8-m1/running/run.fifo

func_add_job(){
  if [[ ! -p ${FLOODGATE} ]];then
    mkdir -p "$(dirname ${FLOODGATE})"
    mkfifo ${FLOODGATE}
    rm -rf runJobPoolSize*.log
    touch "$(dirname ${FLOODGATE})"/runJobPoolSize_0.log
  fi
  exec 6<>${FLOODGATE}
  echo >&6
  origin_max_jobs=$(find $(dirname ${FLOODGATE})/runJobPoolSize_*.log -exec basename {} \;|grep -oP "\d+")
  (( max_jobs=origin_max_jobs+1 ))
  echo "max_jobs from ${origin_max_jobs} to ${max_jobs} (+1)"
  if [[ -p ${FLOODGATE} ]];then
    mv "$(dirname ${FLOODGATE})"/runJobPoolSize_*.log "$(dirname ${FLOODGATE})"/runJobPoolSize_${max_jobs}.log
  fi
}

func_set_job_n_default(){
  add_num=${1}
  if [[ ! -p ${FLOODGATE} ]]; then
    mkdir -p "$(dirname ${FLOODGATE})"
    mkfifo ${FLOODGATE}
    rm -rf runJobPoolSize*.log
    touch "$(dirname "${FLOODGATE}")"/runJobPoolSize_0.log
  fi
  origin_max_jobs=$(find $(dirname ${FLOODGATE})/runJobPoolSize_*.log -exec basename {} \;|grep -oP "\d+")
  max_jobs=$(find $(dirname ${FLOODGATE})/runJobPoolSize_*.log -exec basename {} \;|grep -oP "\d+")
  for index in `seq $add_num`; do
    exec 6<>${FLOODGATE}
    echo >&6
    # echo "add done"
    ((max_jobs+=1))
    # echo "max_jobs=${max_jobs}"
  done
  if [[ -p ${FLOODGATE} ]];then
    mv "$(dirname ${FLOODGATE})"/runJobPoolSize_*.log "$(dirname ${FLOODGATE})"/runJobPoolSize_${max_jobs}.log
  fi
  echo "max_jobs is set to ${max_jobs}"
}

func_set_job_n_quiet(){
  add_num=${1}
  if [[ ! -p ${FLOODGATE} ]]; then
    mkdir -p "$(dirname ${FLOODGATE})"
    mkfifo ${FLOODGATE}
    rm -rf runJobPoolSize*.log
    touch "$(dirname ${FLOODGATE})"/runJobPoolSize_0.log
  fi
  origin_max_jobs=$(find $(dirname ${FLOODGATE})/runJobPoolSize_*.log -exec basename {} \;|grep -oP "\d+")
  max_jobs=$(find $(dirname ${FLOODGATE})/runJobPoolSize_*.log -exec basename {} \;|grep -oP "\d+")
  for index in `seq $add_num`; do
    exec 6<>${FLOODGATE}
    echo >&6
    # echo "add done"
    ((max_jobs+=1))
    # echo "max_jobs=${max_jobs}"
  done
  if [[ -p ${FLOODGATE} ]];then
    mv "$(dirname ${FLOODGATE})"/runJobPoolSize_*.log "$(dirname ${FLOODGATE})"/runJobPoolSize_${max_jobs}.log
  fi
}

func_add_job_n(){
  add_num=${1}
  if [[ ! -p ${FLOODGATE} ]]; then
    mkdir -p "$(dirname ${FLOODGATE})"
    mkfifo ${FLOODGATE}
    rm -rf runJobPoolSize*.log
    touch "$(dirname ${FLOODGATE})"/runJobPoolSize_0.log
  fi
  origin_max_jobs=$(find $(dirname ${FLOODGATE})/runJobPoolSize_*.log -exec basename {} \;|grep -oP "\d+")
  max_jobs=$(find $(dirname ${FLOODGATE})/runJobPoolSize_*.log -exec basename {} \;|grep -oP "\d+")
  for index in `seq $add_num`; do
    exec 6<>${FLOODGATE}
    echo >&6
    # echo "add done"
    ((max_jobs+=1))
    # echo "max_jobs=${max_jobs}"
  done
  if [[ -p ${FLOODGATE} ]];then
    mv "$(dirname ${FLOODGATE})"/runJobPoolSize_*.log "$(dirname ${FLOODGATE})"/runJobPoolSize_${max_jobs}.log
  fi
  echo "max_jobs from ${origin_max_jobs} to ${max_jobs} (+${add_num}"
}

func_add_job_10(){
  if [[ ! -p ${FLOODGATE} ]];then
    mkdir -p "$(dirname ${FLOODGATE})"
    mkfifo ${FLOODGATE}
    rm -rf runJobPoolSize*.log
    touch "$(dirname ${FLOODGATE})"/runJobPoolSize_0.log
  fi
  origin_max_jobs=$(find $(dirname ${FLOODGATE})/runJobPoolSize_*.log -exec basename {} \;|grep -oP "\d+")
  for (( i=0;i<10;i++ )); do
    if [[ ! -p ${FLOODGATE} ]];then
      mkdir -p "$(dirname ${FLOODGATE})"
      mkfifo ${FLOODGATE}
      rm -rf runJobPoolSize*.log
      touch "$(dirname ${FLOODGATE})"/runJobPoolSize_0.log
    fi
    exec 6<>${FLOODGATE}
    echo >&6
    max_jobs=$(find $(dirname ${FLOODGATE})/runJobPoolSize_*.log -exec basename {} \;|grep -oP "\d+")
    ((max_jobs+=1))
    if [[ -p ${FLOODGATE} ]];then
      mv "$(dirname ${FLOODGATE})"/runJobPoolSize_*.log "$(dirname ${FLOODGATE})"/runJobPoolSize_${max_jobs}.log
    fi
  done
  echo "max_jobs from ${origin_max_jobs} to ${max_jobs} (+10)"
}

func_reduce_job(){
  mkdir -p "$(dirname ${FLOODGATE})"
  {
    origin_max_jobs=$(find $(dirname ${FLOODGATE})/runJobPoolSize_*.log -exec basename {} \;|grep -oP "\d+")
    if [[ $origin_max_jobs -gt 1 ]]; then
      if [[ -p ${FLOODGATE} ]]; then
        exec 6<>${FLOODGATE}
        read -u6
        origin_max_jobs=$(find $(dirname ${FLOODGATE})/runJobPoolSize_*.log -exec basename {} \;|grep -oP "\d+")
        if [[ $origin_max_jobs -gt 1 ]]; then
          (( max_jobs = origin_max_jobs-1 ))
        else
          echo "reduce done, max_jobs=${origin_max_jobs}"
          exit 0
        fi
        echo "max_jobs from ${origin_max_jobs} to ${max_jobs} (-1, min=1)"
        mv "$(dirname ${FLOODGATE})"/runJobPoolSize_*.log "$(dirname ${FLOODGATE})"/runJobPoolSize_${max_jobs}.log
      fi
    else
      echo "min=1, not reduce!"
    fi
  }&
}

func_reduce_job_10(){
  origin_max_jobs=$(find $(dirname ${FLOODGATE})/runJobPoolSize_*.log -exec basename {} \;|grep -oP "\d+")
  reduce_num=0
  if [[ $origin_max_jobs -gt 10 ]]; then
    reduce_num=10
  elif [[ $origin_max_jobs -gt 1 && $origin_max_jobs -le 10 ]]; then
    (( reduce_num=origin_max_jobs-1 ))
  else
    echo "min=1, not reduce"
    exit 1
  fi
  {
    for i in `seq ${reduce_num}`; do
    {
      sleep 1s
      if [[ -p ${FLOODGATE} ]]; then
        exec 6<>${FLOODGATE}
        read -u6
        # echo "reduce ${i}"
      fi
    }&
    done
    wait
    origin_max_jobs=$(find $(dirname ${FLOODGATE})/runJobPoolSize_*.log -exec basename {} \;|grep -oP "\d+")
    if [[ $origin_max_jobs -gt 10 ]]; then
      reduce_num=10
    elif [[ $origin_max_jobs -gt 1 && $origin_max_jobs -le 10 ]]; then
      (( reduce_num=origin_max_jobs-1 ))
    else
      echo "reduce done, max_jobs=${origin_max_jobs}"
      exit 0
    fi
    (( max_jobs=origin_max_jobs-reduce_num ))
    echo "reduce done, max_jobs from ${origin_max_jobs} to ${max_jobs} (-${reduce_num}, min=1)"
    mv "$(dirname ${FLOODGATE})"/runJobPoolSize_*.log "$(dirname ${FLOODGATE})"/runJobPoolSize_${max_jobs}.log
  }&
}

func_get_job_pool_size(){
  max_jobs=$(find $(dirname ${FLOODGATE})/runJobPoolSize_*.log -exec basename {} \;|grep -oP "\d+")
  echo "max_jobs=${max_jobs}"
}

func_delete_job_pool(){
#  rm -rf ${FLOODGATE}
#  rm -rf $(dirname ${FLOODGATE})/runJobPoolSize_*.log
  rm -rf $(dirname ${FLOODGATE})
  echo "Now the job pool has been deleted"
}

#Uncontrollable, not recommended
func_clear_redundant_job_pool(){
  (cat <&6)&
  echo "kill the most recent pid in bg:"$!
  killall $!
  echo "clear redundant_job_pool done"
}

func_set_job_pool(){
  FLOODGATE=${1}
  with_add_job=false
  with_add_job_10=false
  with_reduce_job=false
  with_reduce_job_10=false
  with_del_job_pool=false
  with_get_job_pool_size=false
  if [[ ! -p ${FLOODGATE} ]]; then
    #最大线程数
    mkdir -p "$(dirname ${FLOODGATE})"
    #chmod 777 "$(dirname ${FLOODGATE})"
    mkfifo ${FLOODGATE}
    exec 6<>${FLOODGATE}
    touch "$(dirname ${FLOODGATE})"/runJobPoolSize_${max_jobs}.log
    #chmod 666 "$(dirname ${FLOODGATE})"/*
    # echo "Create job pool"
  else
    exec 6<>${FLOODGATE}
    # echo "Job pool has been created"
  fi
}