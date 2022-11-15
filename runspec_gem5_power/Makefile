DATE = $(shell date +%Y%m%d%H%M%S)
GEM5_REPO_PATH ?= $(shell awk '$$1=="GEM5_REPO_PATH"{print $$3}' Makefile.inc)

.PHONY: all

all: help

host: host_500 host_502 host_503 host_505 host_507 host_508 host_510 host_511 host_519 host_520 host_521 host_523 host_525 host_526 host_527 host_531 host_538 host_541 host_544 host_548 host_549 host_554 host_557 host_999

gem5: log-pre gem5_500 gem5_502 gem5_503 gem5_505 gem5_507 gem5_508 gem5_510 gem5_511 gem5_519 gem5_520 gem5_521 gem5_523 gem5_525 gem5_526 gem5_527 gem5_531 gem5_538 gem5_541 gem5_544 gem5_548 gem5_549 gem5_554 gem5_557 gem5_999
	@make log-post

trace: trace_500 trace_502 trace_503 trace_505 trace_507 trace_508 trace_510 trace_511 trace_519 trace_520 trace_521 trace_523 trace_525 trace_526 trace_527 trace_531 trace_538 trace_541 trace_544 trace_548 trace_549 trace_554 trace_557 trace_999

simpoints_all_cases: simpoint_500 simpoint_502 simpoint_503 simpoint_505 simpoint_507 simpoint_508 simpoint_510 simpoint_511 simpoint_519 simpoint_520 simpoint_521 simpoint_523 simpoint_525 simpoint_526 simpoint_527 simpoint_531 simpoint_538 simpoint_541 simpoint_544 simpoint_548 simpoint_549 simpoint_554 simpoint_557 simpoint_999

checkpoints_all_cases: checkpoints_500 checkpoints_502 checkpoints_503 checkpoints_505 checkpoints_507 checkpoints_508 checkpoints_510 checkpoints_511 checkpoints_519 checkpoints_520 checkpoints_521 checkpoints_523 checkpoints_525 checkpoints_526 checkpoints_527 checkpoints_531 checkpoints_538 checkpoints_541 checkpoints_544 checkpoints_548 checkpoints_549 checkpoints_554 checkpoints_557 checkpoints_999

checkpoints_all_cases_2: checkpoints_500_2 checkpoints_502_2 checkpoints_503_2 checkpoints_505_2 checkpoints_507_2 checkpoints_508_2 checkpoints_510_2 checkpoints_511_2 checkpoints_519_2 checkpoints_520_2 checkpoints_521_2 checkpoints_523_2 checkpoints_525_2 checkpoints_526_2 checkpoints_527_2 checkpoints_531_2 checkpoints_538_2 checkpoints_541_2 checkpoints_544_2 checkpoints_548_2 checkpoints_549_2 checkpoints_554_2 checkpoints_557_2 checkpoints_999_2

checkpoints_all_cases_4: checkpoints_500_4 checkpoints_502_4 checkpoints_503_4 checkpoints_505_4 checkpoints_507_4 checkpoints_508_4 checkpoints_510_4 checkpoints_511_4 checkpoints_519_4 checkpoints_520_4 checkpoints_521_4 checkpoints_523_4 checkpoints_525_4 checkpoints_526_4 checkpoints_527_4 checkpoints_531_4 checkpoints_538_4 checkpoints_541_4 checkpoints_544_4 checkpoints_548_4 checkpoints_549_4 checkpoints_554_4 checkpoints_557_4 checkpoints_999_4

checkpoints_all_cases_8: checkpoints_500_8 checkpoints_502_8 checkpoints_503_8 checkpoints_505_8 checkpoints_507_8 checkpoints_508_8 checkpoints_510_8 checkpoints_511_8 checkpoints_519_8 checkpoints_520_8 checkpoints_521_8 checkpoints_523_8 checkpoints_525_8 checkpoints_526_8 checkpoints_527_8 checkpoints_531_8 checkpoints_538_8 checkpoints_541_8 checkpoints_544_8 checkpoints_548_8 checkpoints_549_8 checkpoints_554_8 checkpoints_557_8 checkpoints_999_8

