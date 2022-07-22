DATE = $(shell date +%Y%m%d%H%M%S)
GEM5_REPO_PATH = $(shell awk '$$1=="GEM5_REPO_PATH"{print $$3}' Makefile.inc)

.PHONY: all

all: help

host: host_500 host_502 host_503 host_505 host_507 host_508 host_510 host_511 host_519 host_520 host_521 host_523 host_525 host_526 host_527 host_531 host_538 host_541 host_544 host_548 host_549 host_554 host_557 host_999

gem5: log-pre gem5_500 gem5_502 gem5_503 gem5_505 gem5_507 gem5_508 gem5_510 gem5_511 gem5_519 gem5_520 gem5_521 gem5_523 gem5_525 gem5_526 gem5_527 gem5_531 gem5_538 gem5_541 gem5_544 gem5_548 gem5_549 gem5_554 gem5_557 gem5_999
	@make log-post

trace: trace_500 trace_502 trace_503 trace_505 trace_507 trace_508 trace_510 trace_511 trace_519 trace_520 trace_521 trace_523 trace_525 trace_526 trace_527 trace_531 trace_538 trace_541 trace_544 trace_548 trace_549 trace_554 trace_557 trace_999

checkpoints: checkpoints_500 checkpoints_502 checkpoints_503 checkpoints_505 checkpoints_507 checkpoints_508 checkpoints_510 checkpoints_511 checkpoints_519 checkpoints_520 checkpoints_521 checkpoints_523 checkpoints_525 checkpoints_526 checkpoints_527 checkpoints_531 checkpoints_538 checkpoints_541 checkpoints_544 checkpoints_548 checkpoints_549 checkpoints_554 checkpoints_557 checkpoints_999

restore: restore_500 restore_502 restore_503 restore_505 restore_507 restore_508 restore_510 restore_511 restore_519 restore_520 restore_521 restore_523 restore_525 restore_526 restore_527 restore_531 restore_538 restore_541 restore_544 restore_548 restore_549 restore_554 restore_557 restore_999

log-pre:
	@LOG_DIR=$(DATE); \
	echo $(DATE) > DATE.log; \
	mkdir -p log/$${LOG_DIR}; \
	echo  $(GEM5_REPO_PATH) > log/$${LOG_DIR}/summary.txt; \
	git -C $(GEM5_REPO_PATH) log -1 --pretty=oneline >> log/$${LOG_DIR}/summary.txt; \
	echo  >> log/$${LOG_DIR}/summary.txt; \
	git -C $(GEM5_REPO_PATH) status >> log/$${LOG_DIR}/summary.txt; \
	echo  >> log/$${LOG_DIR}/summary.txt; \
	cat Makefile.inc >> log/$${LOG_DIR}/summary.txt

log-post:
	@LOG_DIR=$$(cat DATE.log); \
	mkdir -p log/$${LOG_DIR}; \
	BENCH_LIST=$$(find -maxdepth 1 -type d -regex ".*r" -exec basename {} \; | sort -h); \
	for name in $${BENCH_LIST}; do \
		[[ -e $${name}/m5out/config.ini ]] || continue; \
		mkdir -p log/$${LOG_DIR}/$${name}; \
		[[ -e $${name}/gem5_stats.log   ]] && cp $${name}/gem5_stats.log   log/$${LOG_DIR}/$${name}/; \
		[[ -e $${name}/stderr_gem5.log  ]] && cp $${name}/stderr_gem5.log  log/$${LOG_DIR}/$${name}/; \
		[[ -e $${name}/stdout_gem5.log  ]] && cp $${name}/stdout_gem5.log  log/$${LOG_DIR}/$${name}/; \
		[[ -e $${name}/m5out/config.ini ]] && cp $${name}/m5out/config.ini log/$${LOG_DIR}/$${name}/; \
	done

host_500:
	@cd  500.perlbench_r; make host || echo 500.perlbench_r >> ../fail_host.log
host_502:
	@cd  502.gcc_r; make host || echo 502.gcc_r >> ../fail_host.log
host_503:
	@cd  503.bwaves_r; make host || echo 503.bwaves_r >> ../fail_host.log
host_505:
	@cd  505.mcf_r; make host || echo 505.mcf_r >> ../fail_host.log
host_507:
	@cd  507.cactuBSSN_r; make host || echo 507.cactuBSSN_r >> ../fail_host.log
host_508:
	@cd  508.namd_r; make host || echo 508.namd_r >> ../fail_host.log
