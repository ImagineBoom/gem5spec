
#判断选项
is_m1=false
is_gem5=false
is_host=false
is_myexe=false
is_spec2017=false
is_control=false
with_all_benchmarks=false
with_entire_all_benchmarks=false
with_entire=false
spec2017_bm=999

#判断参数个数选择不同模式
with_all_steps=false
with_itrace=false
with_qtrace=false
with_run_timer=false
with_pipe_view=false
with_i_insts=false
with_q_jump=false
with_q_convert=false
with_r_insts=false
with_r_cpi_interval=false
with_r_reset_stats=false
with_r_pipe_type=false
with_r_pipe_begin=false
with_r_pipe_end=false
with_max_insts=false
with_slice_len=false
with_gen_txt=false

gem5_ckp_py_opt=""
# label的值会影响Excel表格的命名，日期之后插入。可以自定义一个名称来区分当前这一组gem5_ckp_py_opts定义的任务。默认是数组长度。
label=""
with_restore_case=false
with_restore_all=false
with_restore_all_2=false
with_restore_all_4=false
with_restore_all_8=false
with_cpi_all=false
with_kill_restore_all=false
with_control_gem5=false
with_control_m1=false
with_func_gen_restore_compare_excel=false
parallel_jobs=-1
# ckp超时判定,seconds
timeout=1800
#是否从编译开始
with_build_gem5=false
build_gem5_j=-1

#m1需要的变量
#itrace
NUM_INSNS_TO_COLLECT=-1
#qtrace
JUMP_NUM=0
CONVERT_NUM_Vgi_RECS=-1
#run_timer
NUM_INST=-1
CPI_INTERVAL=-1
RESET_STATS=1
SCROLL_PIPE=2
SCROLL_BEGIN=-1
SCROLL_END=-1
#entire_all_benchmarks
slice_len=-1

target=""
args=""

#spec2017 benchmark
bm_insts=(\
[502]=19000000 [999]=62000000 [538]=210000000 [523]=480000000 [557]=740000000 [526]=1400000000 [525]=2400000000 [511]=2800000000 \
[500]=3300000000 [519]=6800000000 [544]=7000000000 [503]=15000000000 [520]=15000000000 [554]=18000000000 [507]=19000000000 [541]=29000000000 \
[505]=32000000000 [510]=33000000000 [531]=45000000000 [521]=46000000000 [549]=48000000000 [508]=72000000000 [548]=100000000000 [527]=140000000000 )

bm=(\
[502]="502.gcc_r" [999]="999.specrand_ir" [538]="538.imagick_r" [523]="523.xalancbmk_r" [557]="557.xz_r" [526]="526.blender_r" [525]="525.x264_r" [511]="511.povray_r" \
[500]="500.perlbench_r" [519]="519.lbm_r" [544]="544.nab_r" [503]="503.bwaves_r" [520]="520.omnetpp_r" [554]="554.roms_r" [507]="507.cactuBSSN_r" [541]="541.leela_r" \
[505]="505.mcf_r" [510]="510.parest_r" [531]="531.deepsjeng_r" [521]="521.wrf_r" [549]="549.fotonik3d_r" [508]="508.namd_r" [548]="548.exchange2_r" [527]="527.cam4_r")
#${bm[502]}

#判断选项

#判断参数个数选择不同模式

with_add_job=false
with_add_job_10=false
with_reduce_job=false
with_reduce_job_10=false
with_del_job_pool=false
with_get_job_pool_size=false