restore_all_cases: restore_all_500 restore_all_502 restore_all_503 restore_all_505 restore_all_507 restore_all_508 restore_all_510 restore_all_511 restore_all_519 restore_all_520 restore_all_521 restore_all_523 restore_all_525 restore_all_526 restore_all_527 restore_all_531 restore_all_538 restore_all_541 restore_all_544 restore_all_548 restore_all_549 restore_all_554 restore_all_557 restore_all_999

cpi_all_cases: cpi_500 cpi_502 cpi_503 cpi_505 cpi_507 cpi_508 cpi_510 cpi_511 cpi_519 cpi_520 cpi_521 cpi_523 cpi_525 cpi_526 cpi_527 cpi_531 cpi_538 cpi_541 cpi_544 cpi_548 cpi_549 cpi_554 cpi_557 cpi_999

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


checkpoints_500:
	@-make checkpoints -C 500.perlbench_r
checkpoints_502:
	@-make checkpoints -C 502.gcc_r
checkpoints_503:
	@-make checkpoints -C 503.bwaves_r
checkpoints_505:
	@-make checkpoints -C 505.mcf_r
checkpoints_507:
	@-make checkpoints -C 507.cactuBSSN_r
checkpoints_508:
	@-make checkpoints -C 508.namd_r
checkpoints_510:
	@-make checkpoints -C 510.parest_r
checkpoints_511:
	@-make checkpoints -C 511.povray_r
checkpoints_519:
	@-make checkpoints -C 519.lbm_r
checkpoints_520:
	@-make checkpoints -C 520.omnetpp_r
checkpoints_521:
	@-make checkpoints -C 521.wrf_r
checkpoints_523:
	@-make checkpoints -C 523.xalancbmk_r
checkpoints_525:
	@-make checkpoints -C 525.x264_r
checkpoints_526:
	@-make checkpoints -C 526.blender_r
checkpoints_527:
	@-make checkpoints -C 527.cam4_r
checkpoints_531:
	@-make checkpoints -C 531.deepsjeng_r
checkpoints_538:
	@-make checkpoints -C 538.imagick_r
checkpoints_541:
	@-make checkpoints -C 541.leela_r
checkpoints_544:
	@-make checkpoints -C 544.nab_r
checkpoints_548:
	@-make checkpoints -C 548.exchange2_r
checkpoints_549:
	@-make checkpoints -C 549.fotonik3d_r
checkpoints_554:
	@-make checkpoints -C 554.roms_r
checkpoints_557:
	@-make checkpoints -C 557.xz_r
checkpoints_999:
	@-make checkpoints -C 999.specrand_ir

checkpoints_500_2:
	@-make checkpoints_2 -C 500.perlbench_r
checkpoints_502_2:
	@-make checkpoints_2 -C 502.gcc_r
checkpoints_503_2:
	@-make checkpoints_2 -C 503.bwaves_r
checkpoints_505_2:
	@-make checkpoints_2 -C 505.mcf_r
checkpoints_507_2:
	@-make checkpoints_2 -C 507.cactuBSSN_r
checkpoints_508_2:
	@-make checkpoints_2 -C 508.namd_r
checkpoints_510_2:
	@-make checkpoints_2 -C 510.parest_r
checkpoints_511_2:
	@-make checkpoints_2 -C 511.povray_r
checkpoints_519_2:
	@-make checkpoints_2 -C 519.lbm_r
checkpoints_520_2:
	@-make checkpoints_2 -C 520.omnetpp_r
checkpoints_521_2:
	@-make checkpoints_2 -C 521.wrf_r
checkpoints_523_2:
	@-make checkpoints_2 -C 523.xalancbmk_r
checkpoints_525_2:
	@-make checkpoints_2 -C 525.x264_r
checkpoints_526_2:
	@-make checkpoints_2 -C 526.blender_r
checkpoints_527_2:
	@-make checkpoints_2 -C 527.cam4_r
checkpoints_531_2:
	@-make checkpoints_2 -C 531.deepsjeng_r
checkpoints_538_2:
	@-make checkpoints_2 -C 538.imagick_r