host_510:
	@cd  510.parest_r; make host || echo 510.parest_r >> ../fail_host.log
host_511:
	@cd  511.povray_r; make host || echo 511.povray_r >> ../fail_host.log
host_519:
	@cd  519.lbm_r; make host || echo 519.lbm_r >> ../fail_host.log
host_520:
	@cd  520.omnetpp_r; make host || echo 520.omnetpp_r >> ../fail_host.log
host_521:
	@cd  521.wrf_r; make host || echo 521.wrf_r >> ../fail_host.log
host_523:
	@cd  523.xalancbmk_r; make host || echo 523.xalancbmk_r >> ../fail_host.log
host_525:
	@cd  525.x264_r; make host || echo 525.x264_r >> ../fail_host.log
host_526:
	@cd  526.blender_r; make host || echo 526.blender_r >> ../fail_host.log
host_527:
	@cd  527.cam4_r; make host || echo 527.cam4_r >> ../fail_host.log
host_531:
	@cd  531.deepsjeng_r; make host || echo 531.deepsjeng_r >> ../fail_host.log
host_538:
	@cd  538.imagick_r; make host || echo 538.imagick_r >> ../fail_host.log
host_541:
	@cd  541.leela_r; make host || echo 541.leela_r >> ../fail_host.log
host_544:
	@cd  544.nab_r; make host || echo 544.nab_r >> ../fail_host.log
host_548:
	@cd  548.exchange2_r; make host || echo 548.exchange2_r >> ../fail_host.log
host_549:
	@cd  549.fotonik3d_r; make host || echo 549.fotonik3d_r >> ../fail_host.log
host_554:
	@cd  554.roms_r; make host || echo 554.roms_r >> ../fail_host.log
host_557:
	@cd  557.xz_r; make host || echo 557.xz_r >> ../fail_host.log
host_999:
	@cd  999.specrand_ir; make host || echo 999.specrand_ir >> ../fail_host.log

gem5_500:
	@-make gem5 -C 500.perlbench_r
gem5_502:
	@-make gem5 -C 502.gcc_r
gem5_503:
	@-make gem5 -C 503.bwaves_r
gem5_505:
	@-make gem5 -C 505.mcf_r
gem5_507:
	@-make gem5 -C 507.cactuBSSN_r
gem5_508:
	@-make gem5 -C 508.namd_r
gem5_510:
	@-make gem5 -C 510.parest_r
gem5_511:
	@-make gem5 -C 511.povray_r
gem5_519:
	@-make gem5 -C 519.lbm_r
gem5_520:
	@-make gem5 -C 520.omnetpp_r
gem5_521:
	@-make gem5 -C 521.wrf_r
gem5_523:
	@-make gem5 -C 523.xalancbmk_r
gem5_525:
	@-make gem5 -C 525.x264_r
gem5_526:
	@-make gem5 -C 526.blender_r
gem5_527:
	@-make gem5 -C 527.cam4_r
gem5_531:
	@-make gem5 -C 531.deepsjeng_r
gem5_538:
	@-make gem5 -C 538.imagick_r
gem5_541:
	@-make gem5 -C 541.leela_r
gem5_544:
	@-make gem5 -C 544.nab_r
gem5_548:
	@-make gem5 -C 548.exchange2_r
gem5_549:
	@-make gem5 -C 549.fotonik3d_r
gem5_554:
	@-make gem5 -C 554.roms_r
gem5_557:
	@-make gem5 -C 557.xz_r
gem5_999:
	@-make gem5 -C 999.specrand_ir

inst_count:
	@- nohup make inst_count -C 500.perlbench_r &
	@- nohup make inst_count -C 502.gcc_r       &
	@- nohup make inst_count -C 503.bwaves_r    &
	@- nohup make inst_count -C 505.mcf_r       &
	@- nohup make inst_count -C 507.cactuBSSN_r &
	@- nohup make inst_count -C 508.namd_r      &
	@- nohup make inst_count -C 510.parest_r    &
	@- nohup make inst_count -C 511.povray_r    &
	@- nohup make inst_count -C 519.lbm_r       &
	@- nohup make inst_count -C 520.omnetpp_r   &
	@- nohup make inst_count -C 521.wrf_r       &
	@- nohup make inst_count -C 523.xalancbmk_r &
	@- nohup make inst_count -C 525.x264_r      &
	@- nohup make inst_count -C 526.blender_r   &
	@- nohup make inst_count -C 527.cam4_r      &
	@- nohup make inst_count -C 531.deepsjeng_r &
	@- nohup make inst_count -C 538.imagick_r   &
	@- nohup make inst_count -C 541.leela_r     &
	@- nohup make inst_count -C 544.nab_r       &
	@- nohup make inst_count -C 548.exchange2_r &
	@- nohup make inst_count -C 549.fotonik3d_r &
	@- nohup make inst_count -C 554.roms_r      &
	@- nohup make inst_count -C 557.xz_r        &
	@- nohup make inst_count -C 999.specrand_ir &

