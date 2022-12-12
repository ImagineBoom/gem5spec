#!/usr/bin/bash

# Run this script to fix paths after you copy ckp files from another folder.
# This is because write permission is needed in the following ckps.

FILE_LIST=(
runspec_gem5_power/511.povray_r/m5out/config.ini
runspec_gem5_power/511.povray_r/m5out/config.json
runspec_gem5_power/511.povray_r/m5out/cpt.simpoint_03_inst_135000000_weight_0.057090_interval_5000000_warmup_0/m5.cpt
runspec_gem5_power/511.povray_r/m5out/cpt.simpoint_04_inst_515000000_weight_0.162063_interval_5000000_warmup_0/m5.cpt
runspec_gem5_power/511.povray_r/m5out/cpt.simpoint_05_inst_560000000_weight_0.182320_interval_5000000_warmup_0/m5.cpt
runspec_gem5_power/511.povray_r/m5out/cpt.simpoint_06_inst_680000000_weight_0.051565_interval_5000000_warmup_0/m5.cpt
runspec_gem5_power/511.povray_r/m5out/cpt.simpoint_07_inst_950000000_weight_0.110497_interval_5000000_warmup_0/m5.cpt
runspec_gem5_power/511.povray_r/m5out/cpt.simpoint_08_inst_1465000000_weight_0.071823_interval_5000000_warmup_0/m5.cpt
runspec_gem5_power/511.povray_r/m5out/cpt.simpoint_09_inst_1520000000_weight_0.058932_interval_5000000_warmup_0/m5.cpt
runspec_gem5_power/511.povray_r/m5out/cpt.simpoint_09_inst_1520000000_weight_0.058932_interval_5000000_warmup_0/m5.cpt
runspec_gem5_power/511.povray_r/m5out/cpt.simpoint_10_inst_1710000000_weight_0.062615_interval_5000000_warmup_0/m5.cpt
runspec_gem5_power/511.povray_r/m5out/cpt.simpoint_11_inst_1755000000_weight_0.066298_interval_5000000_warmup_0/m5.cpt
runspec_gem5_power/511.povray_r/m5out/cpt.simpoint_12_inst_1850000000_weight_0.057090_interval_5000000_warmup_0/m5.cpt
runspec_gem5_power/511.povray_r/m5out/cpt.simpoint_13_inst_1970000000_weight_0.040516_interval_5000000_warmup_0/m5.cpt
runspec_gem5_power/511.povray_r/m5out/cpt.simpoint_14_inst_2555000000_weight_0.031308_interval_5000000_warmup_0/m5.cpt
runspec_gem5_power/511.povray_r/m5out/cpt.simpoint_15_inst_2620000000_weight_0.025783_interval_5000000_warmup_0/m5.cpt
runspec_gem5_power/520.omnetpp_r/m5out/config.ini
runspec_gem5_power/520.omnetpp_r/m5out/config.json
runspec_gem5_power/520.omnetpp_r/m5out/cpt.simpoint_19_inst_10355000000_weight_0.075379_interval_5000000_warmup_0/m5.cpt
runspec_gem5_power/520.omnetpp_r/m5out/cpt.simpoint_20_inst_12720000000_weight_0.054245_interval_5000000_warmup_0/m5.cpt
runspec_gem5_power/520.omnetpp_r/m5out/cpt.simpoint_21_inst_12815000000_weight_0.055653_interval_5000000_warmup_0/m5.cpt
runspec_gem5_power/520.omnetpp_r/m5out/cpt.simpoint_22_inst_13245000000_weight_0.048961_interval_5000000_warmup_0/m5.cpt
)

for F in ${FILE_LIST[*]}
do
	# Modify the origianal path where ckps are generated before doing substitution
	sed -i 's#/home/yutianhao/Dev/gem5spec_p8dev#'`pwd`'#g' $F
done