checkpoints_541_2:
	@-make checkpoints_2 -C 541.leela_r
checkpoints_544_2:
	@-make checkpoints_2 -C 544.nab_r
checkpoints_548_2:
	@-make checkpoints_2 -C 548.exchange2_r
checkpoints_549_2:
	@-make checkpoints_2 -C 549.fotonik3d_r
checkpoints_554_2:
	@-make checkpoints_2 -C 554.roms_r
checkpoints_557_2:
	@-make checkpoints_2 -C 557.xz_r
checkpoints_999_2:
	@-make checkpoints_2 -C 999.specrand_ir

checkpoints_500_4:
	@-make checkpoints_4 -C 500.perlbench_r
checkpoints_502_4:
	@-make checkpoints_4 -C 502.gcc_r
checkpoints_503_4:
	@-make checkpoints_4 -C 503.bwaves_r
checkpoints_505_4:
	@-make checkpoints_4 -C 505.mcf_r
checkpoints_507_4:
	@-make checkpoints_4 -C 507.cactuBSSN_r
checkpoints_508_4:
	@-make checkpoints_4 -C 508.namd_r
checkpoints_510_4:
	@-make checkpoints_4 -C 510.parest_r
checkpoints_511_4:
	@-make checkpoints_4 -C 511.povray_r
checkpoints_519_4:
	@-make checkpoints_4 -C 519.lbm_r
checkpoints_520_4:
	@-make checkpoints_4 -C 520.omnetpp_r
checkpoints_521_4:
	@-make checkpoints_4 -C 521.wrf_r
checkpoints_523_4:
	@-make checkpoints_4 -C 523.xalancbmk_r
checkpoints_525_4:
	@-make checkpoints_4 -C 525.x264_r
checkpoints_526_4:
	@-make checkpoints_4 -C 526.blender_r
checkpoints_527_4:
	@-make checkpoints_4 -C 527.cam4_r
checkpoints_531_4:
	@-make checkpoints_4 -C 531.deepsjeng_r
checkpoints_538_4:
	@-make checkpoints_4 -C 538.imagick_r
checkpoints_541_4:
	@-make checkpoints_4 -C 541.leela_r
checkpoints_544_4:
	@-make checkpoints_4 -C 544.nab_r
checkpoints_548_4:
	@-make checkpoints_4 -C 548.exchange2_r
checkpoints_549_4:
	@-make checkpoints_4 -C 549.fotonik3d_r
checkpoints_554_4:
	@-make checkpoints_4 -C 554.roms_r
checkpoints_557_4:
	@-make checkpoints_4 -C 557.xz_r
checkpoints_999_4:
	@-make checkpoints_4 -C 999.specrand_ir

checkpoints_500_8:
	@-make checkpoints_8 -C 500.perlbench_r
checkpoints_502_8:
	@-make checkpoints_8 -C 502.gcc_r
checkpoints_503_8:
	@-make checkpoints_8 -C 503.bwaves_r
checkpoints_505_8:
	@-make checkpoints_8 -C 505.mcf_r
checkpoints_507_8:
	@-make checkpoints_8 -C 507.cactuBSSN_r
checkpoints_508_8:
	@-make checkpoints_8 -C 508.namd_r
checkpoints_510_8:
	@-make checkpoints_8 -C 510.parest_r
checkpoints_511_8:
	@-make checkpoints_8 -C 511.povray_r
checkpoints_519_8:
	@-make checkpoints_8 -C 519.lbm_r
checkpoints_520_8:
	@-make checkpoints_8 -C 520.omnetpp_r
checkpoints_521_8:
	@-make checkpoints_8 -C 521.wrf_r
checkpoints_523_8:
	@-make checkpoints_8 -C 523.xalancbmk_r
checkpoints_525_8:
	@-make checkpoints_8 -C 525.x264_r
checkpoints_526_8:
	@-make checkpoints_8 -C 526.blender_r
checkpoints_527_8:
	@-make checkpoints_8 -C 527.cam4_r
checkpoints_531_8:
	@-make checkpoints_8 -C 531.deepsjeng_r
