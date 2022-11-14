######################################################
#args
######################################################

EXE=$1
SIG=$2
#itrace
NUM_INSNS_TO_COLLECT=$3

#vgi2qt
#if CONVERT_NUM_Vgi_RECS ==0 -> convert all itrace
JUMP_NUM=$4
CONVERT_NUM_Vgi_RECS=$5

#Runtimer
NUM_INST=$6
CPI_INTERVAL=$7
RESET_STATS=$8
SCROLL_PIPE=$9
SCROLL_BEGIN="${10}"
SCROLL_END="${11}"

GEN_TXT="${12}"
#echo ${@}

#输出文件位置p8-m1.sh同级目录下 /OUTPUT/*
OUTPUT=$(basename "$EXE")
#当前脚本同目录下的
WORK_DIR=$(cd "$(dirname "${0}")" && pwd )/${OUTPUT}

#给当前目录的文件加上./
EXE=$(cd $(dirname "${EXE}") && pwd )/$(basename "${EXE}")

if [[ ! -e "${WORK_DIR}" ]];then
  mkdir -p "${WORK_DIR}"
  #cp -r "${EXE}" "${WORK_DIR}/"
  cd "${WORK_DIR}" || exit
else
  #cp -r "${EXE}" "${WORK_DIR}/"
  cd "${WORK_DIR}" || exit
fi
######################################################
#pre
######################################################

LEN=1140 #scrollpv window length in pixels
WID=1825 #scrollpv window width in pixels

# func pre(){
#}

######################################################
#Step1
######################################################
# ${insts}-->get insts to next steps
insts=0
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
  if [[ ! -e "${EXE}" ]];then
    echo "not find ${EXE}">&2
  fi
  /home/lizongping/dev/valgrind-install/bin/valgrind \
  --tool=itrace --trace-extent=all --trace-children=no \
  --binary-outfile="${OUTPUT}".vgi \
  --g-num-insns-before-start=0 \
  --num-insns-to-collect="${NUM_INSNS_TO_COLLECT}" \
  "${EXE}" #>>${OUTPUT}_trace.log 2>&1 ;
}

######################################################
#Step3
######################################################
func_qtrace(){
  if [[ ! -e "${OUTPUT}".vgi ]];then
    echo "not find ${WORK_DIR}/${OUTPUT}.vgi">&2
  fi
  /home/lizongping/dev/valgrind-install/bin/vgi2qt \
  -f "${OUTPUT}".vgi \
  -o "${OUTPUT}".qt \
  -j "${JUMP_NUM}" \
  -c "${CONVERT_NUM_Vgi_RECS}" #>>${EXE}_trace.log 2>&1
}

######################################################
#Step4
######################################################
# ${OUTPUT}.qt ${insts} ${insts} 1 ${OUTPUT} --> workload  insts cpi_interval  reset_stats  run_name
#-p 1   -->
#         = 1, scroll by architected instruction id
#         = 2, scroll by internal instruction id
#         = 3, scroll by cycle count
#generate .pipe .config .results
func_run_timer(){
  if [[ ! -e "${OUTPUT}".qt ]];then
    echo "not find ${WORK_DIR}/${OUTPUT}.qt">&2
  fi
  /opt/ibm/sim_ppc/sim_p8/bin/run_timer \
  "${OUTPUT}".qt \
  "${NUM_INST}" \
  "${CPI_INTERVAL}" \
  "${RESET_STATS}" \
  "${OUTPUT}" \
  -p "${SCROLL_PIPE}" \
  -b "${SCROLL_BEGIN}" \
  -e "${SCROLL_END}" \
  -maximize # >>${EXE}_trace.log 2>&1 ; \
}

######################################################
#Step5
######################################################
func_m1_pipeview(){
  if [[ ! -e "${OUTPUT}".pipe ]];then
    echo "not find ${WORK_DIR}/${OUTPUT}.pipe &config">&2
  fi
  /opt/ibm/sim_ppc/bin/scrollpv \
  -pipe "${OUTPUT}".pipe \
  -config "${OUTPUT}".config \
  -wid "$WID" \
  -len "$LEN" #-out_file ${EXE}.txt -overwrite #>>${EXE}_trace.log 2>&1
}

func_m1_pipeview_gen_txt(){
  if [[ ! -e "${OUTPUT}".pipe ]];then
    echo "not find ${WORK_DIR}/${OUTPUT}.pipe &config">&2
  fi
  /opt/ibm/sim_ppc/bin/scrollpv \
  -pipe "${OUTPUT}".pipe \
  -config "${OUTPUT}".config \
  -wid "$WID" \
  -len "$LEN" -out_file ${WORK_DIR}/${OUTPUT}.txt -overwrite #>>${EXE}_trace.log 2>&1
}

#all
func_m1(){
  func_itrace
  func_qtrace
  func_run_timer
  if [[ $GEN_TXT == true ]]; then
    func_m1_pipeview_gen_txt
  else
    func_m1_pipeview
  fi
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



case "${SIG}" in
  --itrace)
    func_itrace
    ;;
  --qtrace)
    func_qtrace
    ;;
  --run_timer)
    func_run_timer
    ;;
  --m1_pipeview)
    if [[ $GEN_TXT == true ]]; then
      func_m1_pipeview_gen_txt
    else
      func_m1_pipeview
    fi
    ;;
  --)#缺省值模式
    func_inst_count
    NUM_INSNS_TO_COLLECT=${insts}
    func_itrace
    func_qtrace
    func_run_timer
    if [[ $GEN_TXT == true ]]; then
      func_m1_pipeview_gen_txt
    else
      func_m1_pipeview
    fi
   ;;
  --entire)
    func_inst_count
    NUM_INSNS_TO_COLLECT=${insts}
    JUMP_NUM=0
    CONVERT_NUM_Vgi_RECS=0
    if [[ ${insts} -gt 700000000 ]];then
      (( segment_count = insts/700000000+1 ))
      lenseg=700000000
      dirname=${segment_count}_seg_${lenseg}_len
      mkdir -p "${WORK_DIR}/${dirname}"
      for ((i=0;i<insts;i=i+lenseg));do
      {
        i_add_lenseg=$((i+lenseg))
        if [[ ${i_add_lenseg} -gt ${insts} ]];then
          i_add_lenseg=${insts}
        fi
        OUTPUT=${segment_count}_${i}_${i_add_lenseg}
        NUM_INST=${lenseg}
        CPI_INTERVAL=${lenseg}
        RESET_STATS=1
        SCROLL_PIPE=1
        SCROLL_BEGIN=1
        SCROLL_END=400
        func_itrace
        func_qtrace
        func_run_timer
        rm -rf "${OUTPUT}".qt
        mv "${OUTPUT}".* "${dirname}"
      } &
      done
    else
      #Runtimer
      NUM_INST=${insts}
      CPI_INTERVAL=${insts}
      RESET_STATS=1
      SCROLL_PIPE=1
      SCROLL_BEGIN=1
      SCROLL_END=400
      func_itrace
      func_qtrace
      func_run_timer
      if [[ $GEN_TXT == true ]]; then
        func_m1_pipeview_gen_txt
      else
        func_m1_pipeview
      fi
    fi
    ;;
  --all)
    func_m1
    ;;
  *)
    echo "option ${SIG} err">&2
    exit 1
esac





