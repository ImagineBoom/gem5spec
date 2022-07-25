#working dir
workdir="${1}/${2}"
#cd "$workdir" || exit 1
#benchmark name 502.gcc_r
file_name_append=$2
#benchmark insts, notion: (this insts) >= (real insts)+(lenseg)
INSTS=$3

#$4和$5只能2选1

#segment count
#如果只给了段的个数,那么段长不用提供,脚本会自行计算
segment_count=$4

#=====================
#the following codes don't need to be modified
#=====================
#如果给了段长,那么段的个数自行计算
if [[ -n ${5} && ${5} != '-' ]]; then
  lenseg=${5}
  segment_count=$((INSTS/lenseg))
  ((mul=segment_count*lenseg))
  if [[ $mul -lt $INSTS ]];then
    ((segment_count+=1))
  fi
else
  #segment len, div(FLOOR)
  lenseg=$(( INSTS/segment_count ))
  ((mul=segment_count*lenseg))
  if [[ $mul -lt $INSTS ]];then
    ((lenseg+=1))
  fi

fi

exec 6<>./running/run.fifo
#run dir
dirname=${segment_count}_seg_${lenseg}_len

#echo "$lenseg"
#echo "$dirname"

mkdir -p "${workdir}/${dirname}"
if [[ ! -e "${workdir}"/"${file_name_append}".vgi ]];then
  make itrace -C "${workdir}" NUM_INSNS_TO_COLLECT="${INSTS}"
fi
index=0
for ((i=0;i<INSTS;i=i+lenseg))
do
  ((index+=1))
  read -u6
  {
    i_add_lenseg=$((i+lenseg))
    if [[ $i_add_lenseg -gt $INSTS ]];then
      i_add_lenseg=$INSTS
    fi
    m1file=${index}_${i}_${i_add_lenseg}_${file_name_append}
    make qtrace -C "${workdir}" JUMP_NUM="${i}" CONVERT_NUM_Vgi_RECS=${lenseg} qtFILE="${m1file}"
    make m1 -C "${workdir}" NUM_INST=${lenseg} CPI_INTERVAL=${lenseg} qtFILE="${m1file}"
    rm -rf "${workdir}"/"${m1file}".qt
    mv "${workdir}"/"${m1file}"* "${workdir}/${dirname}"
    echo >&6
  } &
done
wait