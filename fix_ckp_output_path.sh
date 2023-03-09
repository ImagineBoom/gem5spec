#!/usr/bin/bash

# Run this script to fix paths if you copied ckp files from another folder.
# This is because write permission is needed in the following ckps.

# EDIT this variable before run. This is the original path where CKPs are genarated.
original_path=/home/yutianhao/Dev/gem5spec_final_test


# Update this file list if simpoint is updated.
FILE_LIST=(
runspec_gem5_power/511.povray_r/m5out/config.ini
runspec_gem5_power/511.povray_r/m5out/config.json
runspec_gem5_power/511.povray_r/m5out/cpt.simpoint_03_inst_134000000_weight_0.057090_interval_5000000_warmup_1000000/m5.cpt
runspec_gem5_power/511.povray_r/m5out/cpt.simpoint_04_inst_514000000_weight_0.162063_interval_5000000_warmup_1000000/m5.cpt
runspec_gem5_power/511.povray_r/m5out/cpt.simpoint_05_inst_559000000_weight_0.182320_interval_5000000_warmup_1000000/m5.cpt
runspec_gem5_power/511.povray_r/m5out/cpt.simpoint_06_inst_679000000_weight_0.051565_interval_5000000_warmup_1000000/m5.cpt
runspec_gem5_power/511.povray_r/m5out/cpt.simpoint_07_inst_949000000_weight_0.110497_interval_5000000_warmup_1000000/m5.cpt
runspec_gem5_power/511.povray_r/m5out/cpt.simpoint_08_inst_1464000000_weight_0.071823_interval_5000000_warmup_1000000/m5.cpt
runspec_gem5_power/511.povray_r/m5out/cpt.simpoint_09_inst_1519000000_weight_0.058932_interval_5000000_warmup_1000000/m5.cpt
runspec_gem5_power/511.povray_r/m5out/cpt.simpoint_10_inst_1709000000_weight_0.062615_interval_5000000_warmup_1000000/m5.cpt
runspec_gem5_power/511.povray_r/m5out/cpt.simpoint_11_inst_1754000000_weight_0.066298_interval_5000000_warmup_1000000/m5.cpt
runspec_gem5_power/511.povray_r/m5out/cpt.simpoint_12_inst_1849000000_weight_0.057090_interval_5000000_warmup_1000000/m5.cpt
runspec_gem5_power/511.povray_r/m5out/cpt.simpoint_13_inst_1969000000_weight_0.040516_interval_5000000_warmup_1000000/m5.cpt
runspec_gem5_power/511.povray_r/m5out/cpt.simpoint_14_inst_2554000000_weight_0.031308_interval_5000000_warmup_1000000/m5.cpt
runspec_gem5_power/511.povray_r/m5out/cpt.simpoint_15_inst_2619000000_weight_0.025783_interval_5000000_warmup_1000000/m5.cpt
runspec_gem5_power/520.omnetpp_r/m5out/config.ini
runspec_gem5_power/520.omnetpp_r/m5out/config.json
runspec_gem5_power/520.omnetpp_r/m5out/cpt.simpoint_19_inst_10354000000_weight_0.075379_interval_5000000_warmup_1000000/m5.cpt
runspec_gem5_power/520.omnetpp_r/m5out/cpt.simpoint_20_inst_12719000000_weight_0.054245_interval_5000000_warmup_1000000/m5.cpt
runspec_gem5_power/520.omnetpp_r/m5out/cpt.simpoint_21_inst_12814000000_weight_0.055653_interval_5000000_warmup_1000000/m5.cpt
runspec_gem5_power/520.omnetpp_r/m5out/cpt.simpoint_22_inst_13244000000_weight_0.048961_interval_5000000_warmup_1000000/m5.cpt
)

for F in ${FILE_LIST[*]}
do
	# Make sure the original path is correct before doing substitution
	sed -i 's#${original_path}#'`pwd`'#g' $F
done

