SIMPOINT_EXE   = /home/lizongping/Desktop/SimPoint.3.2/bin/simpoint
VALGRIND_EXE   = /home/lizongping/dev/valgrind-install/bin/valgrind
VGI2QT_EXE     = /home/lizongping/dev/valgrind-install/bin/vgi2qt

FILE           = $$(basename $(BENCH_PATH))
FILE_FOR_FINDINTERVALSIZE = "$(FILE)"
#Simpoint
INTERVAL_SIZE  = 5000000
MAXK           = 35
WARMUP_LENGTH  = 1000000
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

# gem5 ckp 配置部分
# gem5 参数
GEM5_RESTORE_OPT =
# se.py 参数
CPU_CLOCK = 4.0GHz
CPU_TYPE = P8CPU

CACHE_OPT += --ruby --caches --l1d_size=64kB --l1d_assoc=8 --l1i_size=32kB --l1i_assoc=8 --l2cache --l2_size=512kB --l2_assoc=8 --l3_size=8MB --l3_assoc=8 --cacheline_size=128
# se.py 其余参数
GEM5_CKP_PY_OPT += --ruby-clock=4.0GHz --mem-size=16384MB --mem-type=DDR4_2933_16x4 --enable-mem-param-override=True --dram-addr-mapping=RoCoRaBaCh --dram-max-accesses-per-row=16 --dram-page-policy close_adaptive --dram-read-buffer-size=64 --dram-write-buffer-size=128 --mc-be-latency=10ns --mc-fe-latency=35ns --mc-mem-sched-policy=frfcfs

# smt se.py config
#CPU_CLOCK = 3.0GHz
#GEM5_CKP_PY_OPT += --ruby-clock=3.0GHz --mem-size=16384MB --mem-type=DDR5_5600_8x8 --enable-mem-param-override=True --dram-addr-mapping=RoCoRaBaCh --dram-max-accesses-per-row=16 --dram-page-policy close_adaptive --dram-read-buffer-size=64 --dram-write-buffer-size=128 --mc-be-latency=10ns --mc-fe-latency=35ns --mc-mem-sched-policy=frfcfs
#CACHE_OPT += --ruby --mem-size=16384MB --caches --l1d_size=64kB --l1d_assoc=8 --l1i_size=32kB --l1i_assoc=8 --l2cache --l2_size=512kB --l2_assoc=8 --l3_size=8MB --l3_assoc=8 --cacheline_size=64 --network=garnet --topology=CrossbarGarnet --l2_hit_latency=3 --enable_l3prefetch=0 --random_replacement=0
#CACHE_OPT += --ruby --mem-size=16384MB --caches --l1d_size=32kB --l1d_assoc=8 --l1i_size=16kB --l1i_assoc=8 --l2cache --l2_size=512kB --l2_assoc=8 --l3_size=8MB --l3_assoc=8 --cacheline_size=64 --network=garnet --topology=CrossbarGarnet --l2_hit_latency=3 --enable_l3prefetch=0 --random_replacement=0
#CACHE_OPT += --ruby --mem-size=16384MB --caches --l1d_size=16kB --l1d_assoc=8 --l1i_size=8kB --l1i_assoc=8 --l2cache --l2_size=512kB --l2_assoc=8 --l3_size=8MB --l3_assoc=8 --cacheline_size=64 --network=garnet --topology=CrossbarGarnet --l2_hit_latency=3 --enable_l3prefetch=0 --random_replacement=0
#CACHE_OPT += --ruby --mem-size=16384MB --caches --l1d_size=8kB --l1d_assoc=8 --l1i_size=4kB --l1i_assoc=8 --l2cache --l2_size=512kB --l2_assoc=8 --l3_size=8MB --l3_assoc=8 --cacheline_size=64 --network=garnet --topology=CrossbarGarnet --l2_hit_latency=3 --enable_l3prefetch=0 --random_replacement=0

TIME = /usr/bin/time --format="Consumed Time: %E  --  $$(basename $${PWD})"

