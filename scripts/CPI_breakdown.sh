#!/bin/bash
func_CPI_breakdown(){
  bm=(
    "500.perlbench_r" "502.gcc_r" "505.mcf_r" "520.omnetpp_r" "523.xalancbmk_r" "525.x264_r" "531.deepsjeng_r" "541.leela_r" "548.exchange2_r" "557.xz_r"
    "503.bwaves_r" "507.cactuBSSN_r" "508.namd_r" "510.parest_r" "511.povray_r" "519.lbm_r" "521.wrf_r" "526.blender_r" "527.cam4_r" "538.imagick_r" "544.nab_r" "549.fotonik3d_r" "554.roms_r" "999.specrand_ir"
  )

 #Path_of_gem5="/home/zhutairong/Desktop/gem5spec_st_669200b48c/data/gem5/20230313152504"
 Path_of_gem5="$1"
 #echo ${#bm[@]};

 for Spec_Name in ${bm[@]}  
 do
   #删除M1_result路径中遗留的filename.txt simpoint.txt文件
   rm  -rf ./data/M1/gem5spec_v0_M1/runspec_gem5_power/$Spec_Name/M1_result/filename.txt 
   rm  -rf ./data/M1/gem5spec_v0_M1/runspec_gem5_power/$Spec_Name/M1_result/simpoint.txt

   #列出M1_result目录下的所有文件名
   files=$(ls ./data/M1/gem5spec_v0_M1/runspec_gem5_power/$Spec_Name/M1_result)

   for filename in $files 
     do
	      #将文件名打印至filename.txt
        echo $filename >> ./data/M1/gem5spec_v0_M1/runspec_gem5_power/$Spec_Name/M1_result/filename.txt
     done

    #将文件名中的simpoint点提取并打印至simpoint.txt
    awk -F_ '{print $1}' ./data/M1/gem5spec_v0_M1/runspec_gem5_power/$Spec_Name/M1_result/filename.txt >> ./data/M1/gem5spec_v0_M1/runspec_gem5_power/$Spec_Name/M1_result/simpoint.txt

    #将M1_result路径下simpoint.txt文本中的数据转换成数组
    LISTS_M1=($(cat ./data/M1/gem5spec_v0_M1/runspec_gem5_power/$Spec_Name/M1_result/simpoint.txt))
    #echo "size: ${#LISTS_M1[*]}"
    #echo ${LISTS_M1[*]}

    #将gem5路径中merge文件里的第2列simpoint点转换成数组
    LISTS_GEM5=($(awk '{print $2}' $Path_of_gem5/runspec_gem5_power/$Spec_Name/$Spec_Name.merge))
    #echo ${LISTS_GEM5[*]}

    for((i=0;i<${#LISTS_M1[*]};i++))
      do 
        for((j=0;j<${#LISTS_GEM5[*]};j++))
          do
            if [[ "${LISTS_M1[i]}" == "${LISTS_GEM5[j]}" ]] ; then

              #匹配完成后根据simpoint点找出merge文件中的行号
              Line_num=`awk '{print $2}' $Path_of_gem5/runspec_gem5_power/$Spec_Name/$Spec_Name.merge| grep -n -w "${LISTS_GEM5[j]}" | awk -F: '{print $1}'`
              
              #把M1的.result文件copy到对应的output_ckp目录下
              M1_result_file=${LISTS_GEM5[j]}_`awk -F_ 'NR==1''{print $2}' ./data/M1/gem5spec_v0_M1/runspec_gem5_power/$Spec_Name/M1_result/filename.txt`_`awk -F_ 'NR==1''{print $3}' ./data/M1/gem5spec_v0_M1/runspec_gem5_power/$Spec_Name/M1_result/filename.txt`_`awk -F_ 'NR==1''{print $4}' ./data/M1/gem5spec_v0_M1/runspec_gem5_power/$Spec_Name/M1_result/filename.txt`
              cp ./data/M1/gem5spec_v0_M1/runspec_gem5_power/$Spec_Name/M1_result/$M1_result_file $Path_of_gem5/runspec_gem5_power/$Spec_Name/output_ckp$Line_num
              #echo $M1_result_file--output_ckp$Line_num

              #删除原有的M1.results文件
              rm -rf $Path_of_gem5/runspec_gem5_power/$Spec_Name/output_ckp$Line_num/M1.results

              #从拷贝进来的.result文件中grep出CPI_breakdown的数据，并存入新建的M1.results文件中
              echo "Parameters(GEM5)"" ""CPI(M1)">>$Path_of_gem5/runspec_gem5_power/$Spec_Name/output_ckp$Line_num/temp.txt
              grep -w "Wait_for_ifetch_in_pipe" $Path_of_gem5/runspec_gem5_power/$Spec_Name/output_ckp$Line_num/$M1_result_file | awk -F: '{print $2}'| awk '{print $1,$2}'  >> $Path_of_gem5/runspec_gem5_power/$Spec_Name/output_ckp$Line_num/temp.txt
              grep -w "Wait_for_ifetch_miss" $Path_of_gem5/runspec_gem5_power/$Spec_Name/output_ckp$Line_num/$M1_result_file | awk -F: '{print $2}' | awk '{print $1,$2}'>> $Path_of_gem5/runspec_gem5_power/$Spec_Name/output_ckp$Line_num/temp.txt
              grep -w "Wait_for_translation" $Path_of_gem5/runspec_gem5_power/$Spec_Name/output_ckp$Line_num/$M1_result_file | awk -F: 'NR==2''{print $2}' | awk '{print $1,$2}'>> $Path_of_gem5/runspec_gem5_power/$Spec_Name/output_ckp$Line_num/temp.txt
              grep -w "Wait_for_ifetch_other" $Path_of_gem5/runspec_gem5_power/$Spec_Name/output_ckp$Line_num/$M1_result_file | awk -F: '{print $2}' | awk '{print $1,$2}'>> $Path_of_gem5/runspec_gem5_power/$Spec_Name/output_ckp$Line_num/temp.txt
              grep -w "Wait_for_dispatch_requirements" $Path_of_gem5/runspec_gem5_power/$Spec_Name/output_ckp$Line_num/$M1_result_file | awk -F: 'NR==3''{print $2}' | awk '{print $1,$2}'>> $Path_of_gem5/runspec_gem5_power/$Spec_Name/output_ckp$Line_num/temp.txt
              grep -w "Wait_for_execution_unit" $Path_of_gem5/runspec_gem5_power/$Spec_Name/output_ckp$Line_num/$M1_result_file | awk -F: 'NR==2''{print $2}' | awk '{print $1,$2}'>> $Path_of_gem5/runspec_gem5_power/$Spec_Name/output_ckp$Line_num/temp.txt
              grep -w "Wait_for_re_ifetch_on_other_flushes" $Path_of_gem5/runspec_gem5_power/$Spec_Name/output_ckp$Line_num//$M1_result_file | awk -F: 'NR==2''{print $2}' | awk '{print $1,$2}'>>$Path_of_gem5/runspec_gem5_power/$Spec_Name/output_ckp$Line_num/temp.txt
              
              #部分state.txt中的数据未在M1.result文件中未找到与之对应项，先把变量名称列出来
              echo "decodeBlockCpi 0" >>$Path_of_gem5/runspec_gem5_power/$Spec_Name/output_ckp$Line_num/temp.txt
              echo "renameBlockCpi 0" >>$Path_of_gem5/runspec_gem5_power/$Spec_Name/output_ckp$Line_num/temp.txt
              echo "totalBlockCpi 0" >>$Path_of_gem5/runspec_gem5_power/$Spec_Name/output_ckp$Line_num/temp.txt
              echo "noBlockCpi 0" >>$Path_of_gem5/runspec_gem5_power/$Spec_Name/output_ckp$Line_num/temp.txt
              grep "CMPL: CPI" $Path_of_gem5/runspec_gem5_power/$Spec_Name/output_ckp$Line_num/$M1_result_file | awk -F: 'NR==1''{print $2}'| awk '{print $1,$2}'>> $Path_of_gem5/runspec_gem5_power/$Spec_Name/output_ckp$Line_num/temp.txt

              #把M1命名的变量名称替换成与之对应的Gem5变量名称
              sed -i 's/Wait_for_ifetch_in_pipe/fetchBlockCpi/' $Path_of_gem5/runspec_gem5_power/$Spec_Name/output_ckp$Line_num/temp.txt
              sed -i 's/Wait_for_ifetch_miss/iCacheStallCpi/' $Path_of_gem5/runspec_gem5_power/$Spec_Name/output_ckp$Line_num/temp.txt
              sed -i 's/Wait_for_translation/iTlbStallCpi/' $Path_of_gem5/runspec_gem5_power/$Spec_Name/output_ckp$Line_num/temp.txt
              sed -i 's/Wait_for_ifetch_other/miscStallCpi/' $Path_of_gem5/runspec_gem5_power/$Spec_Name/output_ckp$Line_num/temp.txt
              sed -i 's/Wait_for_dispatch_requirements/dispatchBlockCpi/' $Path_of_gem5/runspec_gem5_power/$Spec_Name/output_ckp$Line_num/temp.txt
              sed -i 's/Wait_for_execution_unit/IEWBlockCpi/' $Path_of_gem5/runspec_gem5_power/$Spec_Name/output_ckp$Line_num/temp.txt
              sed -i 's/Wait_for_re_ifetch_on_other_flushes/totalSquashCpi/' $Path_of_gem5/runspec_gem5_power/$Spec_Name/output_ckp$Line_num/temp.txt
              sed -i 's/CMPL: CPI/totalCpi/' $Path_of_gem5/runspec_gem5_power/$Spec_Name/output_ckp$Line_num/temp.txt

              #列对齐
              column -t $Path_of_gem5/runspec_gem5_power/$Spec_Name/output_ckp$Line_num/temp.txt > $Path_of_gem5/runspec_gem5_power/$Spec_Name/output_ckp$Line_num/M1.results
              rm -rf $Path_of_gem5/runspec_gem5_power/$Spec_Name/output_ckp$Line_num/temp.txt
              
            fi
          done
      done
 done
 }


 