checkpoints_538_8:
	@-make checkpoints_8 -C 538.imagick_r
checkpoints_541_8:
	@-make checkpoints_8 -C 541.leela_r
checkpoints_544_8:
	@-make checkpoints_8 -C 544.nab_r
checkpoints_548_8:
	@-make checkpoints_8 -C 548.exchange2_r
checkpoints_549_8:
	@-make checkpoints_8 -C 549.fotonik3d_r
checkpoints_554_8:
	@-make checkpoints_8 -C 554.roms_r
checkpoints_557_8:
	@-make checkpoints_8 -C 557.xz_r
checkpoints_999_8:
	@-make checkpoints_8 -C 999.specrand_ir

restore_all_500:
	@-make restore_all -C 500.perlbench_r
restore_all_502:
	@-make restore_all -C 502.gcc_r
restore_all_503:
	@-make restore_all -C 503.bwaves_r
restore_all_505:
	@-make restore_all -C 505.mcf_r
restore_all_507:
	@-make restore_all -C 507.cactuBSSN_r
restore_all_508:
	@-make restore_all -C 508.namd_r
restore_all_510:
	@-make restore_all -C 510.parest_r
restore_all_511:
	@-make restore_all -C 511.povray_r
restore_all_519:
	@-make restore_all -C 519.lbm_r
restore_all_520:
	@-make restore_all -C 520.omnetpp_r
restore_all_521:
	@-make restore_all -C 521.wrf_r
restore_all_523:
	@-make restore_all -C 523.xalancbmk_r
restore_all_525:
	@-make restore_all -C 525.x264_r
restore_all_526:
	@-make restore_all -C 526.blender_r
restore_all_527:
	@-make restore_all -C 527.cam4_r
restore_all_531:
	@-make restore_all -C 531.deepsjeng_r
restore_all_538:
	@-make restore_all -C 538.imagick_r
restore_all_541:
	@-make restore_all -C 541.leela_r
restore_all_544:
	@-make restore_all -C 544.nab_r
restore_all_548:
	@-make restore_all -C 548.exchange2_r
restore_all_549:
	@-make restore_all -C 549.fotonik3d_r
restore_all_554:
	@-make restore_all -C 554.roms_r
restore_all_557:
	@-make restore_all -C 557.xz_r
restore_all_999:
	@-make restore_all -C 999.specrand_ir

diff:
	find -maxdepth 1 -type d -regex ".*r" -exec make diff -C {} \;

clean:
	rm -rf *.log
	find -maxdepth 1 -type d -regex ".*r" -exec make clean -C {} \;

clean-all:
	rm -rf *.log
	find -maxdepth 1 -type d -regex ".*r" -exec make clean-all -C {} \;

clean-simpoint:
	rm -rf ./*/*bbv ./*/*gem5_bbv.log ./*/*merge ./*/*simpoint.log ./*/*simpts ./*/*weights ./*/*trace*

clean-checkpoint:
	rm -rf ./*/*checkpoints.log ./*/m5out

clean-restore:
	rm -rf ./*/*restore* ./*/output* ./*/*CKPS_CPI.log ./*/*csv ./*/*Weighted_CPI.log ./*/*RS_NUM.log

clean-result:
	rm -rf ./*.csv ./restore_all_consumed_time.log

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


cpi_500:
	@-make cpi -C 500.perlbench_r
cpi_502:
	@-make cpi -C 502.gcc_r
cpi_503:
	@-make cpi -C 503.bwaves_r
cpi_505:
	@-make cpi -C 505.mcf_r
cpi_507:
	@-make cpi -C 507.cactuBSSN_r
cpi_508:
	@-make cpi -C 508.namd_r
cpi_510:
	@-make cpi -C 510.parest_r
cpi_511:
	@-make cpi -C 511.povray_r
cpi_519:
	@-make cpi -C 519.lbm_r
cpi_520:
	@-make cpi -C 520.omnetpp_r
cpi_521:
	@-make cpi -C 521.wrf_r
cpi_523:
	@-make cpi -C 523.xalancbmk_r
cpi_525:
	@-make cpi -C 525.x264_r
cpi_526:
	@-make cpi -C 526.blender_r
cpi_527:
	@-make cpi -C 527.cam4_r
cpi_531:
	@-make cpi -C 531.deepsjeng_r
cpi_538:
	@-make cpi -C 538.imagick_r
cpi_541:
	@-make cpi -C 541.leela_r
cpi_544:
	@-make cpi -C 544.nab_r
cpi_548:
	@-make cpi -C 548.exchange2_r
cpi_549:
	@-make cpi -C 549.fotonik3d_r
cpi_554:
	@-make cpi -C 554.roms_r
cpi_557:
	@-make cpi -C 557.xz_r
cpi_999:
	@-make cpi -C 999.specrand_ir

collect_all_cases_CPI:
	@find ./*/*.csv -exec basename {} \; | awk -F"[_]" '{print $$1,$$5}' > weightedCPI_results.log;
	@sed -i 's/.csv//' weightedCPI_results.log;
	@awk 'NR==1 {OFS=",";print "SpecCase#","WeightedCPI"} {OFS=",";print $$1,$$2}' weightedCPI_results.log > All_case_weightedCPI.csv;
	@rm -rf weightedCPI_results.log;
	@gedit All_case_weightedCPI.csv &

