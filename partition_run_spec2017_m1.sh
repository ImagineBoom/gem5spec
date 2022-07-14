#working dir
workdir=$1
cd "$workdir" || exit 1
#benchmark name 502.gcc_r
file_name_append=$2
#benchmark insts, notion: (this insts) >= (real insts)+(lenseg)
INSTS=$3
#segment count
file_prefix=$4

#=====================
#the following codes don't need to be modified
#=====================

#segment len, div(FLOOR)
lenseg=$((INSTS/file_prefix))
#run dir
dirname=${file_prefix}_seg_${lenseg}_len

echo "$lenseg"
echo "$dirname"

for ((i=0;i<INSTS;i=i+lenseg))
do
  {
    mkdir -p "${dirname}"
    i_add_lenseg=$((i+lenseg))
    m1file=${file_prefix}_${i}_${i_add_lenseg}_${file_name_append}
    make qtrace -C "${file_name_append}" JUMP_NUM=${i} CONVERT_NUM_Vgi_RECS=${lenseg} qtFILE="${m1file}"
    make m1 -C "${file_name_append}" NUM_INST=${lenseg} CPI_INTERVAL=${lenseg} qtFILE="${m1file}"
    rm -rf "${m1file}".qt
    mv "${m1file}".* "${dirname}"
  } &
done
wait