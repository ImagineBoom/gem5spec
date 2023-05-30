
inst_count:$(EXECUTABLE)
	$(TIME) $(VALGRIND_EXE) --tool=exp-bbv --instr-count-only=yes --bb-out-file=/dev/null ./$(EXECUTABLE) $(ARGS) >$(FILE)_inst.log 2>&1
	insts=`grep -oP 'Total instructions: \d+' $(FILE)_inst.log|grep -oP '\d+'`;\
	printf "%-20s %22d \n" $(FILE) $${insts}>>../inst_count.log

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

print_config:
	@echo "gem5-config:"
	@echo $(CPU_CLOCK)
	@echo $(CPU_TYPE)
	@echo $(CACHE_OPT)
	@echo $(GEM5_PY_OPT)
	@echo ""