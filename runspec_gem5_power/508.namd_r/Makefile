
include ../Makefile.inc

EXECUTABLE      = namd_r_base.$(LABEL)
BENCH_PATH      = $(SPEC_HOME)/benchspec/CPU/508.namd_r
ARGS            = --input $(BENCH_PATH)/data/all/input/apoa1.input --iterations 2 --output apoa1.test.host.output
ARGS4GEM5       = --input $(BENCH_PATH)/data/all/input/apoa1.input --iterations 2 --output apoa1.test.gem5.output

host: $(EXECUTABLE)
	$(TIMEH) ./$(EXECUTABLE) $(ARGS) 1> host_out.log 2> host_err.log
	@sed -i 's/host\.//g' host_out.log

gem5: $(EXECUTABLE)
	$(TIMEG) $(GEM5) $(GEM5_OPT) $(GEM5_PY) -c $(EXECUTABLE) -o " $(ARGS4GEM5)" $(GEM5_PY_OPT) >>../consume_time.log 2>&1
	@chmod -x *gem5.log
	@grep -nr "^Error" stderr_gem5.log && echo $$(basename $(BENCH_PATH)) >> ../fail_gem5_crash.log ; true
	@sed -i 's/gem5\.//g' gem5_out.log

$(EXECUTABLE):
	ln -s $(BENCH_PATH)/exe/$(EXECUTABLE)

link:

echo:
	@echo './$(EXECUTABLE) $(ARGS)'

objdump: $(EXECUTABLE)
	$(OBJDUMP) -d ./$(EXECUTABLE) > obj.txt

diff:
	@diff host_out.log gem5_out.log >/dev/null 2>&1 \
		&& diff apoa1.test.gem5.output ../ref/508/apoa1.test.host.ppc.output >/dev/null 2>&1 \
		&& echo $$(basename $(BENCH_PATH)) DIFF PASSED \
		|| echo $$(basename $(BENCH_PATH)) DIFF FAILED | tee -a ../fail_gem5_diff.log ; true

ls:
	find -maxdepth 1 -type f -exec ls -lFh {} \+

clean:
	rm -rf *.log *.txt

clean-all:
	find ./* ! -name Makefile -exec rm -rf {} \+

include ../TRACE.mk

checkpoints: $(EXECUTABLE)
	@echo ---------------------cpts handle $(FILE) beginning ---------------------->>$(FILE)_trace.log
	$(TIMEH) $(GEM5) $(GEM5_PY) --take-simpoint-checkpoints=$(FILE).simpts,$(FILE).weights,$(INTERVAL_SIZE),$(WARMUP_LENGTH) -c $(EXECUTABLE) -o " $(ARGS4GEM5)" >$(FILE)_checkpoints.log 2>&1
	@cat $(FILE)_checkpoints.log >> $(FILE)_trace.log
	@echo ---------------------cpts handle $(FILE) Finished ---------------------->>$(FILE)_trace.log
	@-grep -niE "FAIL|ERR|FAULT" $(FILE)_trace.log >> $(FILE)_trace_err.log ; true

restore: $(EXECUTABLE)
	@echo ---------------------rscpt handle $(FILE) beginning ---------------------->>$(FILE)_trace.log
	$(TIMEH) $(GEM5) -d ./output_ckp$(NUM_CKP) $(GEM5_PY) --restore-simpoint-checkpoint -r $(NUM_CKP) --checkpoint-dir ./m5out --restore-with-cpu=DerivO3CPU -c $(EXECUTABLE) -o " $(ARGS4GEM5)" --cpu-type=$(CPU_TYPE) $(CACHE_OPT) >$(FILE)_restore.log 2>&1
	@cat $(FILE)_restore.log >> $(FILE)_trace.log
	@echo ---------------------rscpt handle $(FILE) Finished ---------------------->>$(FILE)_trace.log
	@-grep -niE "FAIL|ERR|FAULT" $(FILE)_trace.log >> $(FILE)_trace_err.log ; true

gem5_pipeview: $(EXECUTABLE)
	@echo ---------------------gem5pv handle $(FILE) beginning ---------------------->>$(FILE)_trace.log
	tick_nums=(`grep -oP 'Entering event queue @ \d+' $(FILE)_restore.log|grep -oP '\d+'`);\
	$(TIMEG) $(GEM5) --debug-flags=O3PipeView --debug-start=$${tick_nums[0]} --debug-file=trace.out $(GEM5_PY) -c $(EXECUTABLE) -o " $(ARGS4GEM5)" $(GEM5_PY_OPT) -m $${tick_nums[-1]}
	$(GEM5_REPO_PATH)/util/o3-pipeview.py -c 500 -o pipeview.out --color m5out/trace.out
	less -r pipeview.out
	@echo ---------------------gem5pv handle $(FILE) Finished ---------------------->>$(FILE)_trace.log