collect_all_checkpoints_data:
	@rm -rf ./Each_case_ckp_data.csv;
	@cat ./500*/*.csv >> ./Each_case_ckp_data.csv;
	@cat ./502*/*.csv >> ./Each_case_ckp_data.csv;
	@cat ./505*/*.csv >> ./Each_case_ckp_data.csv;
	@cat ./520*/*.csv >> ./Each_case_ckp_data.csv;
	@cat ./523*/*.csv >> ./Each_case_ckp_data.csv;
	@cat ./525*/*.csv >> ./Each_case_ckp_data.csv;
	@cat ./531*/*.csv >> ./Each_case_ckp_data.csv;
	@cat ./541*/*.csv >> ./Each_case_ckp_data.csv;
	@cat ./548*/*.csv >> ./Each_case_ckp_data.csv;
	@cat ./557*/*.csv >> ./Each_case_ckp_data.csv;
	@cat ./503*/*.csv >> ./Each_case_ckp_data.csv;
	@cat ./507*/*.csv >> ./Each_case_ckp_data.csv;
	@cat ./508*/*.csv >> ./Each_case_ckp_data.csv;
	@cat ./510*/*.csv >> ./Each_case_ckp_data.csv;
	@cat ./511*/*.csv >> ./Each_case_ckp_data.csv;
	@cat ./519*/*.csv >> ./Each_case_ckp_data.csv;
	@cat ./521*/*.csv >> ./Each_case_ckp_data.csv;
	@cat ./526*/*.csv >> ./Each_case_ckp_data.csv;
	@cat ./527*/*.csv >> ./Each_case_ckp_data.csv;
	@cat ./538*/*.csv >> ./Each_case_ckp_data.csv;
	@cat ./544*/*.csv >> ./Each_case_ckp_data.csv;
	@cat ./549*/*.csv >> ./Each_case_ckp_data.csv;
	@cat ./554*/*.csv >> ./Each_case_ckp_data.csv;
	@cat ./999*/*.csv >> ./Each_case_ckp_data.csv;
	#@gedit ./Each_case_ckp_data.csv &

collect_checkpoints_number:
	@find ./*/*.merge -exec basename {} \; | awk -F"[_]" '{print $$1}' > temp1.log;
	@sed -i '$$a Total' temp1.log;
	@wc -l ./*/*.merge | awk '{print $$1}' > temp2.log;
	@paste temp1.log temp2.log > temp.log;
	@awk 'NR==1 {OFS=",";print "SpecCase#","Checkpoints#"} {OFS=",";print $$1,$$2}' temp.log > Checkpoint_Num.csv;
	@rm -rf temp*;
	@gedit Checkpoint_Num.csv &

