#线程控制
FLOODGATE=/opt/run-p8-m1/running/run.fifo
#FLOODGATE=./run-p8-m1/running/run.fifo
#最大线程数
max_threads=20

set_thread_pool(){
  if [[ ! -e ${FLOODGATE} ]];then
    sudo mkdir -p "$(dirname ${FLOODGATE})"
    sudo mkfifo ${FLOODGATE}
    sudo chmod 777 ${FLOODGATE}
    exec 6<>${FLOODGATE}
    for(( i=0;i<max_threads;i++ )); do
      echo "$i" >&6
    done
  else
    exec 6<>${FLOODGATE}
  fi
  sudo touch "$(dirname ${FLOODGATE})"/runThreadPoolSize_${max_threads}.log
  sudo chmod 777 "$(dirname ${FLOODGATE})"/runThreadPoolSize_${max_threads}.log
}

add_thread(){
  exec 6<>${FLOODGATE}
  echo "add_thread" >&6
  echo "add done"
  max_threads=$(find $(dirname ${FLOODGATE})/runThreadPoolSize_*.log -exec basename {} \;|grep -oP "\d+")
  ((max_threads+=1))
  echo "max_threads=${max_threads}"
  if [[ -e ${FLOODGATE} ]];then
    sudo rename "s/runThreadPoolSize_\d+/runThreadPoolSize_${max_threads}/" "$(dirname ${FLOODGATE})"/runThreadPoolSize_*.log
  fi
}

add_thread_10(){
  for (( i=0;i<10;i++ )); do
    add_thread
  done
}

reduce_thread(){
  exec 6<>${FLOODGATE}
  read -u6
  echo "reduce done"
  max_threads=$(find $(dirname ${FLOODGATE})/runThreadPoolSize_*.log -exec basename {} \;|grep -oP "\d+")
  ((max_threads-=1))
  echo "max_threads=${max_threads}"
  if [[ -e ${FLOODGATE} ]];then
    sudo rename "s/runThreadPoolSize_\d+/runThreadPoolSize_${max_threads}/" "$(dirname ${FLOODGATE})"/runThreadPoolSize_*.log
  fi
}

reduce_thread_10(){
  for i in `seq 10`; do
    reduce_thread
  done
}

get_thread_pool_size(){
  max_threads=$(find $(dirname ${FLOODGATE})/runThreadPoolSize_*.log -exec basename {} \;|grep -oP "\d+")
  echo "max_threads=${max_threads}"
}

delete_thread_pool(){
  sudo rm -f ${FLOODGATE}
  sudo rm -f $(dirname ${FLOODGATE})/runThreadPoolSize_*.log
}

#Uncontrollable, not recommended
clear_redundant_thread_pool(){
  exec 6<>${FLOODGATE}
  (cat <&6)&
  echo "kill the most recent pid in bg:"$!
  killall $!
  echo "clear redundant_thread_pool done"
}
