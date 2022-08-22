SIMPOINT_EXE   = /home/lizongping/Desktop/SimPoint.3.2/bin/simpoint
VALGRIND_EXE   = /home/lizongping/dev/valgrind-install/bin/valgrind
VGI2QT_EXE     = /home/lizongping/dev/valgrind-install/bin/vgi2qt

FILE           = $$(basename $(BENCH_PATH))
FILE_FOR_FINDINTERVALSIZE = "$(FILE)"
#Simpoint
INTERVAL_SIZE  = 5000000
MAXK           = 35
WARMUP_LENGTH  = 0
NUM_CKP        = 1


#ITRACE
NUM_INSNS_TO_COLLECT   = 20m
NUM_INSNS_BEFORE_START = 0


#vgi2qt
#if CONVERT_NUM_Vgi_RECS ==0 -> convert all itrace
JUMP_NUM               = 0
CONVERT_NUM_Vgi_RECS   = 0
qtFILE                 = $(FILE)
logFILE                = $(qtFILE)
resultsFILE            = $(qtFILE)

#Runtimer
NUM_INST        = 250000
CPI_INTERVAL    = 100000
RESET_STATS     = 1
SCROLL_PIPE     = 1
SCROLL_BEGIN    = 1
SCROLL_END      = 200

#scrollpv
pipeFILE        =$(resultsFILE)
pipeARGS        =

CPU_TYPE = P8CPU
CACHE_OPT += --ruby --mem-size=16384MB --caches --l1d_size=64kB --l1d_assoc=8 --l1i_size=32kB --l1i_assoc=8 --l2cache --l2_size=512kB --l2_assoc=8 --l3_size=8MB --l3_assoc=8 --cacheline_size=128

TIME = /usr/bin/time --format="Consumed Time: %E  --  $$(basename $${PWD})"

FLOODGATE=../../running/run.fifo
BACKUP_PATH=

inst_count:$(EXECUTABLE)
	$(TIME) $(VALGRIND_EXE) --tool=exp-bbv --instr-count-only=yes --bb-out-file=/dev/null ./$(EXECUTABLE) $(ARGS) >$(FILE)_inst.log 2>&1
	insts=`grep -oP 'Total instructions: \d+' $(FILE)_inst.log|grep -oP '\d+'`;\
	printf "%-20s %22d \n" $(FILE) $${insts}>>../inst_count.log

valgrind_simpoint: $(EXECUTABLE)
	@echo ---------------------simpt handle $(FILE) beginning ---------------------->>$(FILE)_trace.log
	$(TIME) $(VALGRIND_EXE) --tool=exp-bbv --interval-size=$(INTERVAL_SIZE) --bb-out-file=$(FILE).bb.out ./$(EXECUTABLE) $(ARGS) >$(FILE)_valgrind.log 2>&1 ; \
	MAXK=`wc -l $(FILE).bb.out | awk 'END{print sqrt($$1)}'` ; \
	$(SIMPOINT_EXE) -loadFVFile $(FILE).bb.out -maxK $${MAXK} -saveSimpoints ./$(FILE).simpts -saveSimpointWeights ./$(FILE).weights >$(FILE)_simpoint.log 2>&1 ; \
	#$(SIMPOINT_EXE) -loadFVFile $(FILE).bb.out -maxK $(MAXK) -saveSimpoints ./$(FILE).simpts -saveSimpointWeights ./$(FILE).weights >>$(FILE)_trace.log 2>&1 ; \
	paste $(FILE).simpts $(FILE).weights | awk '{printf "%-20d %-20d %-15.5f\n",$$2,$$1,$$3}' 1>$(FILE).merge ; \
	sort $(FILE).merge -n -k 2 -o $(FILE).merge
	@echo ---------------------simpt handle $(FILE) Finished ---------------------->>$(FILE)_trace.log
	@-grep -niE "FAIL|ERR|FAULT" $(FILE)_trace.log >> $(FILE)_trace_err.log ; true

trace: $(EXECUTABLE)
	@echo ---------------------m1 handle $(FILE) beginning ---------------------->>$(FILE)_trace.log
	$(TIME) $(VALGRIND_EXE) --tool=itrace --trace-extent=all --trace-children=no --binary-outfile=$(FILE).vgi --g-num-insns-before-start=$(NUM_INSNS_BEFORE_START) --num-insns-to-collect=$(NUM_INSNS_TO_COLLECT) ./$(EXECUTABLE) $(ARGS) >>$(FILE)_trace.log 2>&1 ; \
	echo itrace-ok ; \
	$(VGI2QT_EXE) -f $(FILE).vgi -o $(FILE).qt -j $(JUMP_NUM) -c $(CONVERT_NUM_Vgi_RECS) >>$(FILE)_trace.log 2>&1 ; \
	echo vgi2qt-ok ; \
	/opt/ibm/sim_ppc/sim_p8/bin/run_timer $(FILE).qt $(NUM_INST) $(CPI_INTERVAL) $(RESET_STATS) $(FILE) -p $(SCROLL_PIPE) -b $(SCROLL_BEGIN) -e $(SCROLL_END) -maximize  >>$(FILE)_trace.log 2>&1
	@echo timer-ok
	@echo ---------------------m1 handle $(FILE) Finished ---------------------->>$(FILE)_trace.log
	@-grep -niE "FAIL|ERR|FAULT" $(FILE)_trace.log >> $(FILE)_trace_err.log ; true

