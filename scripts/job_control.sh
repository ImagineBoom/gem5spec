
#线程控制
#FLOODGATE=$1
#FLOODGATE=./run-p8-m1/running/run.fifo

func_add_job(){
  if [[ ! -p ${FLOODGATE} ]];then
    mkfifo ${FLOODGATE}
    rm -rf runJobPoolSize*.log
    touch "$(dirname ${FLOODGATE})"/runJobPoolSize_0.log
  fi
  exec 6<>${FLOODGATE}
  echo >&6
  echo "add done"
  max_jobs=$(find $(dirname ${FLOODGATE})/runJobPoolSize_*.log -exec basename {} \;|grep -oP "\d+")
  ((max_jobs+=1))
  echo "max_jobs=${max_jobs}"
  if [[ -p ${FLOODGATE} ]];then
    rename "s/runJobPoolSize_\d+/runJobPoolSize_${max_jobs}/" "$(dirname ${FLOODGATE})"/runJobPoolSize_*.log
  fi
}

func_add_job_n(){
  add_num=${1}
  origin_max_jobs=$(find $(dirname ${FLOODGATE})/runJobPoolSize_*.log -exec basename {} \;|grep -oP "\d+")
  if [[ ! -p ${FLOODGATE} ]];then
    mkfifo ${FLOODGATE}
    rm -rf runJobPoolSize*.log
    touch "$(dirname ${FLOODGATE})"/runJobPoolSize_0.log
  fi
  max_jobs=$(find $(dirname ${FLOODGATE})/runJobPoolSize_*.log -exec basename {} \;|grep -oP "\d+")
  for index in `seq $add_num`; do
    exec 6<>${FLOODGATE}
    echo >&6
    # echo "add done"
    ((max_jobs+=1))
    # echo "max_jobs=${max_jobs}"
  done
  if [[ -p ${FLOODGATE} ]];then
    rename "s/runJobPoolSize_\d+/runJobPoolSize_${max_jobs}/" "$(dirname ${FLOODGATE})"/runJobPoolSize_*.log
  fi
  echo "max_jobs from ${origin_max_jobs} to ${max_jobs} (+${add_num}, default=5)"
}

func_add_job_10(){
  origin_max_jobs=$(find $(dirname ${FLOODGATE})/runJobPoolSize_*.log -exec basename {} \;|grep -oP "\d+")
  for (( i=0;i<10;i++ )); do
    if [[ ! -p ${FLOODGATE} ]];then
      mkfifo ${FLOODGATE}
      rm -rf runJobPoolSize*.log
      touch "$(dirname ${FLOODGATE})"/runJobPoolSize_0.log
    fi
    exec 6<>${FLOODGATE}
    echo >&6
    max_jobs=$(find $(dirname ${FLOODGATE})/runJobPoolSize_*.log -exec basename {} \;|grep -oP "\d+")
    ((max_jobs+=1))
    if [[ -p ${FLOODGATE} ]];then
      rename "s/runJobPoolSize_\d+/runJobPoolSize_${max_jobs}/" "$(dirname ${FLOODGATE})"/runJobPoolSize_*.log
    fi
  done
  echo "max_jobs from ${origin_max_jobs} to ${max_jobs} (+10)"
}

func_reduce_job(){
  max_jobs=$(find $(dirname ${FLOODGATE})/runJobPoolSize_*.log -exec basename {} \;|grep -oP "\d+")
  if [[ $max_jobs -gt 2 ]]; then
    if [[ -p ${FLOODGATE} ]]; then
      exec 6<>${FLOODGATE}
      read -u6
      echo "reduce done"
      ((max_jobs-=1))
      echo "max_jobs=${max_jobs}"
      rename "s/runJobPoolSize_\d+/runJobPoolSize_${max_jobs}/" "$(dirname ${FLOODGATE})"/runJobPoolSize_*.log
    fi
  else
    echo "min 1, not reduce!"
  fi
}

func_reduce_job_10(){
  for i in `seq 10`; do
    reduce_job &
  done
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
    max_jobs=5
    mkdir -p "$(dirname ${FLOODGATE})"
    #chmod 777 "$(dirname ${FLOODGATE})"
    mkfifo ${FLOODGATE}
    exec 6<>${FLOODGATE}
    touch "$(dirname ${FLOODGATE})"/runJobPoolSize_${max_jobs}.log
    #chmod 666 "$(dirname ${FLOODGATE})"/*
    for (( i=0;i<max_jobs;i++ )); do
      echo >&6
    done
    # echo "Create job pool"
  else
    exec 6<>${FLOODGATE}
    # echo "Job pool has been created"
  fi
}