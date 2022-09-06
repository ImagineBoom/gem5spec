
#线程控制
#FLOODGATE=$1
#FLOODGATE=./run-p8-m1/running/run.fifo

add_thread(){
  if [[ ! -p ${FLOODGATE} ]];then
    mkfifo ${FLOODGATE}
    rm -rf runThreadPoolSize*.log
    touch "$(dirname ${FLOODGATE})"/runThreadPoolSize_0.log
  fi
  exec 6<>${FLOODGATE}
  echo >&6
  echo "add done"
  max_threads=$(find $(dirname ${FLOODGATE})/runThreadPoolSize_*.log -exec basename {} \;|grep -oP "\d+")
  ((max_threads+=1))
  echo "max_threads=${max_threads}"
  if [[ -p ${FLOODGATE} ]];then
    rename "s/runThreadPoolSize_\d+/runThreadPoolSize_${max_threads}/" "$(dirname ${FLOODGATE})"/runThreadPoolSize_*.log
  fi
}

add_thread_10(){
  origin_max_threads=$(find $(dirname ${FLOODGATE})/runThreadPoolSize_*.log -exec basename {} \;|grep -oP "\d+")
  for (( i=0;i<10;i++ )); do
    if [[ ! -p ${FLOODGATE} ]];then
      mkfifo ${FLOODGATE}
      rm -rf runThreadPoolSize*.log
      touch "$(dirname ${FLOODGATE})"/runThreadPoolSize_0.log
    fi
    exec 6<>${FLOODGATE}
    echo >&6
    max_threads=$(find $(dirname ${FLOODGATE})/runThreadPoolSize_*.log -exec basename {} \;|grep -oP "\d+")
    ((max_threads+=1))
    if [[ -p ${FLOODGATE} ]];then
      rename "s/runThreadPoolSize_\d+/runThreadPoolSize_${max_threads}/" "$(dirname ${FLOODGATE})"/runThreadPoolSize_*.log
    fi
  done
  echo "max_threads from ${origin_max_threads} + 10 to ${max_threads}"
}

reduce_thread(){
  max_threads=$(find $(dirname ${FLOODGATE})/runThreadPoolSize_*.log -exec basename {} \;|grep -oP "\d+")
  if [[ $max_threads -gt 2 ]]; then
    if [[ -p ${FLOODGATE} ]]; then
      exec 6<>${FLOODGATE}
      read -u6
      echo "reduce done"
      ((max_threads-=1))
      echo "max_threads=${max_threads}"
      rename "s/runThreadPoolSize_\d+/runThreadPoolSize_${max_threads}/" "$(dirname ${FLOODGATE})"/runThreadPoolSize_*.log
    fi
  else
    echo "min 1, not reduce!"
  fi
}

reduce_thread_10(){
  for i in `seq 10`; do
    reduce_thread &
  done
}

get_thread_pool_size(){
  max_threads=$(find $(dirname ${FLOODGATE})/runThreadPoolSize_*.log -exec basename {} \;|grep -oP "\d+")
  echo "max_threads=${max_threads}"
}

delete_thread_pool(){
#  rm -rf ${FLOODGATE}
#  rm -rf $(dirname ${FLOODGATE})/runThreadPoolSize_*.log
  rm -rf $(dirname ${FLOODGATE})
  echo "Now the thread pool has been deleted"
}

#Uncontrollable, not recommended
clear_redundant_thread_pool(){
  (cat <&6)&
  echo "kill the most recent pid in bg:"$!
  killall $!
  echo "clear redundant_thread_pool done"
}

set_thread_pool(){
  FLOODGATE=${1}
  with_add_thread=false
  with_add_thread_10=false
  with_reduce_thread=false
  with_reduce_thread_10=false
  with_del_thread_pool=false
  with_get_thread_pool_size=false
  if [[ ! -p ${FLOODGATE} ]]; then
    #最大线程数
    max_threads=5
    mkdir -p "$(dirname ${FLOODGATE})"
    #chmod 777 "$(dirname ${FLOODGATE})"
    mkfifo ${FLOODGATE}
    exec 6<>${FLOODGATE}
    touch "$(dirname ${FLOODGATE})"/runThreadPoolSize_${max_threads}.log
    #chmod 666 "$(dirname ${FLOODGATE})"/*
    for (( i=0;i<max_threads;i++ )); do
      echo >&6
    done
    echo "Create thread pool"
  else
    exec 6<>${FLOODGATE}
    # echo "Thread pool has been created"
  fi
}