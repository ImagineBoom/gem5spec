
include ../Makefile.inc

EXECUTABLE      = imagick_r_base.$(LABEL)
BENCH_PATH      = $(SPEC_HOME)/benchspec/CPU/538.imagick_r
ARGS            = -limit disk 0 $(BENCH_PATH)/data/test/input/test_input.tga -shear 25 -resize 640x480 -negate -alpha Off test_output-host.tga
ARGS4GEM5       = -limit disk 0 $(BENCH_PATH)/data/test/input/test_input.tga -shear 25 -resize 640x480 -negate -alpha Off test_output-gem5.tga

host: $(EXECUTABLE)
	$(TIMEH) ./$(EXECUTABLE) $(ARGS) 1> host_out.log 2> host_err.log

gem5: $(EXECUTABLE)
	$(TIMEG) $(GEM5) $(GEM5_OPT) $(GEM5_PY) -c $(EXECUTABLE) -o " $(ARGS4GEM5)" $(GEM5_PY_OPT) >>../consume_time.log 2>&1
	@chmod -x *gem5.log
	@grep -nr "^Error" stderr_gem5.log && echo $$(basename $(BENCH_PATH)) >> ../fail_gem5_crash.log; true

$(EXECUTABLE):
	ln -s $(BENCH_PATH)/exe/$(EXECUTABLE)

link:

echo:
	@echo './$(EXECUTABLE) $(ARGS)'

objdump: $(EXECUTABLE)
	$(OBJDUMP) -d ./$(EXECUTABLE) > obj.txt

diff:
	@diff test_output-host.tga test_output-gem5.tga >/dev/null 2>&1 \
		&& echo $$(basename $(BENCH_PATH)) DIFF PASSED \
		|| echo $$(basename $(BENCH_PATH)) DIFF FAILED | tee -a ../fail_gem5_diff.log; true

ls:
	find -maxdepth 1 -type f -exec ls -lFh {} \+

clean:
	rm -rf *.log *.txt *output.tga

