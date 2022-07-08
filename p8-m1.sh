EXE=$1
PIPE_BEGIN=$2
PIPE_END=$3
SIG=$4

OUTPUT=$(basename "$EXE")
EXE=$(dirname "$EXE")"/${OUTPUT}"


######################################################
#pre
######################################################

LEN=1140 #scrollpv window length in pixels
WID=1825 #scrollpv window width in pixels

mkdir -p "${OUTPUT}"




######################################################
#Step1
######################################################
# ${insts}-->get insts to next steps
func_inst_count(){
  #echo $EXE
  /home/lizongping/dev/valgrind-install/bin/valgrind --tool=exp-bbv --instr-count-only=yes --bb-out-file=/dev/null "${EXE}" >"${OUTPUT}".inst.log 2>&1 ;\
  insts=$(grep -oP 'Total instructions: \d+' "${OUTPUT}".inst.log|grep -oP '\d+') ;\
  #printf "%-20s %22d \n" ${EXE} ${insts}>>../inst_count.log
  echo "${insts}"
  #mv "${OUTPUT}".inst.log "${OUTPUT}"
}

######################################################
#Step2
######################################################
func_itrace(){
  /home/lizongping/dev/valgrind-install/bin/valgrind --tool=itrace --trace-extent=all --trace-children=no \
  --binary-outfile="${OUTPUT}".vgi --g-num-insns-before-start=0 --num-insns-to-collect="${insts}" "${EXE}" #>>${OUTPUT}_trace.log 2>&1 ;
}

######################################################
#Step3
######################################################
func_qtrace(){
  /home/lizongping/dev/valgrind-install/bin/vgi2qt -f "${OUTPUT}".vgi -o "${OUTPUT}".qt #>>${EXE}_trace.log 2>&1
}

######################################################
#Step4
######################################################
# ${OUTPUT}.qt ${insts} ${insts} 1 ${OUTPUT} --> qt  workload  cpi_interval  reset_stats  run_name
#-p 1   -->
#         = 1, scroll by architected instruction id
#         = 2, scroll by internal instruction id
#         = 3, scroll by cycle count
#generate .pipe .config .results
func_run_timer(){
  /opt/ibm/sim_ppc/sim_p8/bin/run_timer "${OUTPUT}".qt "${insts}" "${insts}" 1 "${OUTPUT}" -p 1 -b "${PIPE_BEGIN}" -e "${PIPE_END}" -maximize # >>${EXE}_trace.log 2>&1 ; \
}

######################################################
#Step5
######################################################
func_m1_pipeview(){
  /opt/ibm/sim_ppc/bin/scrollpv -pipe "${OUTPUT}".pipe -config "${OUTPUT}".config -wid "$WID" -len "$LEN" #-out_file ${EXE}.txt -overwrite #>>${EXE}_trace.log 2>&1
}

#all
func_m1(){
  func_inst_count
  func_itrace
  func_qtrace
  func_run_timer
  func_m1_pipeview
  mv "${OUTPUT}".* "${OUTPUT}"
}

#EXE=test_power8_gem5_pipeline_v1
#func_m1
#EXE=test_power8_pipeline_frondend_bound_v1
#func_m1
#EXE=test_power8_pipeline_loop_nop_v1
#func_m1
#EXE=test_power8_pipeline_loop_only_v1
#func_m1
#EXE=test_power8_pipeline_loop_cmp_v1
#func_m1
#EXE=test_power8_pipeline_loop_nondep_v1
#func_m1


#RUN
case "${SIG}" in
  0)#all
    func_m1
    ;;
  1)#itrace
    func_inst_count
    func_itrace
    ;;
  2)#qtrace
    func_qtrace
    ;;
  3)#m1
    func_inst_count
    func_run_timer
    ;;
  4)#pipe view
    func_m1_pipeview
    ;;
  *)#all
    func_m1
    ;;
esac





