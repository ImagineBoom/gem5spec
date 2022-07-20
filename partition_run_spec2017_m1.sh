#working dir
workdir="${1}/${2}"
#cd "$workdir" || exit 1
#benchmark name 502.gcc_r
file_name_append=$2
#benchmark insts, notion: (this insts) >= (real insts)+(lenseg)
INSTS=$3

#segment count
#如果只给了段的个数,那么段长不用提供,脚本会自行计算
segment_count=$4
file_prefix=${segment_count}

#=====================
#the following codes don't need to be modified
#=====================
#如果给了段长,那么段的个数$4也需要提供
if [[ -n ${5} ]]; then
  lenseg=${5}
else
  #segment len, div(FLOOR)
  lenseg=$((INSTS/file_prefix))
fi

#run dir
dirname=${file_prefix}_seg_${lenseg}_len

echo "$lenseg"
echo "$dirname"

mkdir -p "${workdir}/${dirname}"
if [[ ! -e "${workdir}"/"${file_name_append}".vgi ]];then
  make itrace -C "${workdir}" NUM_INSNS_TO_COLLECT="${INSTS}"
fi
for ((i=0;i<INSTS;i=i+lenseg))
do
  read -u6
  {
    i_add_lenseg=$((i+lenseg))
    m1file=${file_prefix}_${i}_${i_add_lenseg}_${file_name_append}
    make qtrace -C "${workdir}" JUMP_NUM="${i}" CONVERT_NUM_Vgi_RECS=${lenseg} qtFILE="${m1file}"
    make m1 -C "${workdir}" NUM_INST=${lenseg} CPI_INTERVAL=${lenseg} qtFILE="${m1file}"
    rm -rf "${workdir}"/"${m1file}".qt
    mv "${workdir}"/"${m1file}"* "${workdir}/${dirname}"
    echo >&6
  } &
done
wait