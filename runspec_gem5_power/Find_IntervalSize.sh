#!/bin/bash
SIMPOINT_EXE=$1
VALGRIND_EXE=$2
EXECUTABLE=$3
FILE=$4
ARGS=$5
MERGE_FILE_PATH=$6
BACKUP_PATH=$7
CPI_log_PATH=./CPI_result
M1_log_PATH=./M1_result
Valgrind_Simpts_log_PATH=./Valgrind_Simpoint_result
NUM_INSNS_BEFORE_START=0
NUM_INSNS_TO_COLLECT=1500m
Sum_WeightedCPI=0

source ../Set_IntervalSize.sh
source ../../scripts/thread_control.sh
set_thread_pool "${8}"
#echo >&6

#if [[ ! -f ${FILE}.vgi ]];then
#  echo ---------------------m1 handle ${FILE} beginning ---------------------->>${FILE}_trace.log
#  ${VALGRIND_EXE} --tool=itrace --trace-extent=all --trace-children=no --binary-outfile=${FILE}.vgi --g-num-insns-before-start=${NUM_INSNS_BEFORE_START} --num-insns-to-collect=${NUM_INSNS_TO_COLLECT} ./${EXECUTABLE} ${ARGS} >>${FILE}_trace.log 2>&1
#  echo itrace-ok
#else
#  echo ${FILE}.vgi already exist
#fi

#if [[ -d "$CPI_log_PATH"||"$M1_log_PATH"||"$Valgrind_Simpts_log_PATH" ]]; then
#  rm -rf ./CPI_result ./M1_result ./Valgrind_Simpoint_result
#fi

#rm -rf M1_result Valgrind_Simpoint_result CPI_result *.qt *.log *.results *.pipe *.config *.dir
mkdir -p M1_result
mkdir -p Valgrind_Simpoint_result
mkdir -p CPI_result
mkdir -p pipe_result
for ((i=0;i<${#interval_size[@]};i++)) do
  {
    Simpts_Array=(`awk '{print $(NF-1)}' ${MERGE_FILE_PATH}`)
    Weight_Array=(`awk '{print $(NF)}' ${MERGE_FILE_PATH}`)
    Interval_size=${interval_size[i]}
    for (( j=0;j<${#Simpts_Array[@]};j++)) do
      read -u6
      {
        Simpts=${Simpts_Array[j]}
        Weight=${Weight_Array[j]}
        had_result=false
        if [[ -e ../../each_bm_cpt_m1.csv ]]; then
          echo "existing, ../../each_bm_cpt_m1.csv"
          array=(`grep -oP "(.*${FILE}.*),(${Simpts}),(.*${Weight}.*),(.*\d+\.*\d*),(.*)" ../../each_bm_cpt_m1.csv|awk -F ',' '{print $1,$2,$3,$4,$5}'`)
          echo ${array[@]}
          if [[ ${#array[@]} == 4 || ${#array[@]} == 5 ]]; then
            echo "existing,FILE=${FILE},Simpts=${Simpts},Weight=${Weight},,"${array[1]}"_${Interval_size}_"${array[0]}".results"|tee -a gen_m1_results.csv
            had_result=true
          elif [ ${#array[@]} -gt 0 ]; then
            echo "exception,"${array[0]}","${array[1]}"_${Interval_size}_"${array[0]}".results"|tee -a gen_m1_results.csv
            had_result=false
          else
            echo "not existing,FILE=${FILE},Simpts=${Simpts},Weight=${Weight},${Simpts}_${Interval_size}_${FILE}.results"|tee -a gen_m1_results.csv
            had_result=false
          fi
        fi
        if [[ $had_result == false ]]; then
          make qtrace JUMP_NUM=$[Simpts*Interval_size] CONVERT_NUM_Vgi_RECS=${Interval_size} qtFILE=${Simpts}_${Interval_size}_${FILE}
          echo "Simpts=${Simpts}  Weight=${Weight}  FILE=${FILE}"
          b=1;e=5000
          qt_records=0
          qt_records=$(grep -oP "Created \d+ qt records" ${Simpts}_${Interval_size}_${FILE}_trace.log |grep -oP "\d+")
          if [[ $qt_records == 5000000 ]]; then
            make m1 NUM_INST=${Interval_size} CPI_INTERVAL=${Interval_size} qtFILE=${Simpts}_${Interval_size}_${FILE} SCROLL_PIPE=1 SCROLL_BEGIN=${b} SCROLL_END=${e}
            make m1_pipeview pipeFILE=${Simpts}_${Interval_size}_${FILE} pipeARGS="-out_file ${b}_${e}_${Simpts}_${Interval_size}_${FILE}.txt  -overwrite "
            CPI=`grep 'CMPL: CPI--------------------------------------- .* inst.*' ./${Simpts}_${Interval_size}_${FILE}.results |awk '{print $3}'`
            echo ${Simpts} $Weight $CPI | awk '{print($1" "$2" "$3" "$2*$3)}' >> ./CPI_result/${Interval_size}_Calculate_WeightedCPI.log
            # rm -rf ${Simpts}_${Interval_size}_${FILE}.qt ${Simpts}_${Interval_size}_${FILE}.pipe
          fi
          mv ${Simpts}_${Interval_size}_${FILE}* M1_result 2>/dev/null
          mv *${Simpts}_${Interval_size}_${FILE}.txt pipe_result 2>/dev/null
          cp -r ./M1_result/${Simpts}_${Interval_size}_${FILE}.results ${BACKUP_PATH} 2>/dev/null
          cp -r -f ./CPI_result/${Interval_size}_Calculate_WeightedCPI.log ${BACKUP_PATH} 2>/dev/null
        else
          :
        fi
        echo >&6
      }&
    done
    wait
    Sum_WeightedCPI=`awk '{s += $4} END {print s}' ./CPI_result/${Interval_size}_Calculate_WeightedCPI.log`
    sort -r -n -k 2 ./CPI_result/${Interval_size}_Calculate_WeightedCPI.log | awk 'BEGIN {OFS = ",";print "simpts","Weights","CPI","WeightedCPI"} {print $1,$2,$3,$4}' |  column -t > ./CPI_result/${Interval_size}_CPI_result.merge
    echo ",${FILE} interval size: ${Interval_size}, sum weighted CPI:, $Sum_WeightedCPI" >> ./CPI_result/${Interval_size}_CPI_result.merge
    echo ${Interval_size}_${FILE}:"$Sum_WeightedCPI" >> ./CPI_result/${FILE}_CPI_result_${Sum_WeightedCPI}.log
  }
done
Interval_Number=${#interval_size[@]}
wait
sort -n -r -k 2 -t : ./CPI_result/${FILE}_CPI_result_${Sum_WeightedCPI}.log | awk 'END{printf "The best CPI is " $0}' >> ./CPI_result/${FILE}_CPI_result_${Sum_WeightedCPI}.log