m1_pipeview: $(EXECUTABLE)
	@echo ---------------------spv handle $(FILE) beginning ---------------------->>$(FILE)_trace.log
	$(TIME) /opt/ibm/sim_ppc/bin/scrollpv -pipe $(pipeFILE).pipe -config $(pipeFILE).config $(pipeARGS) >>$(pipeFILE)_trace.log 2>&1
	@echo ---------------------spv handle $(FILE) Finished ---------------------->>$(FILE)_trace.log
	@-grep -niE "FAIL|ERR|FAULT" $(FILE)_trace.log >> $(FILE)_trace_err.log ; true

itrace: $(EXECUTABLE)
	@echo ---------------------m1 handle $(FILE) beginning ---------------------->>$(FILE)_trace.log
	$(TIME) $(VALGRIND_EXE) --tool=itrace --trace-extent=all --trace-children=no --binary-outfile=$(FILE).vgi --g-num-insns-before-start=$(NUM_INSNS_BEFORE_START) --num-insns-to-collect=$(NUM_INSNS_TO_COLLECT) ./$(EXECUTABLE) $(ARGS) >>$(FILE)_trace.log 2>&1
	@echo itrace-ok

qtrace: $(EXECUTABLE)
	$(TIME) $(VGI2QT_EXE) -f $(FILE).vgi -o $(qtFILE).qt -j $(JUMP_NUM) -c $(CONVERT_NUM_Vgi_RECS) >>$(logFILE)_trace.log 2>&1
	@echo vgi2qt-ok

m1: $(EXECUTABLE)
	$(TIME) /opt/ibm/sim_ppc/sim_p8/bin/run_timer $(qtFILE).qt $(NUM_INST) $(CPI_INTERVAL) $(RESET_STATS) $(resultsFILE) -p $(SCROLL_PIPE) -b $(SCROLL_BEGIN) -e $(SCROLL_END) -maximize  >>$(logFILE)_trace.log 2>&1
	@echo timer-ok
	@echo ---------------------m1 handle $(FILE) Finished ---------------------->>$(FILE)_trace.log
	@-grep -niE "FAIL|ERR|FAULT" $(FILE)_trace.log >> $(FILE)_trace_err.log ; true

cpi: $(EXECUTABLE)
	@echo ---------------------cpi handle $(FILE) beginning ---------------------->>$(FILE)_trace.log;
	@rm -rf ./$(FILE)_CKPS_Weighted_CPI.log;
	@rm -rf ./*.csv;
	@sort -n -r -k 2 ./$(FILE)_CKPS_CPI.log -o ./$(FILE)_CKPS_CPI_sorted.log;
	@m=(`awk 'END {print NR}' ./$(FILE)_CKPS_CPI_sorted.log;`);\
	for i in `seq $${m}`; do( \
		num=`sed -n "$${i}p" ./$(FILE)_CKPS_CPI_sorted.log | awk '{print $$1}' `; \
		weights=`sed -n "$${i}p" ./$(FILE)_CKPS_CPI_sorted.log | awk '{print $$2}' `; \
		cpi=`sed -n "$${i}p" ./$(FILE)_CKPS_CPI_sorted.log | awk '{print $$3}' `;\
		#weightedCPI=`echo "$${weights}*$${cpi}" | bc`;\
		weightedCPI=`echo $${weights} $${cpi} | awk '{printf "%.6f", $$1*$$2}'`;\
		echo $${num} $${weights} $${cpi} $${weightedCPI} >> ./$(FILE)_CKPS_Weighted_CPI.log;) \
	done;
	rm -rf ./$(FILE)_CKPS_CPI_sorted.log;\
	result=`awk '{sum+=$$4}END{print sum}' ./$(FILE)_CKPS_Weighted_CPI.log`;\
	awk 'NR==1 {OFS=",";print "Checkpoint#","Weights","CPI","WeightedCPI"} {OFS=",";print $$1,$$2,$$3,$$4}' $(FILE)_CKPS_Weighted_CPI.log >$(FILE)_final_result_$${result}.csv;\
	case_name=$(FILE);\
	sed -i '$$a The '$$case_name' total weighted cpi is '$$result'' ./$(FILE)_final_result_$${result}.csv;\
	sed -i '$$G' ./$(FILE)_final_result_$${result}.csv;
	@echo ---------------------cpi handle $(FILE) Finished ---------------------->>$(FILE)_trace.log;

restore_status: $(EXECUTABLE)
	@[ x`awk 'END {print NR}' ./$(FILE).merge` == x`awk 'END {print NR}' ./$(FILE)_RS_NUM.log` ] \
	&& echo All Checkpoints Restore Have Finshed! || echo Some Checkpoints Are Restoring!

find_interval_size:  $(EXECUTABLE)
	../Find_IntervalSize.sh $(SIMPOINT_EXE) $(VALGRIND_EXE) $(EXECUTABLE) $(FILE_FOR_FINDINTERVALSIZE) "$(ARGS)" $(FILE).merge $(BACKUP_PATH) $(FLOODGATE)