trace_500:
	@-make trace -C 500.perlbench_r
trace_502:
	@-make trace -C 502.gcc_r
trace_503:
	@-make trace -C 503.bwaves_r
trace_505:
	@-make trace -C 505.mcf_r
trace_507:
	@-make trace -C 507.cactuBSSN_r
trace_508:
	@-make trace -C 508.namd_r
trace_510:
	@-make trace -C 510.parest_r
trace_511:
	@-make trace -C 511.povray_r
trace_519:
	@-make trace -C 519.lbm_r
trace_520:
	@-make trace -C 520.omnetpp_r
trace_521:
	@-make trace -C 521.wrf_r
trace_523:
	@-make trace -C 523.xalancbmk_r
trace_525:
	@-make trace -C 525.x264_r
trace_526:
	@-make trace -C 526.blender_r
trace_527:
	@-make trace -C 527.cam4_r
trace_531:
	@-make trace -C 531.deepsjeng_r
trace_538:
	@-make trace -C 538.imagick_r
trace_541:
	@-make trace -C 541.leela_r
trace_544:
	@-make trace -C 544.nab_r
trace_548:
	@-make trace -C 548.exchange2_r
trace_549:
	@-make trace -C 549.fotonik3d_r
trace_554:
	@-make trace -C 554.roms_r
trace_557:
	@-make trace -C 557.xz_r
trace_999:
	@-make trace -C 999.specrand_ir


simpoint_500:
	@-make simpoint -C 500.perlbench_r
simpoint_502:
	@-make simpoint -C 502.gcc_r
simpoint_503:
	@-make simpoint -C 503.bwaves_r
simpoint_505:
	@-make simpoint -C 505.mcf_r
simpoint_507:
	@-make simpoint -C 507.cactuBSSN_r
simpoint_508:
	@-make simpoint -C 508.namd_r
simpoint_510:
	@-make simpoint -C 510.parest_r
simpoint_511:
	@-make simpoint -C 511.povray_r
simpoint_519:
	@-make simpoint -C 519.lbm_r
simpoint_520:
	@-make simpoint -C 520.omnetpp_r
simpoint_521:
	@-make simpoint -C 521.wrf_r
simpoint_523:
	@-make simpoint -C 523.xalancbmk_r
simpoint_525:
	@-make simpoint -C 525.x264_r
simpoint_526:
	@-make simpoint -C 526.blender_r
simpoint_527:
	@-make simpoint -C 527.cam4_r
simpoint_531:
	@-make simpoint -C 531.deepsjeng_r
simpoint_538:
	@-make simpoint -C 538.imagick_r
simpoint_541:
	@-make simpoint -C 541.leela_r
simpoint_544:
	@-make simpoint -C 544.nab_r
simpoint_548:
	@-make simpoint -C 548.exchange2_r
simpoint_549:
	@-make simpoint -C 549.fotonik3d_r
simpoint_554:
	@-make simpoint -C 554.roms_r
simpoint_557:
	@-make simpoint -C 557.xz_r
simpoint_999:
	@-make simpoint -C 999.specrand_ir


checkpoints_500:simpoint_500
	@-make checkpoints -C 500.perlbench_r
checkpoints_502:simpoint_502
	@-make checkpoints -C 502.gcc_r
checkpoints_503:simpoint_503
	@-make checkpoints -C 503.bwaves_r
checkpoints_505:simpoint_505
	@-make checkpoints -C 505.mcf_r
checkpoints_507:simpoint_507
	@-make checkpoints -C 507.cactuBSSN_r
checkpoints_508:simpoint_508
	@-make checkpoints -C 508.namd_r
checkpoints_510:simpoint_510
	@-make checkpoints -C 510.parest_r
checkpoints_511:simpoint_511
	@-make checkpoints -C 511.povray_r
checkpoints_519:simpoint_519
	@-make checkpoints -C 519.lbm_r
checkpoints_520:simpoint_520
	@-make checkpoints -C 520.omnetpp_r