classify_result:
	@rm -rf ./Sort_All_case_weightedCPI.csv;
	@find ./500*/*.csv -exec basename {} \; | awk -F"[_]" '{print $$1,$$5}' >> ./Sort_All_case_weightedCPI.csv;
	@find ./502*/*.csv -exec basename {} \; | awk -F"[_]" '{print $$1,$$5}' >> ./Sort_All_case_weightedCPI.csv;
	@find ./505*/*.csv -exec basename {} \; | awk -F"[_]" '{print $$1,$$5}' >> ./Sort_All_case_weightedCPI.csv;
	@find ./520*/*.csv -exec basename {} \; | awk -F"[_]" '{print $$1,$$5}' >> ./Sort_All_case_weightedCPI.csv;
	@find ./523*/*.csv -exec basename {} \; | awk -F"[_]" '{print $$1,$$5}' >> ./Sort_All_case_weightedCPI.csv;
	@find ./525*/*.csv -exec basename {} \; | awk -F"[_]" '{print $$1,$$5}' >> ./Sort_All_case_weightedCPI.csv;
	@find ./531*/*.csv -exec basename {} \; | awk -F"[_]" '{print $$1,$$5}' >> ./Sort_All_case_weightedCPI.csv;
	@find ./541*/*.csv -exec basename {} \; | awk -F"[_]" '{print $$1,$$5}' >> ./Sort_All_case_weightedCPI.csv;
	@find ./548*/*.csv -exec basename {} \; | awk -F"[_]" '{print $$1,$$5}' >> ./Sort_All_case_weightedCPI.csv;
	@find ./557*/*.csv -exec basename {} \; | awk -F"[_]" '{print $$1,$$5}' >> ./Sort_All_case_weightedCPI.csv;
	@find ./503*/*.csv -exec basename {} \; | awk -F"[_]" '{print $$1,$$5}' >> ./Sort_All_case_weightedCPI.csv;
	@find ./507*/*.csv -exec basename {} \; | awk -F"[_]" '{print $$1,$$5}' >> ./Sort_All_case_weightedCPI.csv;
	@find ./508*/*.csv -exec basename {} \; | awk -F"[_]" '{print $$1,$$5}' >> ./Sort_All_case_weightedCPI.csv;
	@find ./510*/*.csv -exec basename {} \; | awk -F"[_]" '{print $$1,$$5}' >> ./Sort_All_case_weightedCPI.csv;
	@find ./511*/*.csv -exec basename {} \; | awk -F"[_]" '{print $$1,$$5}' >> ./Sort_All_case_weightedCPI.csv;
	@find ./519*/*.csv -exec basename {} \; | awk -F"[_]" '{print $$1,$$5}' >> ./Sort_All_case_weightedCPI.csv;
	@find ./521*/*.csv -exec basename {} \; | awk -F"[_]" '{print $$1,$$5}' >> ./Sort_All_case_weightedCPI.csv;
	@find ./526*/*.csv -exec basename {} \; | awk -F"[_]" '{print $$1,$$5}' >> ./Sort_All_case_weightedCPI.csv;
	@find ./527*/*.csv -exec basename {} \; | awk -F"[_]" '{print $$1,$$5}' >> ./Sort_All_case_weightedCPI.csv;
	@find ./538*/*.csv -exec basename {} \; | awk -F"[_]" '{print $$1,$$5}' >> ./Sort_All_case_weightedCPI.csv;
	@find ./544*/*.csv -exec basename {} \; | awk -F"[_]" '{print $$1,$$5}' >> ./Sort_All_case_weightedCPI.csv;
	@find ./549*/*.csv -exec basename {} \; | awk -F"[_]" '{print $$1,$$5}' >> ./Sort_All_case_weightedCPI.csv;
	@find ./554*/*.csv -exec basename {} \; | awk -F"[_]" '{print $$1,$$5}' >> ./Sort_All_case_weightedCPI.csv;
	@find ./999*/*.csv -exec basename {} \; | awk -F"[_]" '{print $$1,$$5}' >> ./Sort_All_case_weightedCPI.csv;
	@sed -i 's/ /,/' ./Sort_All_case_weightedCPI.csv;
	@sed -i '1i "SpecCase#","Checkpoints#"' ./Sort_All_case_weightedCPI.csv;
	@gedit ./Sort_All_case_weightedCPI.csv &