FLOODGATE=../../running/run.fifo
BACKUP_PATH=
WORK_DIR=

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
	@rm -rf ./$(FILE)_CKPS_Weighted_CPI.log
	@rm -rf ./$(FILE)_CKPS_CPI.log
	@rm -rf ./$(FILE)_CKPS_CPI_Err.log
	@rm -rf ./$(FILE)_RS_NUM.log
	@rm -rf ./*.csv
	@m=(`awk 'END {print NR}' ./$(FILE).merge`);\
	# set up flag for judge ;\
	flag=true;\
	# check .merge lines ?= m5out/cpt file nums ;\
	[ $${m} != ` find ./m5out/ -name "cpt.*" -exec basename {} \; |wc -l` ] \
	&& flag=false || echo "ckp num right";\
	# check each cpt weight (on cptfile such as: cpt.simpoint_00_inst_0_weight_0.045455_interval_5000000_warmup_0) ?= weight(in .merge) ;\
	# because of weights Digital precision problem，gem5 create checkpoint use %.6f and our .merge file use %.5 ;\
	# so we use the original .weights file directly;\
	for i in `seq $${m}`; do\
		weights=`sed -n "$${i}p" $(FILE).weights | awk '{printf "%.6f\n",$$1}'`;\
		[ ` find ./m5out/ -name "cpt.*" -exec basename {} \;| grep $${weights} -o | wc -l` == 0 ] \
		&& flag=false || echo "with $${weights}";\
	done;\
	# recreate ./$(FILE)_CKPS_CPI.log /$(FILE)_RS_NUM.log, according to above ;\
	for i in `seq $${m}`; do\
		simpts=`sed -n "$${i}p" $(FILE).merge | awk '{print $$2}'`;\
		weights=`sed -n "$${i}p" $(FILE).merge | awk '{print $$3}'`;\
		cpi=0;\
		[ $${flag} == true ] \
		&& [ `grep "system.switch_cpus.totalCpi" ./output_ckp$${i}/stats.txt | wc -l` == 2 ] \
		&& cpi=`grep "system.switch_cpus.totalCpi.*" ./output_ckp$${i}/stats.txt | awk 'END{print $$2}'`\
		||echo "restore results maybe with problem!, $(FILE), ckp$${i}, simpts, $${simpts}, weights, $${weights}, not have cpi"| tee -a ./$(FILE)_CKPS_CPI_Err.log;\
		echo ckp$${i} $${simpts} $${weights} $${cpi} >> ./$(FILE)_CKPS_CPI.log;\
		echo Finshed_Restore_CKP_$${i} >> ./$(FILE)_RS_NUM.log;\
	done;
	# create cpi files
	@sort -n -r -k 3 ./$(FILE)_CKPS_CPI.log -o ./$(FILE)_CKPS_CPI_sorted.log;
	@m=(`awk 'END {print NR}' ./$(FILE)_CKPS_CPI_sorted.log;`);\
	for i in `seq $${m}`; do( \
		num=`sed -n "$${i}p" ./$(FILE)_CKPS_CPI_sorted.log | awk '{print $$1}'`; \
		simpts=`sed -n "$${i}p" ./$(FILE)_CKPS_CPI_sorted.log | awk '{print $$2}'`; \
		weights=`sed -n "$${i}p" ./$(FILE)_CKPS_CPI_sorted.log | awk '{print $$3}'`; \
		cpi=`sed -n "$${i}p" ./$(FILE)_CKPS_CPI_sorted.log | awk '{print $$4}'`;\
		#weightedCPI=`echo "$${weights}*$${cpi}" | bc`;\
		weightedCPI=`echo $${weights} $${cpi} | awk '{printf "%.6f", $$1*$$2}'`;\
		echo $(FILE) $${num} $${simpts} $${weights} $${cpi} $${weightedCPI} >> ./$(FILE)_CKPS_Weighted_CPI.log;) \
	done;
	rm -rf ./$(FILE)_CKPS_CPI_sorted.log;\
	result=`awk '{sum+=$$6}END{print sum}' ./$(FILE)_CKPS_Weighted_CPI.log`;\
	awk 'NR==1 {OFS=",";print "Case#","Checkpoint#","Simpts","Weights","CPI","WeightedCPI"} {OFS=",";print $$1,$$2,$$3,$$4,$$5,$$6}' $(FILE)_CKPS_Weighted_CPI.log >$(FILE)_Final_Result_$${result}.csv;\
	case_name=$(FILE);\
	#sed -i '$$a The '$$case_name' total weighted cpi is '$$result'' ./$(FILE)_Final_Result_$${result}.csv;\
	sed -i '$$G' ./$(FILE)_Final_Result_$${result}.csv;\
	echo $(FILE) $${result} >$(FILE)_Total_Result_CPI.log;
	@echo ---------------------cpi handle $(FILE) Finished ---------------------->>$(FILE)_trace.log;

cpi_2: $(EXECUTABLE)
	@echo ---------------------cpi handle $(FILE) beginning ---------------------->>$(FILE)_trace.log;
	@rm -rf ./$(FILE)_CKPS_Weighted_CPI.log
	@rm -rf ./$(FILE)_CKPS_CPI.log
	@rm -rf ./$(FILE)_CKPS_CPI_Err.log
	@rm -rf ./$(FILE)_RS_NUM.log
	@rm -rf ./*.csv
	@m=(`awk 'END {print NR}' ./$(FILE).merge`);\
	# set up flag for judge ;\
	flag=true;\
	# check .merge lines ?= m5out/cpt file nums ;\
	[ $${m} != ` find ./m5out/ -name "cpt.*" -exec basename {} \; |wc -l` ] \
	&& flag=false || echo "ckp num right";\
	# check each cpt weight (on cptfile such as: cpt.simpoint_00_inst_0_weight_0.045455_interval_5000000_warmup_0) ?= weight(in .merge) ;\
	# because of weights Digital precision problem，gem5 create checkpoint use %.6f and our .merge file use %.5 ;\
	# so we use the original .weights file directly;\
	for i in `seq $${m}`; do\
		weights=`sed -n "$${i}p" $(FILE).weights | awk '{printf "%.6f\n",$$1}'`;\
		[ ` find ./m5out/ -name "cpt.*" -exec basename {} \;| grep $${weights} -o | wc -l` == 0 ] \
		&& flag=false || echo "with $${weights}";\
	done;\
	# recreate ./$(FILE)_CKPS_CPI.log /$(FILE)_RS_NUM.log, according to above ;\
	for i in `seq $${m}`; do\
		simpts=`sed -n "$${i}p" $(FILE).merge | awk '{print $$2}'`;\
		weights=`sed -n "$${i}p" $(FILE).merge | awk '{print $$3}'`;\
		#cpi=0;\
		cpi0=0;\
		cpi1=0;\
		[ $${flag} == true ] \
		&& [ `grep "system.switch_cpus0.totalCpi" ./output_ckp$${i}/stats.txt | wc -l` == 2 ] \
		&& cpi0=`grep "system.switch_cpus0.totalCpi.*" ./output_ckp$${i}/stats.txt | awk 'END{print $$2}'`\
		&& [ `grep "system.switch_cpus1.totalCpi" ./output_ckp$${i}/stats.txt | wc -l` == 2 ] \
		&& cpi1=`grep "system.switch_cpus1.totalCpi.*" ./output_ckp$${i}/stats.txt | awk 'END{print $$2}'`\
		||echo "restore results maybe with problem!, $(FILE), ckp$${i}, simpts, $${simpts}, weights, $${weights}, not have cpi"| tee -a ./$(FILE)_CKPS_CPI_Err.log;\
		#cpi=`echo $${cpi0} $${cpi1} | awk '{printf "%.2f", $$1+$$2}'`;\
		echo ckp$${i} $${simpts} $${weights} $${cpi0} $${cpi1} >> ./$(FILE)_CKPS_CPI.log;\
		echo Finshed_Restore_CKP_$${i} >> ./$(FILE)_RS_NUM.log;\
	done;
	# create cpi files
	@sort -n -r -k 3 ./$(FILE)_CKPS_CPI.log -o ./$(FILE)_CKPS_CPI_sorted.log;
	@m=(`awk 'END {print NR}' ./$(FILE)_CKPS_CPI_sorted.log;`);\
	for i in `seq $${m}`; do( \
		num=`sed -n "$${i}p" ./$(FILE)_CKPS_CPI_sorted.log | awk '{print $$1}'`; \
		simpts=`sed -n "$${i}p" ./$(FILE)_CKPS_CPI_sorted.log | awk '{print $$2}'`; \
		weights=`sed -n "$${i}p" ./$(FILE)_CKPS_CPI_sorted.log | awk '{print $$3}'`; \
		cpi0=`sed -n "$${i}p" ./$(FILE)_CKPS_CPI_sorted.log | awk '{print $$4}'`;\
		cpi1=`sed -n "$${i}p" ./$(FILE)_CKPS_CPI_sorted.log | awk '{print $$5}'`;\
		#weightedCPI=`echo "$${weights}*$${cpi}" | bc`;\
		weightedCPI0=`echo $${weights} $${cpi0} | awk '{printf "%.6f", $$1*$$2}'`;\
		weightedCPI1=`echo $${weights} $${cpi1} | awk '{printf "%.6f", $$1*$$2}'`;\
		echo $(FILE) $${num} $${simpts} $${weights} $${cpi0} $${weightedCPI0} $${cpi1} $${weightedCPI1} >> ./$(FILE)_CKPS_Weighted_CPI.log;) \
	done;
	rm -rf ./$(FILE)_CKPS_CPI_sorted.log;\
	result0=`awk '{sum+=$$6}END{print sum}' ./$(FILE)_CKPS_Weighted_CPI.log`;\
	result1=`awk '{sum+=$$8}END{print sum}' ./$(FILE)_CKPS_Weighted_CPI.log`;\
	awk 'NR==1 {OFS=",";print "Case#","Checkpoint#","Simpts","Weights","CPI0","WeightedCPI0","CPI1","WeightedCPI1"} {OFS=",";print $$1,$$2,$$3,$$4,$$5,$$6,$$7,$$8}' $(FILE)_CKPS_Weighted_CPI.log >./$(FILE)_Final_Result_CPI.csv;\
	case_name=$(FILE);\
	#sed -i '$$a The '$$case_name' total weighted cpi is '$$result'' ./$(FILE)_Final_Result_$${result}.csv;\
	sed -i '$$G' ./$(FILE)_Final_Result_CPI.csv;\
	echo $(FILE) $${result0} $${result1} >$(FILE)_Total_Result_CPI.log;
	@echo ---------------------cpi handle $(FILE) Finished ---------------------->>$(FILE)_trace.log;

		# grep -niE "FAIL|ERR|FAULT" $(FILE)_restore_ckp$${i}.log >> $(FILE)_trace_err.log; true;\
		# simpts=`sed -n "$${i}p" $(FILE).merge | awk '{print $$2}'`;\
		# weights=`sed -n "$${i}p" $(FILE).merge | awk '{print $$3}'`;\
		# cpi=0;\
		# cpi0=0;\
		# cpi1=0;\
		# [ `grep "system.switch_cpus0.totalCpi" ./output_ckp$${i}/stats.txt | wc -l` == 2 ] \
		# && cpi0=`grep "system.switch_cpus0.totalCpi.*" ./output_ckp$${i}/stats.txt | awk 'END{print $$2}'`;\
		# [ `grep "system.switch_cpus1.totalCpi" ./output_ckp$${i}/stats.txt | wc -l` == 2 ] \
		# && cpi1=`grep "system.switch_cpus1.totalCpi.*" ./output_ckp$${i}/stats.txt | awk 'END{print $$2}'`;\
		# cpi=`echo $${cpi0} $${cpi1} | awk '{printf "%.6f", $$1+$$2}'`;\
		# echo ckp$${i} $${simpts} $${weights} $${cpi} $${cpi0} $${cpi1}>> ./$(FILE)_CKPS_CPI.log;\
		# echo Finshed_Restore_CKP_$${i} >> ./$(FILE)_RS_NUM.log;\

cpi_4: $(EXECUTABLE)
	@echo ---------------------cpi handle $(FILE) beginning ---------------------->>$(FILE)_trace.log;
	@rm -rf ./$(FILE)_CKPS_Weighted_CPI.log
	@rm -rf ./$(FILE)_CKPS_CPI.log
	@rm -rf ./$(FILE)_CKPS_CPI_Err.log
	@rm -rf ./$(FILE)_RS_NUM.log
	@rm -rf ./*.csv
	@m=(`awk 'END {print NR}' ./$(FILE).merge`);\
	# set up flag for judge ;\
	flag=true;\
	# check .merge lines ?= m5out/cpt file nums ;\
	[ $${m} != ` find ./m5out/ -name "cpt.*" -exec basename {} \; |wc -l` ] \
	&& flag=false || echo "ckp num right";\
	# check each cpt weight (on cptfile such as: cpt.simpoint_00_inst_0_weight_0.045455_interval_5000000_warmup_0) ?= weight(in .merge) ;\
	# because of weights Digital precision problem，gem5 create checkpoint use %.6f and our .merge file use %.5 ;\
	# so we use the original .weights file directly;\
	for i in `seq $${m}`; do\
		weights=`sed -n "$${i}p" $(FILE).weights | awk '{printf "%.6f\n",$$1}'`;\
		[ ` find ./m5out/ -name "cpt.*" -exec basename {} \;| grep $${weights} -o | wc -l` == 0 ] \
		&& flag=false || echo "with $${weights}";\
	done;\
	# recreate ./$(FILE)_CKPS_CPI.log /$(FILE)_RS_NUM.log, according to above ;\
	for i in `seq $${m}`; do\
		simpts=`sed -n "$${i}p" $(FILE).merge | awk '{print $$2}'`;\
		weights=`sed -n "$${i}p" $(FILE).merge | awk '{print $$3}'`;\
		#cpi=0;\
		cpi0=0;\
		cpi1=0;\
		cpi2=0;\
		cpi3=0;\
		[ $${flag} == true ] \
		&& [ `grep "system.switch_cpus0.totalCpi" ./output_ckp$${i}/stats.txt | wc -l` == 2 ] \
		&& cpi0=`grep "system.switch_cpus0.totalCpi.*" ./output_ckp$${i}/stats.txt | awk 'END{print $$2}'`\
		&& [ `grep "system.switch_cpus1.totalCpi" ./output_ckp$${i}/stats.txt | wc -l` == 2 ] \
		&& cpi1=`grep "system.switch_cpus1.totalCpi.*" ./output_ckp$${i}/stats.txt | awk 'END{print $$2}'`\
		&& [ `grep "system.switch_cpus2.totalCpi" ./output_ckp$${i}/stats.txt | wc -l` == 2 ] \
		&& cpi2=`grep "system.switch_cpus2.totalCpi.*" ./output_ckp$${i}/stats.txt | awk 'END{print $$2}'`\
		&& [ `grep "system.switch_cpus3.totalCpi" ./output_ckp$${i}/stats.txt | wc -l` == 2 ] \
		&& cpi3=`grep "system.switch_cpus3.totalCpi.*" ./output_ckp$${i}/stats.txt | awk 'END{print $$2}'`\
		||echo "restore results maybe with problem!, $(FILE), ckp$${i}, simpts, $${simpts}, weights, $${weights}, not have cpi"| tee -a ./$(FILE)_CKPS_CPI_Err.log;\
		#cpi=`echo $${cpi0} $${cpi1} $${cpi2} $${cpi3}| awk '{printf "%.6f", $$1+$$2+$$3+$$4}'`;\
		echo ckp$${i} $${simpts} $${weights} $${cpi0} $${cpi1} $${cpi2} $${cpi3} >> ./$(FILE)_CKPS_CPI.log;\
		echo Finshed_Restore_CKP_$${i} >> ./$(FILE)_RS_NUM.log;\
	done;
	# create cpi files
	@sort -n -r -k 3 ./$(FILE)_CKPS_CPI.log -o ./$(FILE)_CKPS_CPI_sorted.log;
	@m=(`awk 'END {print NR}' ./$(FILE)_CKPS_CPI_sorted.log;`);\
	for i in `seq $${m}`; do( \
		num=`sed -n "$${i}p" ./$(FILE)_CKPS_CPI_sorted.log | awk '{print $$1}'`; \
		simpts=`sed -n "$${i}p" ./$(FILE)_CKPS_CPI_sorted.log | awk '{print $$2}'`; \
		weights=`sed -n "$${i}p" ./$(FILE)_CKPS_CPI_sorted.log | awk '{print $$3}'`; \
		cpi0=`sed -n "$${i}p" ./$(FILE)_CKPS_CPI_sorted.log | awk '{print $$4}'`;\
		cpi1=`sed -n "$${i}p" ./$(FILE)_CKPS_CPI_sorted.log | awk '{print $$5}'`;\
		cpi2=`sed -n "$${i}p" ./$(FILE)_CKPS_CPI_sorted.log | awk '{print $$6}'`;\
		cpi3=`sed -n "$${i}p" ./$(FILE)_CKPS_CPI_sorted.log | awk '{print $$7}'`;\
		#weightedCPI=`echo "$${weights}*$${cpi}" | bc`;\
		weightedCPI0=`echo $${weights} $${cpi0} | awk '{printf "%.6f", $$1*$$2}'`;\
		weightedCPI1=`echo $${weights} $${cpi1} | awk '{printf "%.6f", $$1*$$2}'`;\
		weightedCPI2=`echo $${weights} $${cpi2} | awk '{printf "%.6f", $$1*$$2}'`;\
		weightedCPI3=`echo $${weights} $${cpi3} | awk '{printf "%.6f", $$1*$$2}'`;\
		echo $(FILE) $${num} $${simpts} $${weights} $${cpi0} $${weightedCPI0} $${cpi1} $${weightedCPI1} $${cpi2} $${weightedCPI2} $${cpi3} $${weightedCPI3}>> ./$(FILE)_CKPS_Weighted_CPI.log;) \
	done;
	rm -rf ./$(FILE)_CKPS_CPI_sorted.log;\
	result0=`awk '{sum+=$$6}END{print sum}' ./$(FILE)_CKPS_Weighted_CPI.log`;\
	result1=`awk '{sum+=$$8}END{print sum}' ./$(FILE)_CKPS_Weighted_CPI.log`;\
	result2=`awk '{sum+=$$10}END{print sum}' ./$(FILE)_CKPS_Weighted_CPI.log`;\
	result3=`awk '{sum+=$$12}END{print sum}' ./$(FILE)_CKPS_Weighted_CPI.log`;\
	awk 'NR==1 {OFS=",";print "Case#","Checkpoint#","Simpts","Weights","CPI0","WeightedCPI0","CPI1","WeightedCPI1","CPI2","WeightedCPI2","CPI3","WeightedCPI3"} {OFS=",";print $$1,$$2,$$3,$$4,$$5,$$6,$$7,$$8,$$9,$$10,$$11,$$12}' $(FILE)_CKPS_Weighted_CPI.log >$(FILE)_Final_Result_CPI.csv;\
	case_name=$(FILE);\
	#sed -i '$$a The '$$case_name' total weighted cpi is '$$result'' ./$(FILE)_Final_Result_$${result}.csv;\
	sed -i '$$G' ./$(FILE)_Final_Result_CPI.csv;\
	echo $(FILE) $${result0} $${result1} $${result2} $${result3} >$(FILE)_Total_Result_CPI.log;
	@echo ---------------------cpi handle $(FILE) Finished ---------------------->>$(FILE)_trace.log;

cpi_8: $(EXECUTABLE)
	@echo ---------------------cpi handle $(FILE) beginning ---------------------->>$(FILE)_trace.log;
	@rm -rf ./$(FILE)_CKPS_Weighted_CPI.log
	@rm -rf ./$(FILE)_CKPS_CPI.log
	@rm -rf ./$(FILE)_CKPS_CPI_Err.log
	@rm -rf ./$(FILE)_RS_NUM.log
	@rm -rf ./*.csv
	@m=(`awk 'END {print NR}' ./$(FILE).merge`);\
	# set up flag for judge ;\
	flag=true;\
	# check .merge lines ?= m5out/cpt file nums ;\
	[ $${m} != ` find ./m5out/ -name "cpt.*" -exec basename {} \; |wc -l` ] \
	&& flag=false || echo "ckp num right";\
	# check each cpt weight (on cptfile such as: cpt.simpoint_00_inst_0_weight_0.045455_interval_5000000_warmup_0) ?= weight(in .merge) ;\
	# because of weights Digital precision problem，gem5 create checkpoint use %.6f and our .merge file use %.5 ;\
	# so we use the original .weights file directly;\
	for i in `seq $${m}`; do\
		weights=`sed -n "$${i}p" $(FILE).weights | awk '{printf "%.6f\n",$$1}'`;\
		[ ` find ./m5out/ -name "cpt.*" -exec basename {} \;| grep $${weights} -o | wc -l` == 0 ] \
		&& flag=false || echo "with $${weights}";\
	done;\
	# recreate ./$(FILE)_CKPS_CPI.log /$(FILE)_RS_NUM.log, according to above ;\
	for i in `seq $${m}`; do\
		simpts=`sed -n "$${i}p" $(FILE).merge | awk '{print $$2}'`;\
		weights=`sed -n "$${i}p" $(FILE).merge | awk '{print $$3}'`;\
		#cpi=0;\
		cpi0=0;\
		cpi1=0;\
		cpi2=0;\
		cpi3=0;\
		cpi4=0;\
		cpi5=0;\
		cpi6=0;\
		cpi7=0;\
		[ $${flag} == true ] \
		&& [ `grep "system.switch_cpus0.totalCpi" ./output_ckp$${i}/stats.txt | wc -l` == 2 ] \
		&& cpi0=`grep "system.switch_cpus0.totalCpi.*" ./output_ckp$${i}/stats.txt | awk 'END{print $$2}'`\
		&& [ `grep "system.switch_cpus1.totalCpi" ./output_ckp$${i}/stats.txt | wc -l` == 2 ] \
		&& cpi1=`grep "system.switch_cpus1.totalCpi.*" ./output_ckp$${i}/stats.txt | awk 'END{print $$2}'`\
		&& [ `grep "system.switch_cpus2.totalCpi" ./output_ckp$${i}/stats.txt | wc -l` == 2 ] \
		&& cpi2=`grep "system.switch_cpus2.totalCpi.*" ./output_ckp$${i}/stats.txt | awk 'END{print $$2}'`\
		&& [ `grep "system.switch_cpus3.totalCpi" ./output_ckp$${i}/stats.txt | wc -l` == 2 ] \
		&& cpi3=`grep "system.switch_cpus3.totalCpi.*" ./output_ckp$${i}/stats.txt | awk 'END{print $$2}'`\
		&& [ `grep "system.switch_cpus4.totalCpi" ./output_ckp$${i}/stats.txt | wc -l` == 2 ] \
		&& cpi4=`grep "system.switch_cpus4.totalCpi.*" ./output_ckp$${i}/stats.txt | awk 'END{print $$2}'`\
		&& [ `grep "system.switch_cpus5.totalCpi" ./output_ckp$${i}/stats.txt | wc -l` == 2 ] \
		&& cpi5=`grep "system.switch_cpus5.totalCpi.*" ./output_ckp$${i}/stats.txt | awk 'END{print $$2}'`\
		&& [ `grep "system.switch_cpus6.totalCpi" ./output_ckp$${i}/stats.txt | wc -l` == 2 ] \
		&& cpi6=`grep "system.switch_cpus6.totalCpi.*" ./output_ckp$${i}/stats.txt | awk 'END{print $$2}'`\
		&& [ `grep "system.switch_cpus7.totalCpi" ./output_ckp$${i}/stats.txt | wc -l` == 2 ] \
		&& cpi7=`grep "system.switch_cpus7.totalCpi.*" ./output_ckp$${i}/stats.txt | awk 'END{print $$2}'`\
		||echo "restore results maybe with problem!, $(FILE), ckp$${i}, simpts, $${simpts}, weights, $${weights}, not have cpi"| tee -a ./$(FILE)_CKPS_CPI_Err.log;\
		#cpi=`echo $${cpi0} $${cpi1} $${cpi2} $${cpi3} $${cpi4} $${cpi5} $${cpi6} $${cpi7} | awk '{printf "%.6f", $$1+$$2+$$3+$$4+$$5+$$6+$$7+$$8}'`;\
		echo ckp$${i} $${simpts} $${weights} $${cpi0} $${cpi1} $${cpi2} $${cpi3} $${cpi4} $${cpi5} $${cpi6} $${cpi7} >> ./$(FILE)_CKPS_CPI.log;\
		echo Finshed_Restore_CKP_$${i} >> ./$(FILE)_RS_NUM.log;\
	done;
	# create cpi files
	@sort -n -r -k 3 ./$(FILE)_CKPS_CPI.log -o ./$(FILE)_CKPS_CPI_sorted.log;
	@m=(`awk 'END {print NR}' ./$(FILE)_CKPS_CPI_sorted.log;`);\
	for i in `seq $${m}`; do( \
		num=`sed -n "$${i}p" ./$(FILE)_CKPS_CPI_sorted.log | awk '{print $$1}'`; \
		simpts=`sed -n "$${i}p" ./$(FILE)_CKPS_CPI_sorted.log | awk '{print $$2}'`; \
		weights=`sed -n "$${i}p" ./$(FILE)_CKPS_CPI_sorted.log | awk '{print $$3}'`; \
		cpi0=`sed -n "$${i}p" ./$(FILE)_CKPS_CPI_sorted.log | awk '{print $$4}'`;\
		cpi1=`sed -n "$${i}p" ./$(FILE)_CKPS_CPI_sorted.log | awk '{print $$5}'`;\
		cpi2=`sed -n "$${i}p" ./$(FILE)_CKPS_CPI_sorted.log | awk '{print $$6}'`;\
		cpi3=`sed -n "$${i}p" ./$(FILE)_CKPS_CPI_sorted.log | awk '{print $$7}'`;\
		cpi4=`sed -n "$${i}p" ./$(FILE)_CKPS_CPI_sorted.log | awk '{print $$8}'`;\
		cpi5=`sed -n "$${i}p" ./$(FILE)_CKPS_CPI_sorted.log | awk '{print $$9}'`;\
		cpi6=`sed -n "$${i}p" ./$(FILE)_CKPS_CPI_sorted.log | awk '{print $$10}'`;\
		cpi7=`sed -n "$${i}p" ./$(FILE)_CKPS_CPI_sorted.log | awk '{print $$11}'`;\
		#weightedCPI=`echo "$${weights}*$${cpi}" | bc`;\
		weightedCPI0=`echo $${weights} $${cpi0} | awk '{printf "%.6f", $$1*$$2}'`;\
		weightedCPI1=`echo $${weights} $${cpi1} | awk '{printf "%.6f", $$1*$$2}'`;\
		weightedCPI2=`echo $${weights} $${cpi2} | awk '{printf "%.6f", $$1*$$2}'`;\
		weightedCPI3=`echo $${weights} $${cpi3} | awk '{printf "%.6f", $$1*$$2}'`;\
		weightedCPI4=`echo $${weights} $${cpi4} | awk '{printf "%.6f", $$1*$$2}'`;\
		weightedCPI5=`echo $${weights} $${cpi5} | awk '{printf "%.6f", $$1*$$2}'`;\
		weightedCPI6=`echo $${weights} $${cpi6} | awk '{printf "%.6f", $$1*$$2}'`;\
		weightedCPI7=`echo $${weights} $${cpi7} | awk '{printf "%.6f", $$1*$$2}'`;\
		echo $(FILE) $${num} $${simpts} $${weights} $${cpi0} $${weightedCPI0} $${cpi1} $${weightedCPI1} $${cpi2} $${weightedCPI2} $${cpi3} $${weightedCPI3} $${cpi4} $${weightedCPI4} $${cpi5} $${weightedCPI5} $${cpi6} $${weightedCPI6} $${cpi7} $${weightedCPI7} >> ./$(FILE)_CKPS_Weighted_CPI.log;) \
	done;
	rm -rf ./$(FILE)_CKPS_CPI_sorted.log;\
	result0=`awk '{sum+=$$6}END{print sum}' ./$(FILE)_CKPS_Weighted_CPI.log`;\
	result1=`awk '{sum+=$$8}END{print sum}' ./$(FILE)_CKPS_Weighted_CPI.log`;\
	result2=`awk '{sum+=$$10}END{print sum}' ./$(FILE)_CKPS_Weighted_CPI.log`;\
	result3=`awk '{sum+=$$12}END{print sum}' ./$(FILE)_CKPS_Weighted_CPI.log`;\
	result4=`awk '{sum+=$$14}END{print sum}' ./$(FILE)_CKPS_Weighted_CPI.log`;\
	result5=`awk '{sum+=$$16}END{print sum}' ./$(FILE)_CKPS_Weighted_CPI.log`;\
	result6=`awk '{sum+=$$18}END{print sum}' ./$(FILE)_CKPS_Weighted_CPI.log`;\
	result7=`awk '{sum+=$$20}END{print sum}' ./$(FILE)_CKPS_Weighted_CPI.log`;\
	awk 'NR==1 {OFS=",";print "Case#","Checkpoint#","Simpts","Weights","CPI0","WeightedCPI0","CPI1","WeightedCPI1","CPI2","WeightedCPI2","CPI3","WeightedCPI3","CPI4","WeightedCPI4","CPI5","WeightedCPI5","CPI6","WeightedCPI6","CPI7","WeightedCPI7"} {OFS=",";print $$1,$$2,$$3,$$4,$$5,$$6,$$7,$$8,$$9,$$10,$$11,$$12,$$13,$$14,$$15,$$16,$$17,$$18,$$19,$$20}' $(FILE)_CKPS_Weighted_CPI.log >$(FILE)_Final_Result_CPI.csv;\
	case_name=$(FILE);\
	#sed -i '$$a The '$$case_name' total weighted cpi is '$$result'' ./$(FILE)_Final_Result_$${result}.csv;\
	sed -i '$$G' ./$(FILE)_Final_Result_CPI.csv;\
	echo $(FILE) $${result0} $${result1} $${result2} $${result3} $${result4} $${result5} $${result6} $${result7} >$(FILE)_Total_Result_CPI.log;
	@echo ---------------------cpi handle $(FILE) Finished ---------------------->>$(FILE)_trace.log;

mpki: $(EXECUTABLE)
	@echo ---------------------mkpi handle $(FILE) beginning ---------------------->>$(FILE)_trace.log;
	@rm -rf ./$(FILE)_CKPS_Weighted_L2_MISS_ACCESS.log
	@rm -rf ./$(FILE)_CKPS_L2_MISS_ACCESS.log
	@rm -rf ./$(FILE)_CKPS_L2_MISS_ACCESS_Err.log
	@rm -rf ./$(FILE)_RS_NUM.log
	@m=(`awk 'END {print NR}' ./$(FILE).merge`);\
	# set up flag for judge ;\
	flag=true;\
	# check .merge lines ?= m5out/cpt file nums ;\
	[ $${m} != ` find ./m5out/ -name "cpt.*" -exec basename {} \; |wc -l` ] \
	&& flag=false || echo "ckp num right";\
	# check each cpt weight (on cptfile such as: cpt.simpoint_00_inst_0_weight_0.045455_interval_5000000_warmup_0) ?= weight(in .merge) ;\
	# because of weights Digital precision problem，gem5 create checkpoint use %.6f and our .merge file use %.5 ;\
	# so we use the original .weights file directly;\
	for i in `seq $${m}`; do\
		weights=`sed -n "$${i}p" $(FILE).weights | awk '{printf "%.6f\n",$$1}'`;\
		[ ` find ./m5out/ -name "cpt.*" -exec basename {} \;| grep $${weights} -o | wc -l` == 0 ] \
		&& flag=false || echo "with $${weights}";\
	done;\
	# recreate ./$(FILE)_CKPS_L2_MISS_ACCESS.log /$(FILE)_RS_NUM.log, according to above ;\
	for i in `seq $${m}`; do\
		simpts=`sed -n "$${i}p" $(FILE).merge | awk '{print $$2}'`;\
		weights=`sed -n "$${i}p" $(FILE).merge | awk '{print $$3}'`;\
		miss=0;\
		access=0;\
		[ $${flag} == true ] \
		&& [ `grep "system.ruby.l2_cntrl0.L2cache.m_demand_misses" ./output_ckp$${i}/stats.txt | wc -l` == 2 ] \
		&& miss=`grep "system.ruby.l2_cntrl0.L2cache.m_demand_misses.*" ./output_ckp$${i}/stats.txt | awk 'END{print $$2}'`\
		&& [ `grep "system.ruby.l2_cntrl0.L2cache.m_demand_accesses" ./output_ckp$${i}/stats.txt | wc -l` == 2 ] \
		&& access=`grep "system.ruby.l2_cntrl0.L2cache.m_demand_accesses.*" ./output_ckp$${i}/stats.txt | awk 'END{print $$2}'`\
		||echo "restore results maybe with problem!, $(FILE), ckp$${i}, simpts, $${simpts}, weights, $${weights}, not have miss & access"| tee -a ./$(FILE)_CKPS_L2_MISS_ACCESS_Err.log;\
		echo ckp$${i} $${simpts} $${weights} $${miss} $${access} >> ./$(FILE)_CKPS_L2_MISS_ACCESS.log;\
		echo Finshed_Restore_CKP_$${i} >> ./$(FILE)_RS_NUM.log;\
	done;
	# create cpi files
	@sort -n -r -k 3 ./$(FILE)_CKPS_L2_MISS_ACCESS.log -o ./$(FILE)_CKPS_L2_MISS_ACCESS_sorted.log;
	@m=(`awk 'END {print NR}' ./$(FILE)_CKPS_L2_MISS_ACCESS_sorted.log;`);\
	for i in `seq $${m}`; do( \
		num=`sed -n "$${i}p" ./$(FILE)_CKPS_L2_MISS_ACCESS_sorted.log | awk '{print $$1}'`; \
		simpts=`sed -n "$${i}p" ./$(FILE)_CKPS_L2_MISS_ACCESS_sorted.log | awk '{print $$2}'`; \
		weights=`sed -n "$${i}p" ./$(FILE)_CKPS_L2_MISS_ACCESS_sorted.log | awk '{print $$3}'`; \
		miss=`sed -n "$${i}p" ./$(FILE)_CKPS_L2_MISS_ACCESS_sorted.log | awk '{print $$4}'`;\
		access=`sed -n "$${i}p" ./$(FILE)_CKPS_L2_MISS_ACCESS_sorted.log | awk '{print $$5}'`;\
		weightedMiss=`echo $${weights} $${miss} | awk '{printf "%.6f", $$1*$$2}'`;\
		weightedAccess=`echo $${weights} $${access} | awk '{printf "%.6f", $$1*$$2}'`;\
		echo $(FILE) $${num} $${simpts} $${weights} $${miss} $${weightedMiss} $${access} $${weightedAccess} >> ./$(FILE)_CKPS_Weighted_L2_MISS_ACCESS.log;) \
	done;
	rm -rf ./$(FILE)_CKPS_L2_MISS_ACCESS_sorted.log;\
	Tmiss=`awk '{sum+=$$6}END{print sum}' ./$(FILE)_CKPS_Weighted_L2_MISS_ACCESS.log`;\
	Taccess=`awk '{sum+=$$8}END{print sum}' ./$(FILE)_CKPS_Weighted_L2_MISS_ACCESS.log`;\
	awk 'NR==1 {OFS=",";print "Case#","Checkpoint#","Simpts","Weights","Miss#","WeightedMiss#","Access#","WeightedAccess#"} {OFS=",";print $$1,$$2,$$3,$$4,$$5,$$6,$$7,$$8}' $(FILE)_CKPS_Weighted_L2_MISS_ACCESS.log >./$(FILE)_Final_Result_L2_Miss_Access.log;\
	case_name=$(FILE);\
	sed -i '$$G' ./$(FILE)_Final_Result_L2_Miss_Access.log;\
	echo $(FILE) $${Tmiss} $${Taccess} >$(FILE)_Total_Result_L2_Miss_Access.log;
	@echo ---------------------mkpi handle $(FILE) Finished ---------------------->>$(FILE)_trace.log;

clean-simpoint:
	rm -rf ./*bbv ./*gem5_bbv.log ./*merge ./*simpoint.log ./*simpts ./*weights ./*trace*

clean-checkpoint:
	rm -rf ./*checkpoints.log ./m5out

clean-restore:
	rm -rf ./*restore* ./output* ./*CKPS_CPI.log ./*csv ./*Weighted_CPI.log ./*RS_NUM.log

restore_status: $(EXECUTABLE)
	@[ x`awk 'END {print NR}' ./$(FILE).merge` == x`awk 'END {print NR}' ./$(FILE)_RS_NUM.log` ] \
	&& echo All Checkpoints Restore Have Finshed! || echo Some Checkpoints Are Restoring!

find_interval_size:  $(EXECUTABLE)
	../Find_IntervalSize.sh $(SIMPOINT_EXE) $(VALGRIND_EXE) $(EXECUTABLE) $(FILE_FOR_FINDINTERVALSIZE) "$(ARGS)" $(FILE).merge $(BACKUP_PATH) $(FLOODGATE)

print_config:
	@echo "gem5-config:"
	@echo $(CPU_CLOCK)
	@echo $(CPU_TYPE)
	@echo $(CACHE_OPT)
	@echo $(GEM5_CKP_PY_OPT)
	@echo ""