clean-all:
	find ./* ! -name Makefile -exec rm -rf {} \+

include ../TRACE.mk

simpoint: $(EXECUTABLE)
	@echo ---------------------bbv_simpt handle $(FILE) beginning ---------------------->>$(FILE)_trace.log
	@$(TIMEG) $(GEM5) --outdir=$(FILE)_bbv $(GEM5_PY) --simpoint-profile --simpoint-interval=$(INTERVAL_SIZE) -c $(EXECUTABLE) -o " $(ARGS4GEM5)" --cpu-type=NonCachingSimpleCPU --mem-size=16384MB >$(FILE)_gem5_bbv.log 2>&1 ; \
	gunzip -c ./$(FILE)_bbv/simpoint.bb.gz >./$(FILE)_bbv/simpoint.bb;\
	MAXK=`wc -l ./$(FILE)_bbv/simpoint.bb | awk 'END{print sqrt($$1)}'`;\
	$(SIMPOINT_EXE) -loadFVFile ./$(FILE)_bbv/simpoint.bb.gz -maxK $${MAXK} -saveSimpoints ./$(FILE).simpts -saveSimpointWeights ./$(FILE).weights -inputVectorsGzipped >$(FILE)_simpoint.log 2>&1;\
	#$(SIMPOINT_EXE) -loadFVFile $(FILE).bb.out -maxK $(MAXK) -saveSimpoints ./$(FILE).simpts -saveSimpointWeights ./$(FILE).weights >>$(FILE)_trace.log 2>&1 ; \
	paste $(FILE).simpts $(FILE).weights | awk '{printf "%-20d %-20d %-15.5f\n",$$2,$$1,$$3}' 1>$(FILE).merge;\
	sort $(FILE).merge -n -k 2 -o $(FILE).merge
	@echo ---------------------bbv_simpt handle $(FILE) Finished ---------------------->>$(FILE)_trace.log
	@-grep -niE "FAIL|ERR|FAULT" $(FILE)_trace.log >> $(FILE)_trace_err.log; true

checkpoints: $(EXECUTABLE)
	@echo ---------------------cpts handle $(FILE) beginning ---------------------->>$(FILE)_trace.log
	$(TIMEG) $(GEM5) $(GEM5_PY) --take-simpoint-checkpoints=$(FILE).simpts,$(FILE).weights,$(INTERVAL_SIZE),$(WARMUP_LENGTH) -c $(EXECUTABLE) -o " $(ARGS4GEM5)" --mem-size=16384MB >$(FILE)_checkpoints.log 2>&1
	@echo ---------------------cpts handle $(FILE) Finished ---------------------->>$(FILE)_trace.log
	@-grep -niE "FAIL|ERR|FAULT" $(FILE)_checkpoints.log >> $(FILE)_trace_err.log; true

checkpoints_2: $(EXECUTABLE)
	@echo ---------------------cpts handle $(FILE) beginning ---------------------->>$(FILE)_trace.log
	$(TIMEG) $(GEM5) $(GEM5_PY) --take-simpoint-checkpoints=$(FILE).simpts,$(FILE).weights,$(INTERVAL_SIZE),$(WARMUP_LENGTH) -n 2 -c "$(EXECUTABLE);$(EXECUTABLE)" -o " $(ARGS4GEM5); $(ARGS4GEM5)" --mem-size=16384MB >$(FILE)_checkpoints.log 2>&1
	@echo ---------------------cpts handle $(FILE) Finished ---------------------->>$(FILE)_trace.log
	@-grep -niE "FAIL|ERR|FAULT" $(FILE)_checkpoints.log >> $(FILE)_trace_err.log; true

checkpoints_4: $(EXECUTABLE)
	@echo ---------------------cpts handle $(FILE) beginning ---------------------->>$(FILE)_trace.log
	$(TIMEG) $(GEM5) $(GEM5_PY) --take-simpoint-checkpoints=$(FILE).simpts,$(FILE).weights,$(INTERVAL_SIZE),$(WARMUP_LENGTH) -n 4 -c "$(EXECUTABLE);$(EXECUTABLE);$(EXECUTABLE);$(EXECUTABLE)" -o " $(ARGS4GEM5); $(ARGS4GEM5); $(ARGS4GEM5); $(ARGS4GEM5)" --mem-size=16384MB >$(FILE)_checkpoints.log 2>&1
	@echo ---------------------cpts handle $(FILE) Finished ---------------------->>$(FILE)_trace.log
	@-grep -niE "FAIL|ERR|FAULT" $(FILE)_checkpoints.log >> $(FILE)_trace_err.log; true

checkpoints_8: $(EXECUTABLE)
	@echo ---------------------cpts handle $(FILE) beginning ---------------------->>$(FILE)_trace.log
	$(TIMEG) $(GEM5) $(GEM5_PY) --take-simpoint-checkpoints=$(FILE).simpts,$(FILE).weights,$(INTERVAL_SIZE),$(WARMUP_LENGTH) -n 8 -c "$(EXECUTABLE);$(EXECUTABLE);$(EXECUTABLE);$(EXECUTABLE);$(EXECUTABLE);$(EXECUTABLE);$(EXECUTABLE);$(EXECUTABLE)" -o " $(ARGS4GEM5); $(ARGS4GEM5); $(ARGS4GEM5); $(ARGS4GEM5); $(ARGS4GEM5); $(ARGS4GEM5); $(ARGS4GEM5); $(ARGS4GEM5)" --mem-size=16384MB >$(FILE)_checkpoints.log 2>&1
	@echo ---------------------cpts handle $(FILE) Finished ---------------------->>$(FILE)_trace.log
	@-grep -niE "FAIL|ERR|FAULT" $(FILE)_checkpoints.log >> $(FILE)_trace_err.log; true

restore: $(EXECUTABLE)
	@echo ---------------------rscpt handle $(FILE) beginning ---------------------->>$(FILE)_trace.log
	$(TIMEG) $(GEM5) -d ./output_ckp$(NUM_CKP) $(GEM5_PY) --restore-simpoint-checkpoint -r $(NUM_CKP) --checkpoint-dir ./m5out -c $(EXECUTABLE) -o " $(ARGS4GEM5)" --cpu-type=$(CPU_TYPE) $(CACHE_OPT) >$(FILE)_restore_ckp$(NUM_CKP).log 2>&1
	@echo ---------------------rscpt handle $(FILE) Finished ---------------------->>$(FILE)_trace.log
	@-grep -niE "FAIL|ERR|FAULT" $(FILE)_restore_ckp$(NUM_CKP).log >> $(FILE)_trace_err.log; true

restore_case: $(EXECUTABLE)
	@echo ---------------------rscpt_all handle $(FILE) beginning ---------------------->>$(FILE)_trace.log;
	@rm -rf ./output_ckp*;
	@rm -rf ./$(FILE)_CKPS_CPI.log;
	@rm -rf ./$(FILE)_RS_NUM.log;
	@m=(`awk 'END {print NR}' ./$(FILE).merge`);\
	for i in `seq $${m}`; do (\
		$(TIMEG) $(GEM5) -d ./output_ckp$${i} $(GEM5_PY) --restore-simpoint-checkpoint -r $${i} --checkpoint-dir ./m5out -c $(EXECUTABLE) -o " $(ARGS4GEM5)" --cpu-type=$(CPU_TYPE) $(CACHE_OPT) >$(FILE)_restore_ckp$${i}.log 2>&1;\
		grep -niE "FAIL|ERR|FAULT" $(FILE)_restore_ckp$${i}.log >> $(FILE)_trace_err.log; true;\
		simpts=`sed -n "$${i}p" $(FILE).merge | awk '{print $$2}'`;\
		weights=`sed -n "$${i}p" $(FILE).merge | awk '{print $$3}'`;\
		cpi=0;\
		[ `grep "system.switch_cpus.totalCpi" ./output_ckp$${i}/stats.txt | wc -l` == 2 ] \
		&& cpi=`grep "system.switch_cpus.totalCpi.*" ./output_ckp$${i}/stats.txt | awk 'END{print $$2}'`;\
		echo ckp$${i} $${simpts} $${weights} $${cpi} >> ./$(FILE)_CKPS_CPI.log;\
		echo Finshed_Restore_CKP_$${i} >> ./$(FILE)_RS_NUM.log)& \
	done;
	@echo ---------------------rscpt_all handle $(FILE) Finished ---------------------->>$(FILE)_trace.log

restore_all: $(EXECUTABLE)
	@echo ---------------------rscpt_all handle $(FILE) beginning ---------------------->>$(FILE)_trace.log;
	@rm -rf ./output_ckp*;
	@rm -rf ./$(FILE)_CKPS_CPI.log;
	@rm -rf ./$(FILE)_RS_NUM.log;
	@m=(`awk 'END {print NR}' ./$(FILE).merge`);\
	exec 6<>$(FLOODGATE);\
	for i in `seq $${m}`; do read -u6; (\
		$(TIMEG) $(GEM5) -d $(WORK_DIR)/$(FILE)/output_ckp$${i} $(GEM5_PY) --restore-simpoint-checkpoint -r $${i} --checkpoint-dir ./m5out -c $(EXECUTABLE) -o " $(ARGS4GEM5)" --cpu-type=$(CPU_TYPE) --cpu-clock=$(CPU_CLOCK) $(CACHE_OPT) >$(FILE)_restore_ckp$${i}.log 2>&1;\
		grep -niE "FAIL|ERR|FAULT" $(FILE)_restore_ckp$${i}.log >> $(FILE)_trace_err.log; true;\
		simpts=`sed -n "$${i}p" $(FILE).merge | awk '{print $$2}'`;\
		weights=`sed -n "$${i}p" $(FILE).merge | awk '{print $$3}'`;\
		cpi=0;\
		[ `grep "system.switch_cpus.totalCpi" ./output_ckp$${i}/stats.txt | wc -l` == 2 ] \
		&& cpi=`grep "system.switch_cpus.totalCpi.*" ./output_ckp$${i}/stats.txt | awk 'END{print $$2}'`;\
		echo ckp$${i} $${simpts} $${weights} $${cpi} >> ./$(FILE)_CKPS_CPI.log;\
		echo Finshed_Restore_CKP_$${i} >> ./$(FILE)_RS_NUM.log;\
		echo >&6 )& \
	done;
	@echo ---------------------rscpt_all handle $(FILE) Finished ---------------------->>$(FILE)_trace.log

restore_all_2: $(EXECUTABLE)
	@echo ---------------------rscpt_all handle $(FILE) beginning ---------------------->>$(FILE)_trace.log;
	@rm -rf ./output_ckp*;
	@rm -rf ./$(FILE)_CKPS_CPI.log;
	@rm -rf ./$(FILE)_RS_NUM.log;
	@m=(`awk 'END {print NR}' ./$(FILE).merge`);\
	exec 6<>$(FLOODGATE);\
	for i in `seq $${m}`; do read -u6; (\
		$(TIMEG) $(GEM5) -d $(WORK_DIR)/$(FILE)/output_ckp$${i} $(GEM5_PY) --restore-simpoint-checkpoint -r $${i} --checkpoint-dir ./m5out -n 2 -c "$(EXECUTABLE);$(EXECUTABLE)" -o " $(ARGS4GEM5); $(ARGS4GEM5)" --cpu-type=$(CPU_TYPE) $(CACHE_OPT) >$(FILE)_restore_ckp$${i}.log 2>&1;\
		echo >&6 )& \
	done;
	@echo ---------------------rscpt_all handle $(FILE) Finished ---------------------->>$(FILE)_trace.log

restore_all_4: $(EXECUTABLE)
	@echo ---------------------rscpt_all handle $(FILE) beginning ---------------------->>$(FILE)_trace.log;
	@rm -rf ./output_ckp*;
	@rm -rf ./$(FILE)_CKPS_CPI.log;
	@rm -rf ./$(FILE)_RS_NUM.log;
	@m=(`awk 'END {print NR}' ./$(FILE).merge`);\
	exec 6<>$(FLOODGATE);\
	for i in `seq $${m}`; do read -u6; (\
		$(TIMEG) $(GEM5) -d $(WORK_DIR)/$(FILE)/output_ckp$${i} $(GEM5_PY) --restore-simpoint-checkpoint -r $${i} --checkpoint-dir ./m5out -n 4 -c "$(EXECUTABLE);$(EXECUTABLE);$(EXECUTABLE);$(EXECUTABLE)" -o " $(ARGS4GEM5); $(ARGS4GEM5); $(ARGS4GEM5); $(ARGS4GEM5)" --cpu-type=$(CPU_TYPE) $(CACHE_OPT) >$(FILE)_restore_ckp$${i}.log 2>&1;\
		echo >&6 )& \
	done;
	@echo ---------------------rscpt_all handle $(FILE) Finished ---------------------->>$(FILE)_trace.log

gem5_pipeview: $(EXECUTABLE)
	@echo ---------------------gem5pv handle $(FILE) beginning ---------------------->>$(FILE)_trace.log
	tick_nums=(`grep -oP 'Entering event queue @ \d+' $(FILE)_restore.log|grep -oP '\d+'`);\
	$(TIMEG) $(GEM5) --debug-flags=O3PipeView --debug-start=$${tick_nums[0]} --debug-file=trace.out $(GEM5_PY) -c $(EXECUTABLE) -o " $(ARGS4GEM5)"  $(GEM5_PY_OPT) -m $${tick_nums[-1]}
	$(GEM5_REPO_PATH)/util/o3-pipeview.py -c 500 -o pipeview.out --color m5out/trace.out
	less -r pipeview.out
	@echo ---------------------gem5pv handle $(FILE) Finished ---------------------->>$(FILE)_trace.log