checkpoints_521:simpoint_521
	@-make checkpoints -C 521.wrf_r
checkpoints_523:simpoint_523
	@-make checkpoints -C 523.xalancbmk_r
checkpoints_525:simpoint_525
	@-make checkpoints -C 525.x264_r
checkpoints_526:simpoint_526
	@-make checkpoints -C 526.blender_r
checkpoints_527:simpoint_527
	@-make checkpoints -C 527.cam4_r
checkpoints_531:simpoint_531
	@-make checkpoints -C 531.deepsjeng_r
checkpoints_538:simpoint_538
	@-make checkpoints -C 538.imagick_r
checkpoints_541:simpoint_541
	@-make checkpoints -C 541.leela_r
checkpoints_544:simpoint_544
	@-make checkpoints -C 544.nab_r
checkpoints_548:simpoint_548
	@-make checkpoints -C 548.exchange2_r
checkpoints_549:simpoint_549
	@-make checkpoints -C 549.fotonik3d_r
checkpoints_554:simpoint_554
	@-make checkpoints -C 554.roms_r
checkpoints_557:simpoint_557
	@-make checkpoints -C 557.xz_r
checkpoints_999:simpoint_999
	@-make checkpoints -C 999.specrand_ir

restore_500:
	@-make restore -C 500.perlbench_r
restore_502:
	@-make restore -C 502.gcc_r
restore_503:
	@-make restore -C 503.bwaves_r
restore_505:
	@-make restore -C 505.mcf_r
restore_507:
	@-make restore -C 507.cactuBSSN_r
restore_508:
	@-make restore -C 508.namd_r
restore_510:
	@-make restore -C 510.parest_r
restore_511:
	@-make restore -C 511.povray_r
restore_519:
	@-make restore -C 519.lbm_r
restore_520:
	@-make restore -C 520.omnetpp_r
restore_521:
	@-make restore -C 521.wrf_r
restore_523:
	@-make restore -C 523.xalancbmk_r
restore_525:
	@-make restore -C 525.x264_r
restore_526:
	@-make restore -C 526.blender_r
restore_527:
	@-make restore -C 527.cam4_r
restore_531:
	@-make restore -C 531.deepsjeng_r
restore_538:
	@-make restore -C 538.imagick_r
restore_541:
	@-make restore -C 541.leela_r
restore_544:
	@-make restore -C 544.nab_r
restore_548:
	@-make restore -C 548.exchange2_r
restore_549:
	@-make restore -C 549.fotonik3d_r
restore_554:
	@-make restore -C 554.roms_r
restore_557:
	@-make restore -C 557.xz_r
restore_999:
	@-make restore -C 999.specrand_ir

diff:
	find -maxdepth 1 -type d -regex ".*r" -exec make diff -C {} \;

clean:
	rm -rf *.log
	find -maxdepth 1 -type d -regex ".*r" -exec make clean -C {} \;

clean-all:
	rm -rf *.log
	find -maxdepth 1 -type d -regex ".*r" -exec make clean-all -C {} \;

time:
	@echo grep -nr "^Host Consumed Time:"
	@grep -nr "^Host Consumed Time:" | sort -h| sed "s/\..\+: /,/g" || true
	@echo grep -nr "^GEM5 Consumed Time:"
	@grep -nr "^GEM5 Consumed Time:" | sort -h| sed "s/\..\+: /,/g" || true

help:
	@echo "Modify SPEC and GEM5 path in Makefile.inc before run!"
	@echo "Use -jN to run multiple benchmarks in parallel"
	@echo ""
	@echo "  Run all SPEC on host:"
	@echo "    make host -jN"
	@echo "  Run all SPEC via GEM5:"
	@echo "    make gem5 -jN"
	@echo "  Clean log and temp files:"
	@echo "    make clean"
	@echo "  Clean all except Makefile:"
	@echo "    make clean-all"
	@echo "  Get consumed runtime:"
	@echo "    make time"
	@echo ""
	@echo "Check fail_[host|gem5].log to see failed benchmarks."
	@echo ""

cpi-all:
	@find ./*/*.csv -exec basename {} \; | awk -F"[_]" '{print $$1,$$5}' > weightedCPI_results.log 
	@sed -i 's/.csv//' weightedCPI_results.log;
	@awk -F, 'NR==1 {print "SpecCase#","WeightedCPI"} {print $$1,$$2}' weightedCPI_results.log | column -t > weightedCPI_results.csv;
	@rm -rf weightedCPI_results.log;
	@gedit weightedCPI_results.csv;