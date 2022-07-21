#!/bin/bash

FILE=$4

	case $FILE in
	502.gcc_r)
		interval_size=(300000 500000)
		;;
	500.perlbench_r)
		interval_size=(500)
		;;
	503.bwaves_r)
		interval_size=(503)
		;;
	505.mcf_r)
		interval_size=(505)
		;;
	507.cactuBSSN_r)
		interval_size=(507)
		;;
	508.namd_r)
		interval_size=(508)
		;;
	510.parest_r)
		interval_size=(510)
		;;
	511.povray_r)
		interval_size=(511)
		;;
	519.lbm_r)
		interval_size=(519)
		;;
	520.omnetpp_r)
		interval_size=(520)
		;;
	521.wrf_r)
		interval_size=(521)
		;;
	523.xalancbmk_r)
		interval_size=(523)
		;;
	525.x264_r)
		interval_size=(525)
		;;
	526.blender_r)
		interval_size=(526)
		;;
	527.cam4_r)
		interval_size=(527)
		;;
	531.deepsjeng_r)
		interval_size=(531)
		;;
	538.imagick_r)
		interval_size=(538)
		;;
	541.leela_r)
		interval_size=(541)
		;;
	544.nab_r)
		interval_size=(544)
		;;
	548.exchange2_r)
		interval_size=(548)
		;;
	549.fotonik3d_r)
		interval_size=(549)
		;;
	554.roms_r)
		interval_size=(554)
		;;
	557.xz_r)
		interval_size=(557)
		;;
	999.specrand_ir)
		interval_size=(999)
		;;
	*)
		interval_size=()

	esac


