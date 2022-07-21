#!/bin/bash
SIMPOINT_EXE=$1
VALGRIND_EXE=$2
EXECUTABLE=$3
FILE=$4
ARGS=$5
CPI_log_PATH=./CPI_result
M1_log_PATH=./M1_result
Valgrind_Simpts_log_PATH=./Valgrind_Simpoint_result
NUM_INSNS_BEFORE_START=0
NUM_INSNS_TO_COLLECT=1500m

source ../Set_IntervalSize.sh

if [[ ! -f ${FILE}.vgi ]];then
	echo ---------------------m1 handle ${FILE} beginning ---------------------->>${FILE}_trace.log
	${VALGRIND_EXE} --tool=itrace --trace-extent=all --trace-children=no --binary-outfile=${FILE}.vgi --g-num-insns-before-start=${NUM_INSNS_BEFORE_START} --num-insns-to-collect=${NUM_INSNS_TO_COLLECT} ./${EXECUTABLE} ${ARGS} >>${FILE}_trace.log 2>&1
	echo itrace-ok
else
	echo ${FILE}.vgi already exist	
fi

if [[ -d "$CPI_log_PATH"||"$M1_log_PATH"||"$Valgrind_Simpts_log_PATH" ]];then 
	rm -rf ./CPI_result ./M1_result ./Valgrind_Simpoint_result
fi

mkdir -p M1_result
mkdir -p Valgrind_Simpoint_result
mkdir -p CPI_result

for ((i=0;i<${#interval_size[@]};i++)) do
{
	echo ---------------------simpt handle ${FILE}_${interval_size[i]} beginning ---------------------->>${FILE}_${interval_size[i]}_trace.log
	${VALGRIND_EXE} --tool=exp-bbv --interval-size=${interval_size[i]} --bb-out-file=${FILE}_${interval_size[i]}.bb.out ./${EXECUTABLE} ${ARGS} >>${FILE}_${interval_size[i]}_trace.log 2>&1 
	MAXK=`wc -l ${FILE}_${interval_size[i]}.bb.out | awk 'END{print sqrt($1)}'` 
	${SIMPOINT_EXE} -loadFVFile ${FILE}_${interval_size[i]}.bb.out -maxK ${MAXK} -saveSimpoints ./${FILE}_${interval_size[i]}.simpts -saveSimpointWeights ./${FILE}_${interval_size[i]}.weights >>${FILE}_${interval_size[i]}_trace.log 2>&1 
	paste ${FILE}_${interval_size[i]}.simpts ${FILE}_${interval_size[i]}.weights | awk '{printf "%-20d %-15.5f\n",$1,$3}' 1>${FILE}_${interval_size[i]}.merge 
	sort ${FILE}_${interval_size[i]}.merge -n -k 1 -o ${FILE}_${interval_size[i]}.merge 2>>${FILE}_${interval_size[i]}_trace.log
	echo ---------------------simpt handle ${FILE}_${interval_size[i]} Finished ---------------------->>${FILE}_${interval_size[i]}_trace.log
	grep -niE "FAIL|ERR|FAULT" ${FILE}_${interval_size[i]}_trace.log >> ${FILE}_${interval_size[i]}_trace_err.log ; true
			
			Simpts_Array=(`awk '{print $(NF-1)}' ./${FILE}_${interval_size[i]}.merge`)
			for (( j=0;j<${#Simpts_Array[@]};j++)) 
			do
				{
				Simpts=${Simpts_Array[j]}
				Interval_size=${interval_size[i]}
				make qtrace JUMP_NUM=$[Simpts*Interval_size] CONVERT_NUM_Vgi_RECS=${interval_size[i]} qtFILE=${Simpts_Array[j]}_${interval_size[i]}_${FILE} 
				make m1 NUM_INST=${interval_size[i]} CPI_INTERVAL=${interval_size[i]} qtFILE=${Simpts_Array[j]}_${interval_size[i]}_${FILE} 
				CPI=`grep 'CMPL: CPI--------------------------------------- .* inst.*' ./${Simpts_Array[j]}_${interval_size[i]}_${FILE}.results |awk '{print $3}'`
				Weight=`grep -w "${Simpts_Array[j]}" ./${FILE}_${interval_size[i]}.merge | awk '{print $2}'`
				echo ${Simpts_Array[j]} $CPI >> ./CPI_result/${interval_size[i]}_Calculate_CPI.log
				echo ${Simpts_Array[j]} $Weight $CPI | awk '{print($1" "$2*$3)}' >> ./CPI_result/${interval_size[i]}_Calculate_WeightedCPI.log
				rm ${Simpts_Array[j]}_${interval_size[i]}_${FILE}.pipe ${Simpts_Array[j]}_${interval_size[i]}_${FILE}.qt ${Simpts_Array[j]}_${interval_size[i]}_${FILE}.config;		
				mv ${Simpts_Array[j]}_${interval_size[i]}_${FILE}.* M1_result
				mv ${Simpts_Array[j]}_${interval_size[i]}_${FILE}_trace.* M1_result
				}&
			done
			
			LineNumof_merge=`awk 'END{print NR}' ./${FILE}_${interval_size[i]}.merge`
			while true
			do 
				LineNumof_Calculate_WeightedCPI_log=`awk 'END{print NR}' ./CPI_result/${interval_size[i]}_Calculate_WeightedCPI.log`
				if [[ $LineNumof_Calculate_WeightedCPI_log == $LineNumof_merge ]];then  
					Sum_WeightedCPI=`awk '{s += $2} END {print s}' ./CPI_result/${interval_size[i]}_Calculate_WeightedCPI.log`
					sort -n -k 1 ./CPI_result/${interval_size[i]}_Calculate_WeightedCPI.log >> ./CPI_result/${interval_size[i]}_Calculate_WeightedCPI.sort
					sort -n -k 1 ./CPI_result/${interval_size[i]}_Calculate_CPI.log >> ./CPI_result/${interval_size[i]}_Calculate_CPI.sort
					paste ${FILE}_${interval_size[i]}.merge ./CPI_result/${interval_size[i]}_Calculate_CPI.sort ./CPI_result/${interval_size[i]}_Calculate_WeightedCPI.sort | awk 'BEGIN {print "simpts","Weights","CPI","WeightedCPI"} {print $1,$2,$4,$6}' |  column -t > ./CPI_result/${interval_size[i]}_CPI_result.merge 
					echo ${interval_size[i]}_${FILE}_SumWeightCPI:"$Sum_WeightedCPI" >> ./CPI_result/${interval_size[i]}_CPI_result.merge
					mv ${FILE}_${interval_size[i]}.* Valgrind_Simpoint_result
					mv ${FILE}_${interval_size[i]}_trace.* Valgrind_Simpoint_result
					mv ${FILE}_${interval_size[i]}_trace_err.* Valgrind_Simpoint_result
					echo ${interval_size[i]}_${FILE}:"$Sum_WeightedCPI" >> ./CPI_result/CPI_result.log
					break
				fi
				sleep 10s
			done			
}&				
done

Interval_Number=${#interval_size[@]}
while true
do 
	LineNumof_CPI_result_log=`awk 'END{print NR}' ./CPI_result/CPI_result.log`
	if [[ $Interval_Number == $LineNumof_CPI_result_log ]];then  
		sort -n -r -k 2 -t : ./CPI_result/CPI_result.log | awk 'END{printf "The best CPI is " $0}' >> ./CPI_result/CPI_result.log
		break
	fi
	sleep 5s
done



	
	
	
	
	
