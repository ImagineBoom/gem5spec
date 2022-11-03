
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

with_restore_all=false
with_restore_all_4=false
with_cpi_all=false
with_kill_restore_all=false
with_control_gem5=false
with_control_m1=false
with_func_gen_restore_compare_excel=false
parallel_jobs=5

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
SCROLL_PIPE=1
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

#at gem5spec dir
func_create_vgi_soft_link(){
  bm=(\
  [502]="502.gcc_r" [999]="999.specrand_ir" [538]="538.imagick_r" [523]="523.xalancbmk_r" [557]="557.xz_r" [526]="526.blender_r" [525]="525.x264_r" [511]="511.povray_r" \
  [500]="500.perlbench_r" [519]="519.lbm_r" [544]="544.nab_r" [503]="503.bwaves_r" [520]="520.omnetpp_r" [554]="554.roms_r" [507]="507.cactuBSSN_r" [541]="541.leela_r" \
  [505]="505.mcf_r" [510]="510.parest_r" [531]="531.deepsjeng_r" [521]="521.wrf_r" [549]="549.fotonik3d_r" [508]="508.namd_r" [548]="548.exchange2_r" [527]="527.cam4_r")
  TARGET="/home/lizongping/dev/gitlab/gem5spec/runspec_gem5_power"
  ln -nfs ${TARGET}/${bm[502]}/${bm[502]}.vgi ./runspec_gem5_power/${bm[502]}/${bm[502]}.vgi
  ln -nfs ${TARGET}/${bm[999]}/${bm[999]}.vgi ./runspec_gem5_power/${bm[999]}/${bm[999]}.vgi
  ln -nfs ${TARGET}/${bm[538]}/${bm[538]}.vgi ./runspec_gem5_power/${bm[538]}/${bm[538]}.vgi
  ln -nfs ${TARGET}/${bm[523]}/${bm[523]}.vgi ./runspec_gem5_power/${bm[523]}/${bm[523]}.vgi
  ln -nfs ${TARGET}/${bm[557]}/${bm[557]}.vgi ./runspec_gem5_power/${bm[557]}/${bm[557]}.vgi
  ln -nfs ${TARGET}/${bm[526]}/${bm[526]}.vgi ./runspec_gem5_power/${bm[526]}/${bm[526]}.vgi
  ln -nfs ${TARGET}/${bm[525]}/${bm[525]}.vgi ./runspec_gem5_power/${bm[525]}/${bm[525]}.vgi
  ln -nfs ${TARGET}/${bm[511]}/${bm[511]}.vgi ./runspec_gem5_power/${bm[511]}/${bm[511]}.vgi
  ln -nfs ${TARGET}/${bm[500]}/${bm[500]}.vgi ./runspec_gem5_power/${bm[500]}/${bm[500]}.vgi
  ln -nfs ${TARGET}/${bm[519]}/${bm[519]}.vgi ./runspec_gem5_power/${bm[519]}/${bm[519]}.vgi
  ln -nfs ${TARGET}/${bm[544]}/${bm[544]}.vgi ./runspec_gem5_power/${bm[544]}/${bm[544]}.vgi
  ln -nfs ${TARGET}/${bm[503]}/${bm[503]}.vgi ./runspec_gem5_power/${bm[503]}/${bm[503]}.vgi
  ln -nfs ${TARGET}/${bm[520]}/${bm[520]}.vgi ./runspec_gem5_power/${bm[520]}/${bm[520]}.vgi
  ln -nfs ${TARGET}/${bm[554]}/${bm[554]}.vgi ./runspec_gem5_power/${bm[554]}/${bm[554]}.vgi
  ln -nfs ${TARGET}/${bm[507]}/${bm[507]}.vgi ./runspec_gem5_power/${bm[507]}/${bm[507]}.vgi
  ln -nfs ${TARGET}/${bm[541]}/${bm[541]}.vgi ./runspec_gem5_power/${bm[541]}/${bm[541]}.vgi
  ln -nfs ${TARGET}/${bm[505]}/${bm[505]}.vgi ./runspec_gem5_power/${bm[505]}/${bm[505]}.vgi
  ln -nfs ${TARGET}/${bm[510]}/${bm[510]}.vgi ./runspec_gem5_power/${bm[510]}/${bm[510]}.vgi
  ln -nfs ${TARGET}/${bm[531]}/${bm[531]}.vgi ./runspec_gem5_power/${bm[531]}/${bm[531]}.vgi
  ln -nfs ${TARGET}/${bm[521]}/${bm[521]}.vgi ./runspec_gem5_power/${bm[521]}/${bm[521]}.vgi
  ln -nfs ${TARGET}/${bm[549]}/${bm[549]}.vgi ./runspec_gem5_power/${bm[549]}/${bm[549]}.vgi
  ln -nfs ${TARGET}/${bm[508]}/${bm[508]}.vgi ./runspec_gem5_power/${bm[508]}/${bm[508]}.vgi
  ln -nfs ${TARGET}/${bm[548]}/${bm[548]}.vgi ./runspec_gem5_power/${bm[548]}/${bm[548]}.vgi
  ln -nfs ${TARGET}/${bm[527]}/${bm[527]}.vgi ./runspec_gem5_power/${bm[527]}/${bm[527]}.vgi
}

#at gem5spec dir
func_cp_merge(){
  bm=(\
  [502]="502.gcc_r" [999]="999.specrand_ir" [538]="538.imagick_r" [523]="523.xalancbmk_r" [557]="557.xz_r" [526]="526.blender_r" [525]="525.x264_r" [511]="511.povray_r" \
  [500]="500.perlbench_r" [519]="519.lbm_r" [544]="544.nab_r" [503]="503.bwaves_r" [520]="520.omnetpp_r" [554]="554.roms_r" [507]="507.cactuBSSN_r" [541]="541.leela_r" \
  [505]="505.mcf_r" [510]="510.parest_r" [531]="531.deepsjeng_r" [521]="521.wrf_r" [549]="549.fotonik3d_r" [508]="508.namd_r" [548]="548.exchange2_r" [527]="527.cam4_r")
  TARGET="/home/lizongping/prj/data/gem5spec_5m_x86_backup/runspec_gem5_power"
  rm -rf ./runspec_gem5_power/*r/*.merge
  cp -r ${TARGET}/${bm[502]}/${bm[502]}.merge ./runspec_gem5_power/${bm[502]}/${bm[502]}.merge
  cp -r ${TARGET}/${bm[999]}/${bm[999]}.merge ./runspec_gem5_power/${bm[999]}/${bm[999]}.merge
  cp -r ${TARGET}/${bm[538]}/${bm[538]}.merge ./runspec_gem5_power/${bm[538]}/${bm[538]}.merge
  cp -r ${TARGET}/${bm[523]}/${bm[523]}.merge ./runspec_gem5_power/${bm[523]}/${bm[523]}.merge
  cp -r ${TARGET}/${bm[557]}/${bm[557]}.merge ./runspec_gem5_power/${bm[557]}/${bm[557]}.merge
  cp -r ${TARGET}/${bm[526]}/${bm[526]}.merge ./runspec_gem5_power/${bm[526]}/${bm[526]}.merge
  cp -r ${TARGET}/${bm[525]}/${bm[525]}.merge ./runspec_gem5_power/${bm[525]}/${bm[525]}.merge
  cp -r ${TARGET}/${bm[511]}/${bm[511]}.merge ./runspec_gem5_power/${bm[511]}/${bm[511]}.merge
  cp -r ${TARGET}/${bm[500]}/${bm[500]}.merge ./runspec_gem5_power/${bm[500]}/${bm[500]}.merge
  cp -r ${TARGET}/${bm[519]}/${bm[519]}.merge ./runspec_gem5_power/${bm[519]}/${bm[519]}.merge
  cp -r ${TARGET}/${bm[544]}/${bm[544]}.merge ./runspec_gem5_power/${bm[544]}/${bm[544]}.merge
  cp -r ${TARGET}/${bm[503]}/${bm[503]}.merge ./runspec_gem5_power/${bm[503]}/${bm[503]}.merge
  cp -r ${TARGET}/${bm[520]}/${bm[520]}.merge ./runspec_gem5_power/${bm[520]}/${bm[520]}.merge
  cp -r ${TARGET}/${bm[554]}/${bm[554]}.merge ./runspec_gem5_power/${bm[554]}/${bm[554]}.merge
  cp -r ${TARGET}/${bm[507]}/${bm[507]}.merge ./runspec_gem5_power/${bm[507]}/${bm[507]}.merge
  cp -r ${TARGET}/${bm[541]}/${bm[541]}.merge ./runspec_gem5_power/${bm[541]}/${bm[541]}.merge
  cp -r ${TARGET}/${bm[505]}/${bm[505]}.merge ./runspec_gem5_power/${bm[505]}/${bm[505]}.merge
  cp -r ${TARGET}/${bm[510]}/${bm[510]}.merge ./runspec_gem5_power/${bm[510]}/${bm[510]}.merge
  cp -r ${TARGET}/${bm[531]}/${bm[531]}.merge ./runspec_gem5_power/${bm[531]}/${bm[531]}.merge
  cp -r ${TARGET}/${bm[521]}/${bm[521]}.merge ./runspec_gem5_power/${bm[521]}/${bm[521]}.merge
  cp -r ${TARGET}/${bm[549]}/${bm[549]}.merge ./runspec_gem5_power/${bm[549]}/${bm[549]}.merge
  cp -r ${TARGET}/${bm[508]}/${bm[508]}.merge ./runspec_gem5_power/${bm[508]}/${bm[508]}.merge
  cp -r ${TARGET}/${bm[548]}/${bm[548]}.merge ./runspec_gem5_power/${bm[548]}/${bm[548]}.merge
  cp -r ${TARGET}/${bm[527]}/${bm[527]}.merge ./runspec_gem5_power/${bm[527]}/${bm[527]}.merge
}

# gem5spec目录下执行
func_cp_simpts_weights(){
  bm=(\
  [502]="502.gcc_r" [999]="999.specrand_ir" [538]="538.imagick_r" [523]="523.xalancbmk_r" [557]="557.xz_r" [526]="526.blender_r" [525]="525.x264_r" [511]="511.povray_r" \
  [500]="500.perlbench_r" [519]="519.lbm_r" [544]="544.nab_r" [503]="503.bwaves_r" [520]="520.omnetpp_r" [554]="554.roms_r" [507]="507.cactuBSSN_r" [541]="541.leela_r" \
  [505]="505.mcf_r" [510]="510.parest_r" [531]="531.deepsjeng_r" [521]="521.wrf_r" [549]="549.fotonik3d_r" [508]="508.namd_r" [548]="548.exchange2_r" [527]="527.cam4_r")
  TARGET="/home/lizongping/prj/data/gem5spec_5m_x86_backup/runspec_gem5_power"
  rm -rf ./runspec_gem5_power/*r/*.simpts ./runspec_gem5_power/*r/*.weights
  cp -r ${TARGET}/${bm[502]}/${bm[502]}.simpts ./runspec_gem5_power/${bm[502]}/${bm[502]}.simpts
  cp -r ${TARGET}/${bm[999]}/${bm[999]}.simpts ./runspec_gem5_power/${bm[999]}/${bm[999]}.simpts
  cp -r ${TARGET}/${bm[538]}/${bm[538]}.simpts ./runspec_gem5_power/${bm[538]}/${bm[538]}.simpts
  cp -r ${TARGET}/${bm[523]}/${bm[523]}.simpts ./runspec_gem5_power/${bm[523]}/${bm[523]}.simpts
  cp -r ${TARGET}/${bm[557]}/${bm[557]}.simpts ./runspec_gem5_power/${bm[557]}/${bm[557]}.simpts
  cp -r ${TARGET}/${bm[526]}/${bm[526]}.simpts ./runspec_gem5_power/${bm[526]}/${bm[526]}.simpts
  cp -r ${TARGET}/${bm[525]}/${bm[525]}.simpts ./runspec_gem5_power/${bm[525]}/${bm[525]}.simpts
  cp -r ${TARGET}/${bm[511]}/${bm[511]}.simpts ./runspec_gem5_power/${bm[511]}/${bm[511]}.simpts
  cp -r ${TARGET}/${bm[500]}/${bm[500]}.simpts ./runspec_gem5_power/${bm[500]}/${bm[500]}.simpts
  cp -r ${TARGET}/${bm[519]}/${bm[519]}.simpts ./runspec_gem5_power/${bm[519]}/${bm[519]}.simpts
  cp -r ${TARGET}/${bm[544]}/${bm[544]}.simpts ./runspec_gem5_power/${bm[544]}/${bm[544]}.simpts
  cp -r ${TARGET}/${bm[503]}/${bm[503]}.simpts ./runspec_gem5_power/${bm[503]}/${bm[503]}.simpts
  cp -r ${TARGET}/${bm[520]}/${bm[520]}.simpts ./runspec_gem5_power/${bm[520]}/${bm[520]}.simpts
  cp -r ${TARGET}/${bm[554]}/${bm[554]}.simpts ./runspec_gem5_power/${bm[554]}/${bm[554]}.simpts
  cp -r ${TARGET}/${bm[507]}/${bm[507]}.simpts ./runspec_gem5_power/${bm[507]}/${bm[507]}.simpts
  cp -r ${TARGET}/${bm[541]}/${bm[541]}.simpts ./runspec_gem5_power/${bm[541]}/${bm[541]}.simpts
  cp -r ${TARGET}/${bm[505]}/${bm[505]}.simpts ./runspec_gem5_power/${bm[505]}/${bm[505]}.simpts
  cp -r ${TARGET}/${bm[510]}/${bm[510]}.simpts ./runspec_gem5_power/${bm[510]}/${bm[510]}.simpts
  cp -r ${TARGET}/${bm[531]}/${bm[531]}.simpts ./runspec_gem5_power/${bm[531]}/${bm[531]}.simpts
  cp -r ${TARGET}/${bm[521]}/${bm[521]}.simpts ./runspec_gem5_power/${bm[521]}/${bm[521]}.simpts
  cp -r ${TARGET}/${bm[549]}/${bm[549]}.simpts ./runspec_gem5_power/${bm[549]}/${bm[549]}.simpts
  cp -r ${TARGET}/${bm[508]}/${bm[508]}.simpts ./runspec_gem5_power/${bm[508]}/${bm[508]}.simpts
  cp -r ${TARGET}/${bm[548]}/${bm[548]}.simpts ./runspec_gem5_power/${bm[548]}/${bm[548]}.simpts
  cp -r ${TARGET}/${bm[527]}/${bm[527]}.simpts ./runspec_gem5_power/${bm[527]}/${bm[527]}.simpts

  cp -r ${TARGET}/${bm[502]}/${bm[502]}.weights ./runspec_gem5_power/${bm[502]}/${bm[502]}.weights
  cp -r ${TARGET}/${bm[999]}/${bm[999]}.weights ./runspec_gem5_power/${bm[999]}/${bm[999]}.weights
  cp -r ${TARGET}/${bm[538]}/${bm[538]}.weights ./runspec_gem5_power/${bm[538]}/${bm[538]}.weights
  cp -r ${TARGET}/${bm[523]}/${bm[523]}.weights ./runspec_gem5_power/${bm[523]}/${bm[523]}.weights
  cp -r ${TARGET}/${bm[557]}/${bm[557]}.weights ./runspec_gem5_power/${bm[557]}/${bm[557]}.weights
  cp -r ${TARGET}/${bm[526]}/${bm[526]}.weights ./runspec_gem5_power/${bm[526]}/${bm[526]}.weights
  cp -r ${TARGET}/${bm[525]}/${bm[525]}.weights ./runspec_gem5_power/${bm[525]}/${bm[525]}.weights
  cp -r ${TARGET}/${bm[511]}/${bm[511]}.weights ./runspec_gem5_power/${bm[511]}/${bm[511]}.weights
  cp -r ${TARGET}/${bm[500]}/${bm[500]}.weights ./runspec_gem5_power/${bm[500]}/${bm[500]}.weights
  cp -r ${TARGET}/${bm[519]}/${bm[519]}.weights ./runspec_gem5_power/${bm[519]}/${bm[519]}.weights
  cp -r ${TARGET}/${bm[544]}/${bm[544]}.weights ./runspec_gem5_power/${bm[544]}/${bm[544]}.weights
  cp -r ${TARGET}/${bm[503]}/${bm[503]}.weights ./runspec_gem5_power/${bm[503]}/${bm[503]}.weights
  cp -r ${TARGET}/${bm[520]}/${bm[520]}.weights ./runspec_gem5_power/${bm[520]}/${bm[520]}.weights
  cp -r ${TARGET}/${bm[554]}/${bm[554]}.weights ./runspec_gem5_power/${bm[554]}/${bm[554]}.weights
  cp -r ${TARGET}/${bm[507]}/${bm[507]}.weights ./runspec_gem5_power/${bm[507]}/${bm[507]}.weights
  cp -r ${TARGET}/${bm[541]}/${bm[541]}.weights ./runspec_gem5_power/${bm[541]}/${bm[541]}.weights
  cp -r ${TARGET}/${bm[505]}/${bm[505]}.weights ./runspec_gem5_power/${bm[505]}/${bm[505]}.weights
  cp -r ${TARGET}/${bm[510]}/${bm[510]}.weights ./runspec_gem5_power/${bm[510]}/${bm[510]}.weights
  cp -r ${TARGET}/${bm[531]}/${bm[531]}.weights ./runspec_gem5_power/${bm[531]}/${bm[531]}.weights
  cp -r ${TARGET}/${bm[521]}/${bm[521]}.weights ./runspec_gem5_power/${bm[521]}/${bm[521]}.weights
  cp -r ${TARGET}/${bm[549]}/${bm[549]}.weights ./runspec_gem5_power/${bm[549]}/${bm[549]}.weights
  cp -r ${TARGET}/${bm[508]}/${bm[508]}.weights ./runspec_gem5_power/${bm[508]}/${bm[508]}.weights
  cp -r ${TARGET}/${bm[548]}/${bm[548]}.weights ./runspec_gem5_power/${bm[548]}/${bm[548]}.weights
  cp -r ${TARGET}/${bm[527]}/${bm[527]}.weights ./runspec_gem5_power/${bm[527]}/${bm[527]}.weights
}

func_help(){
  cat <<- EOF
  1.Desc: run some spec2017 benchmarks and custom programs help
  2.Notion: )表示输入的上一级命令, []内表示可选, |表示选择一个, <>内表示必填项
  3.Usage: ./run.sh  [MAIN_OPTS]  [FIR_OPTS]  [SEC_OPTS]

    [MAIN_OPTS]:
              --m1,                                                                     使用power8模拟器
              --gem5                                                                    使用gem5模拟器
              --control                                                                 线程控制

    [FIR_OPTS]:
      --m1)
              --myexe <exepath>                                                         使用自定义的程序(编译后的)
              --spec2017                                                                使用spec2017某一个或者全部
      --gem5)
              --spec2017                                                                使用spec2017全部
      --control)
              --add_job|--add_job_10                                                    增加可运行的线程数
              --reduce_job|--reduce_job_10                                              减少可运行的线程数
              --del_job_pool                                                            删除线程池
              --kill_restore_all_jobs                                                   kill restore_all 的任务

    [SEC_OPTS]:
      --myexe)
              -a --i_insts=<num> -j=<num> -c=<num> --r_insts=<num> -b=<num> -e=<num>
              -i --i_insts=<num>                                                        生成i_insts条指令的itrace
              -q -j=<num> -c=<num>                                                      生成[j,j+c]指令区间的qtrace
              -r --r_insts=<num> -b=<num> -e=<num>                                      在qtrace区间中执行r_insts条指令,流水线图指令区间为[j+b,j+e-b+1]
              -p                                                                        查看流水线图
              -b=<num> -e=<num>                                                         缺省参数模式

      --spec2017)
              <benchmark num>                                                           [502|999|538|523|557|526|525|511|500|519|544|503|520|554|507|541|505|510|531|521|549|508|548|527]
              --restore_all                                                             run all benchmark checkpoints segments
              -a --i_insts=<num> -j=<num> -c=<num> --r_insts=<num> -b=<num> -e=<num>
              -i --i_insts=<num>                                                        生成i_insts条指令的itrace
              -q -j=<num> -c=<num>                                                      生成[j,j+c]指令区间的qtrace
              -r --r_insts=<num> -b=<num> -e=<num>                                      在qtrace区间中执行r_insts条指令,流水线图指令区间为[j+b,j+e-b+1]
              -p                                                                        查看流水线图
              -b=<num> -e=<num>                                                         缺省参数模式

  4.OPTS解释:
    --m1
      --all             | --all_steps             | -a                                  执行使用m1的所有步骤
      --itrace                                    | -i                                  只生成itrace
      --qtrace                                    | -q                                  只转换qtrace
      --run_timer                                 | -r                                  只执行run_timer
      --pipe_view                                 | -p                                  只查看流水线
      --i_insts         | --NUM_INSNS_TO_COLLECT                                        生成itrace指定的指令数
      --q_jump          | --JUMP_NUM              | -j                                  生成qtrace跳过的指令数
      --q_convert       | --CONVERT_NUM_Vgi_RECS  | -c                                  生成qtrace转换的指令数
      --r_insts         | --NUM_INST                                                    run_timer执行的指令数
      --r_cpi_interval  | --CPI_INTERVAL                                                可打印CPI的INTERVAL大小
      --r_reset_stats   | --RESET_STATS
      --r_pipe_type     | --SCROLL_PIPE                                                 流水线类型 1为architected inst, 2为internal instruction, 3为cycle count
      --r_pipe_begin    | --SCROLL_BEGIN          | -b                                  流水线图指令区间起始位置
      --r_pipe_end      | --SCROLL_END            | -e                                  流水线图指令区间结束位置

  5.RUN:
    PATTERN-1: 完整参数模式

    *  运行m1的整个流程,生成前2000000条指令的itrace,转换[9999,19999]条指令的qtrace,执行10000条,查看qtrace中前400条指令的流水线
       ./run.sh --m1 --spec2017 999 -a --i_insts=2000000 -j=9999 -c=10000 --r_insts=10000 -b=1 -e=400
       ./run.sh --m1 --myexe ./test -a --i_insts=2000000 -j=9999 -c=10000 --r_insts=10000 -b=1 -e=400

    *  所有的benchmark执行指令数均为5,000,000(q_convert\r_insts),itrace按最大指令数转换,流水线区间为[jump+1,jump+400]
       ./run.sh --m1 --spec2017 --all_benchmarks --q_jump=9999 --q_convert=5000000 --r_pipe_begin=1 --r_pipe_end=400

    *  所有的benchmark按最大指令数执行,超过700,000,000条指令的将按照700,000,000分段执行
       ./run.sh --m1 --spec2017 --entire_all_benchmarks
       ./run.sh --m1 --spec2017 --entire_all_benchmarks --max_insts

    *  所有的benchmark按1000条指令分段执行
       ./run.sh --m1 --spec2017 --entire_all_benchmarks --slice_len=1000

    *  test-p8按最大指令数执行,超过700,000,000条指令的将按照700,000,000分段执行
       ./run.sh --m1 --myexe ./test-p8 --entire

    PATTERN-2: 缺省参数模式【推荐】

    *  运行m1的整个流程,生成前最大指令数的itrace,qtrace区间为[begin,end],执行400条(end-begin+1),流水线区间为[begin,end]
       ./run.sh --m1 --spec2017 999 -b=1 -e=400
       ./run.sh --m1 --myexe ./test -b=1 -e=400

  :)END
EOF
    exit 0
}

func_with_all_benchmarks(){
  opts=(
    "runspec_gem5_power/500.perlbench_r NUM_INSNS_TO_COLLECT=${bm_insts[500]} JUMP_NUM=${JUMP_NUM} CONVERT_NUM_Vgi_RECS=${CONVERT_NUM_Vgi_RECS} NUM_INST=${NUM_INST} CPI_INTERVAL=${NUM_INST} SCROLL_BEGIN=${SCROLL_BEGIN} SCROLL_END=${SCROLL_END}"
    "runspec_gem5_power/502.gcc_r       NUM_INSNS_TO_COLLECT=${bm_insts[502]} JUMP_NUM=${JUMP_NUM} CONVERT_NUM_Vgi_RECS=${CONVERT_NUM_Vgi_RECS} NUM_INST=${NUM_INST} CPI_INTERVAL=${NUM_INST} SCROLL_BEGIN=${SCROLL_BEGIN} SCROLL_END=${SCROLL_END}"
    "runspec_gem5_power/503.bwaves_r    NUM_INSNS_TO_COLLECT=${bm_insts[503]} JUMP_NUM=${JUMP_NUM} CONVERT_NUM_Vgi_RECS=${CONVERT_NUM_Vgi_RECS} NUM_INST=${NUM_INST} CPI_INTERVAL=${NUM_INST} SCROLL_BEGIN=${SCROLL_BEGIN} SCROLL_END=${SCROLL_END}"
    "runspec_gem5_power/505.mcf_r       NUM_INSNS_TO_COLLECT=${bm_insts[505]} JUMP_NUM=${JUMP_NUM} CONVERT_NUM_Vgi_RECS=${CONVERT_NUM_Vgi_RECS} NUM_INST=${NUM_INST} CPI_INTERVAL=${NUM_INST} SCROLL_BEGIN=${SCROLL_BEGIN} SCROLL_END=${SCROLL_END}"
    "runspec_gem5_power/507.cactuBSSN_r NUM_INSNS_TO_COLLECT=${bm_insts[507]} JUMP_NUM=${JUMP_NUM} CONVERT_NUM_Vgi_RECS=${CONVERT_NUM_Vgi_RECS} NUM_INST=${NUM_INST} CPI_INTERVAL=${NUM_INST} SCROLL_BEGIN=${SCROLL_BEGIN} SCROLL_END=${SCROLL_END}"
    "runspec_gem5_power/508.namd_r      NUM_INSNS_TO_COLLECT=${bm_insts[508]} JUMP_NUM=${JUMP_NUM} CONVERT_NUM_Vgi_RECS=${CONVERT_NUM_Vgi_RECS} NUM_INST=${NUM_INST} CPI_INTERVAL=${NUM_INST} SCROLL_BEGIN=${SCROLL_BEGIN} SCROLL_END=${SCROLL_END}"
    "runspec_gem5_power/510.parest_r    NUM_INSNS_TO_COLLECT=${bm_insts[510]} JUMP_NUM=${JUMP_NUM} CONVERT_NUM_Vgi_RECS=${CONVERT_NUM_Vgi_RECS} NUM_INST=${NUM_INST} CPI_INTERVAL=${NUM_INST} SCROLL_BEGIN=${SCROLL_BEGIN} SCROLL_END=${SCROLL_END}"
    "runspec_gem5_power/511.povray_r    NUM_INSNS_TO_COLLECT=${bm_insts[511]} JUMP_NUM=${JUMP_NUM} CONVERT_NUM_Vgi_RECS=${CONVERT_NUM_Vgi_RECS} NUM_INST=${NUM_INST} CPI_INTERVAL=${NUM_INST} SCROLL_BEGIN=${SCROLL_BEGIN} SCROLL_END=${SCROLL_END}"
    "runspec_gem5_power/519.lbm_r       NUM_INSNS_TO_COLLECT=${bm_insts[519]} JUMP_NUM=${JUMP_NUM} CONVERT_NUM_Vgi_RECS=${CONVERT_NUM_Vgi_RECS} NUM_INST=${NUM_INST} CPI_INTERVAL=${NUM_INST} SCROLL_BEGIN=${SCROLL_BEGIN} SCROLL_END=${SCROLL_END}"
    "runspec_gem5_power/520.omnetpp_r   NUM_INSNS_TO_COLLECT=${bm_insts[520]} JUMP_NUM=${JUMP_NUM} CONVERT_NUM_Vgi_RECS=${CONVERT_NUM_Vgi_RECS} NUM_INST=${NUM_INST} CPI_INTERVAL=${NUM_INST} SCROLL_BEGIN=${SCROLL_BEGIN} SCROLL_END=${SCROLL_END}"
    "runspec_gem5_power/521.wrf_r       NUM_INSNS_TO_COLLECT=${bm_insts[521]} JUMP_NUM=${JUMP_NUM} CONVERT_NUM_Vgi_RECS=${CONVERT_NUM_Vgi_RECS} NUM_INST=${NUM_INST} CPI_INTERVAL=${NUM_INST} SCROLL_BEGIN=${SCROLL_BEGIN} SCROLL_END=${SCROLL_END}"
    "runspec_gem5_power/523.xalancbmk_r NUM_INSNS_TO_COLLECT=${bm_insts[523]} JUMP_NUM=${JUMP_NUM} CONVERT_NUM_Vgi_RECS=${CONVERT_NUM_Vgi_RECS} NUM_INST=${NUM_INST} CPI_INTERVAL=${NUM_INST} SCROLL_BEGIN=${SCROLL_BEGIN} SCROLL_END=${SCROLL_END}"
    "runspec_gem5_power/525.x264_r      NUM_INSNS_TO_COLLECT=${bm_insts[525]} JUMP_NUM=${JUMP_NUM} CONVERT_NUM_Vgi_RECS=${CONVERT_NUM_Vgi_RECS} NUM_INST=${NUM_INST} CPI_INTERVAL=${NUM_INST} SCROLL_BEGIN=${SCROLL_BEGIN} SCROLL_END=${SCROLL_END}"
    "runspec_gem5_power/526.blender_r   NUM_INSNS_TO_COLLECT=${bm_insts[526]} JUMP_NUM=${JUMP_NUM} CONVERT_NUM_Vgi_RECS=${CONVERT_NUM_Vgi_RECS} NUM_INST=${NUM_INST} CPI_INTERVAL=${NUM_INST} SCROLL_BEGIN=${SCROLL_BEGIN} SCROLL_END=${SCROLL_END}"
    "runspec_gem5_power/527.cam4_r      NUM_INSNS_TO_COLLECT=${bm_insts[527]} JUMP_NUM=${JUMP_NUM} CONVERT_NUM_Vgi_RECS=${CONVERT_NUM_Vgi_RECS} NUM_INST=${NUM_INST} CPI_INTERVAL=${NUM_INST} SCROLL_BEGIN=${SCROLL_BEGIN} SCROLL_END=${SCROLL_END}"
    "runspec_gem5_power/531.deepsjeng_r NUM_INSNS_TO_COLLECT=${bm_insts[531]} JUMP_NUM=${JUMP_NUM} CONVERT_NUM_Vgi_RECS=${CONVERT_NUM_Vgi_RECS} NUM_INST=${NUM_INST} CPI_INTERVAL=${NUM_INST} SCROLL_BEGIN=${SCROLL_BEGIN} SCROLL_END=${SCROLL_END}"
    "runspec_gem5_power/538.imagick_r   NUM_INSNS_TO_COLLECT=${bm_insts[538]} JUMP_NUM=${JUMP_NUM} CONVERT_NUM_Vgi_RECS=${CONVERT_NUM_Vgi_RECS} NUM_INST=${NUM_INST} CPI_INTERVAL=${NUM_INST} SCROLL_BEGIN=${SCROLL_BEGIN} SCROLL_END=${SCROLL_END}"
    "runspec_gem5_power/541.leela_r     NUM_INSNS_TO_COLLECT=${bm_insts[541]} JUMP_NUM=${JUMP_NUM} CONVERT_NUM_Vgi_RECS=${CONVERT_NUM_Vgi_RECS} NUM_INST=${NUM_INST} CPI_INTERVAL=${NUM_INST} SCROLL_BEGIN=${SCROLL_BEGIN} SCROLL_END=${SCROLL_END}"
    "runspec_gem5_power/544.nab_r       NUM_INSNS_TO_COLLECT=${bm_insts[544]} JUMP_NUM=${JUMP_NUM} CONVERT_NUM_Vgi_RECS=${CONVERT_NUM_Vgi_RECS} NUM_INST=${NUM_INST} CPI_INTERVAL=${NUM_INST} SCROLL_BEGIN=${SCROLL_BEGIN} SCROLL_END=${SCROLL_END}"
    "runspec_gem5_power/548.exchange2_r NUM_INSNS_TO_COLLECT=${bm_insts[548]} JUMP_NUM=${JUMP_NUM} CONVERT_NUM_Vgi_RECS=${CONVERT_NUM_Vgi_RECS} NUM_INST=${NUM_INST} CPI_INTERVAL=${NUM_INST} SCROLL_BEGIN=${SCROLL_BEGIN} SCROLL_END=${SCROLL_END}"
    "runspec_gem5_power/549.fotonik3d_r NUM_INSNS_TO_COLLECT=${bm_insts[549]} JUMP_NUM=${JUMP_NUM} CONVERT_NUM_Vgi_RECS=${CONVERT_NUM_Vgi_RECS} NUM_INST=${NUM_INST} CPI_INTERVAL=${NUM_INST} SCROLL_BEGIN=${SCROLL_BEGIN} SCROLL_END=${SCROLL_END}"
    "runspec_gem5_power/554.roms_r      NUM_INSNS_TO_COLLECT=${bm_insts[554]} JUMP_NUM=${JUMP_NUM} CONVERT_NUM_Vgi_RECS=${CONVERT_NUM_Vgi_RECS} NUM_INST=${NUM_INST} CPI_INTERVAL=${NUM_INST} SCROLL_BEGIN=${SCROLL_BEGIN} SCROLL_END=${SCROLL_END}"
    "runspec_gem5_power/557.xz_r        NUM_INSNS_TO_COLLECT=${bm_insts[557]} JUMP_NUM=${JUMP_NUM} CONVERT_NUM_Vgi_RECS=${CONVERT_NUM_Vgi_RECS} NUM_INST=${NUM_INST} CPI_INTERVAL=${NUM_INST} SCROLL_BEGIN=${SCROLL_BEGIN} SCROLL_END=${SCROLL_END}"
    "runspec_gem5_power/999.specrand_ir NUM_INSNS_TO_COLLECT=${bm_insts[999]} JUMP_NUM=${JUMP_NUM} CONVERT_NUM_Vgi_RECS=${CONVERT_NUM_Vgi_RECS} NUM_INST=${NUM_INST} CPI_INTERVAL=${NUM_INST} SCROLL_BEGIN=${SCROLL_BEGIN} SCROLL_END=${SCROLL_END}"
  )
  for opt in "${opts[@]}" ;do
    read -u6
    {
      make trace -C "${opt}" >>nohup.out 2>&1
      echo >&6
    }&
  done
}

func_with_entire_all_benchmarks(){
  if [[ $with_slice_len == false ]];then
    opts=(
      "make trace -C runspec_gem5_power/502.gcc_r       NUM_INSNS_TO_COLLECT=${bm_insts[502]} JUMP_NUM=0 NUM_INST=${bm_insts[502]} CPI_INTERVAL=${bm_insts[502]} RESET_STATS=1"
      "make trace -C runspec_gem5_power/999.specrand_ir NUM_INSNS_TO_COLLECT=${bm_insts[999]} JUMP_NUM=0 NUM_INST=${bm_insts[999]} CPI_INTERVAL=${bm_insts[999]} RESET_STATS=1"
      "make trace -C runspec_gem5_power/538.imagick_r   NUM_INSNS_TO_COLLECT=${bm_insts[538]} JUMP_NUM=0 NUM_INST=${bm_insts[538]} CPI_INTERVAL=${bm_insts[538]} RESET_STATS=1"
      "make trace -C runspec_gem5_power/523.xalancbmk_r NUM_INSNS_TO_COLLECT=${bm_insts[523]} JUMP_NUM=0 NUM_INST=${bm_insts[523]} CPI_INTERVAL=${bm_insts[523]} RESET_STATS=1"
      "make trace -C runspec_gem5_power/557.xz_r        NUM_INSNS_TO_COLLECT=${bm_insts[557]} JUMP_NUM=0 NUM_INST=${bm_insts[557]} CPI_INTERVAL=${bm_insts[557]} RESET_STATS=1"
      "./partition_run_spec2017_m1.sh ${WORK_DIR} ${bm[526]} ${bm_insts[526]} 2"
      "./partition_run_spec2017_m1.sh ${WORK_DIR} ${bm[525]} ${bm_insts[525]} 4"
      "./partition_run_spec2017_m1.sh ${WORK_DIR} ${bm[511]} ${bm_insts[511]} 4"
      "./partition_run_spec2017_m1.sh ${WORK_DIR} ${bm[500]} ${bm_insts[500]} 5"
      "./partition_run_spec2017_m1.sh ${WORK_DIR} ${bm[519]} ${bm_insts[519]} 10"
      "./partition_run_spec2017_m1.sh ${WORK_DIR} ${bm[544]} ${bm_insts[544]} 10"
      "./partition_run_spec2017_m1.sh ${WORK_DIR} ${bm[503]} ${bm_insts[503]} 20"
      "./partition_run_spec2017_m1.sh ${WORK_DIR} ${bm[520]} ${bm_insts[520]} 21"
      "./partition_run_spec2017_m1.sh ${WORK_DIR} ${bm[554]} ${bm_insts[554]} 25"
      "./partition_run_spec2017_m1.sh ${WORK_DIR} ${bm[507]} ${bm_insts[507]} 27"
      "./partition_run_spec2017_m1.sh ${WORK_DIR} ${bm[541]} ${bm_insts[541]} 41"
      "./partition_run_spec2017_m1.sh ${WORK_DIR} ${bm[505]} ${bm_insts[505]} 45"
      "./partition_run_spec2017_m1.sh ${WORK_DIR} ${bm[510]} ${bm_insts[510]} 46"
      "./partition_run_spec2017_m1.sh ${WORK_DIR} ${bm[531]} ${bm_insts[531]} 64"
      "./partition_run_spec2017_m1.sh ${WORK_DIR} ${bm[521]} ${bm_insts[521]} 65"
      "./partition_run_spec2017_m1.sh ${WORK_DIR} ${bm[549]} ${bm_insts[549]} 68"
      "./partition_run_spec2017_m1.sh ${WORK_DIR} ${bm[508]} ${bm_insts[508]} 102"
      "./partition_run_spec2017_m1.sh ${WORK_DIR} ${bm[548]} ${bm_insts[548]} 143"
      "./partition_run_spec2017_m1.sh ${WORK_DIR} ${bm[527]} ${bm_insts[527]} 184"
    )
  else
    opts=(
      "./partition_run_spec2017_m1.sh ${WORK_DIR} ${bm[502]} ${bm_insts[502]} - ${slice_len}"
      "./partition_run_spec2017_m1.sh ${WORK_DIR} ${bm[999]} ${bm_insts[999]} - ${slice_len}"
      "./partition_run_spec2017_m1.sh ${WORK_DIR} ${bm[538]} ${bm_insts[538]} - ${slice_len}"
      "./partition_run_spec2017_m1.sh ${WORK_DIR} ${bm[523]} ${bm_insts[523]} - ${slice_len}"
      "./partition_run_spec2017_m1.sh ${WORK_DIR} ${bm[557]} ${bm_insts[557]} - ${slice_len}"
      "./partition_run_spec2017_m1.sh ${WORK_DIR} ${bm[526]} ${bm_insts[526]} - ${slice_len}"
      "./partition_run_spec2017_m1.sh ${WORK_DIR} ${bm[525]} ${bm_insts[525]} - ${slice_len}"
      "./partition_run_spec2017_m1.sh ${WORK_DIR} ${bm[511]} ${bm_insts[511]} - ${slice_len}"
      "./partition_run_spec2017_m1.sh ${WORK_DIR} ${bm[500]} ${bm_insts[500]} - ${slice_len}"
      "./partition_run_spec2017_m1.sh ${WORK_DIR} ${bm[519]} ${bm_insts[519]} - ${slice_len}"
      "./partition_run_spec2017_m1.sh ${WORK_DIR} ${bm[544]} ${bm_insts[544]} - ${slice_len}"
      "./partition_run_spec2017_m1.sh ${WORK_DIR} ${bm[503]} ${bm_insts[503]} - ${slice_len}"
      "./partition_run_spec2017_m1.sh ${WORK_DIR} ${bm[520]} ${bm_insts[520]} - ${slice_len}"
      "./partition_run_spec2017_m1.sh ${WORK_DIR} ${bm[554]} ${bm_insts[554]} - ${slice_len}"
      "./partition_run_spec2017_m1.sh ${WORK_DIR} ${bm[507]} ${bm_insts[507]} - ${slice_len}"
      "./partition_run_spec2017_m1.sh ${WORK_DIR} ${bm[541]} ${bm_insts[541]} - ${slice_len}"
      "./partition_run_spec2017_m1.sh ${WORK_DIR} ${bm[505]} ${bm_insts[505]} - ${slice_len}"
      "./partition_run_spec2017_m1.sh ${WORK_DIR} ${bm[510]} ${bm_insts[510]} - ${slice_len}"
      "./partition_run_spec2017_m1.sh ${WORK_DIR} ${bm[531]} ${bm_insts[531]} - ${slice_len}"
      "./partition_run_spec2017_m1.sh ${WORK_DIR} ${bm[521]} ${bm_insts[521]} - ${slice_len}"
      "./partition_run_spec2017_m1.sh ${WORK_DIR} ${bm[549]} ${bm_insts[549]} - ${slice_len}"
      "./partition_run_spec2017_m1.sh ${WORK_DIR} ${bm[508]} ${bm_insts[508]} - ${slice_len}"
      "./partition_run_spec2017_m1.sh ${WORK_DIR} ${bm[548]} ${bm_insts[548]} - ${slice_len}"
      "./partition_run_spec2017_m1.sh ${WORK_DIR} ${bm[527]} ${bm_insts[527]} - ${slice_len}"
    )
  fi
  for opt in "${opts[@]}" ;do
    read -u6
    {
      ${opt} >>nohup.out 2>&1
      echo >&6
    }&
  done
}

func_collect_handle_all_m1_restore_data(){
#sum=0
  bm=(
    "500.perlbench_r" "502.gcc_r" "505.mcf_r" "520.omnetpp_r" "523.xalancbmk_r" "525.x264_r" "531.deepsjeng_r" "541.leela_r" "548.exchange2_r" "557.xz_r"
    "503.bwaves_r" "507.cactuBSSN_r" "508.namd_r" "510.parest_r" "511.povray_r" "519.lbm_r" "521.wrf_r" "526.blender_r" "527.cam4_r" "538.imagick_r" "544.nab_r" "549.fotonik3d_r" "554.roms_r" "999.specrand_ir"
  )
  rm -rf each_bm_cpt_m1.csv summary_bm_cpt_m1.csv
  for FILE in ${bm[@]}
  do
    #FILE="502.gcc_r"
    find ./runspec_gem5_power/"${FILE}"/CPI_result/5000000_Calculate_WeightedCPI.log -exec sort -n -b -r -k 2 {} \; | \
    awk -v FILE="${FILE}" 'BEGIN {
        OFS = ",";
        sum_weight = 0;sum = 0;cred=0;
        print "Benchmark","Simpts","Weights","CPI","WeightedCPI"
      }
      {
        sum_weight += $2;
        if ($3 != 0)
          cred += $2;
        sum += $4;
        print FILE,$1,$2,$3,$4
      }
      END {
        #if (sum_weight > 0.999)
        #  print FILE,"COMPLETED",FILE,"Credibility:%"cred*100,"SumWeightedCPI:"sum;
        #else
        #  print FILE,"UN-COMPLETED:%"sum_weight*100,FILE,"Credibility:%"cred*100,"SumWeightedCPI:"sum;
        :
      }' >>each_bm_cpt_m1.csv
    echo >> each_bm_cpt_m1.csv
  done
  echo "Benchmark,Credibility,M1 Sum Weighted CPI"| tee -a summary_bm_cpt_m1.csv
  for FILE in ${bm[@]}
  do
    array=(`grep -oP "(.*),(.*),(${FILE}.*),(Credibility:.*),(SumWeightedCPI:\d+\.*\d*)" each_bm_cpt_m1.csv|awk -F ',' '{print $2,$3,$4,$5 }'`)
#    for a in ${array[@]}
#    do
#      echo $a
#    done
    if [[ ${#array[@]} -gt 0 && "${array[0]}" == "COMPLETED" ]]; then
      echo "${array[1]},${array[2]#Credibility:},${array[3]#SumWeightedCPI:}" |tee -a summary_bm_cpt_m1.csv
    else
      echo "${FILE}," |tee -a summary_bm_cpt_m1.csv
    fi
  done
}

# 检查当前后台restore运行情况
func_detect_restore_bg(){
  detect_task_regex=${1}
  is_print=${2}

  if [[ ${is_print} == true ]];then
    echo "DETECTING background tasks..."
  fi
  while : ; do
    # kill run job
    run_names=(`ps -o pid,time,command -u $(whoami) | grep -P "${detect_task_regex}" | grep -v grep| awk '{print \$5}'`)
    run_nums=(`ps -o pid,time,command -u $(whoami) | grep -P "${detect_task_regex}" | grep -v grep| awk '{print \$1}'`)
    if [[ ${#run_nums[@]} -gt 0 ]]; then
      :
      sleep 1s
      for run_name in ${run_names[@]}; do
        if [[ ${run_name} =~ .*output_ckp.* ]]; then
          if [[ ${is_print} == true ]];then
            echo "RUNNING: ${run_name}..."
          fi
        fi
      done
    else
      break
    fi
  done
}

# gem5spec目录下调用
# 统计restore数据, 生成对比表格
func_gen_restore_compare_excel(){
  begin_time="${1}"
  echo >>nohup.out
  echo "make cpi_all_cases -C runspec_gem5_power start @ $(date +"%Y-%m-%d %H:%M:%S.%N"| cut -b 1-23)" >>nohup.out 2>&1
  make cpi_all_cases -C runspec_gem5_power >/dev/null 2>&1
  echo "make cpi_all_cases -C runspec_gem5_power done @ $(date +"%Y-%m-%d %H:%M:%S.%N"| cut -b 1-23)" >>nohup.out 2>&1
  make collect_all_checkpoints_data -C runspec_gem5_power >>nohup.out 2>&1
  echo "make collect_all_checkpoints_data -C runspec_gem5_power done @ $(date +"%Y-%m-%d %H:%M:%S.%N"| cut -b 1-23)" >>nohup.out 2>&1
  mkdir -p ./data/gem5/"${begin_time}"/
  cp ./runspec_gem5_power/Each_case_ckp_data.csv ./data/gem5/"${begin_time}"/ >>nohup.out 2>&1
  python3 ./scripts/gem5_M1_host_results_compare.py "${begin_time}"
  echo "python3 ./scripts/gem5_M1_host_results_compare.py ${begin_time} done @ $(date +"%Y-%m-%d %H:%M:%S.%N"| cut -b 1-23)" >>nohup.out 2>&1
}

#gem5spec目录下执行
# 运行完会备份结果
# gem5: -->./data/"${begin_time}"/gem5/"${FILE}
# 包含以下文件
#       gem5_stats.log
#       stdout_gem5.log
#       stderr_gem5.log
# m1:   -->./data/"${begin_time}"/M1/"${FILE}"'
# 包含以下文件
#       each_bm_cpt_m1.csv
#       summary_bm_cpt_m1.csv
func_with_restore_all_benchmarks(){
  bm=(
    "500.perlbench_r" "502.gcc_r" "505.mcf_r" "520.omnetpp_r" "523.xalancbmk_r" "525.x264_r" "531.deepsjeng_r" "541.leela_r" "548.exchange2_r" "557.xz_r"
    "503.bwaves_r" "507.cactuBSSN_r" "508.namd_r" "510.parest_r" "511.povray_r" "519.lbm_r" "521.wrf_r" "526.blender_r" "527.cam4_r" "538.imagick_r" "544.nab_r" "549.fotonik3d_r" "554.roms_r" "999.specrand_ir"
  )
  FLOODGATE=${1}
  begin_time=${2}
  WORK_DIR=${3}
  parallel_jobs=${4}
  date1=$(date +"%Y-%m-%d %H:%M:%S")
  for FILE in ${bm[@]}
  do
    read -u6
    {
      echo >&6
      if [[ $is_gem5 == true ]]; then
        mkdir -p ./data/gem5/"${begin_time}"/"${FILE}"
        opt="make restore_all -C runspec_gem5_power/${FILE} FLOODGATE=${FLOODGATE} WORK_DIR=${WORK_DIR}"
        ${opt} >>nohup.out 2>&1
        # 每运行完一个benchmark做出统计
        wait
        func_detect_restore_bg "gem5.opt -d ${WORK_DIR}/${FILE}/output_ckp\d+" false
        opt="make cpi -C runspec_gem5_power/${FILE} FLOODGATE=${FLOODGATE} WORK_DIR=${WORK_DIR}"
        ${opt} >/dev/null 2>&1
      elif [[ $is_m1 == true ]]; then
        mkdir -p ./data/M1/"${begin_time}"/"${FILE}"
        opt="make find_interval_size -C runspec_gem5_power/${FILE} BACKUP_PATH=$(cd "$(dirname "${0}")" && pwd )/data/M1/${begin_time}/${FILE}/ FLOODGATE=${FLOODGATE}"
        ${opt} >>nohup.out 2>&1
      fi
    }&
  done
  wait

  # 检测是否被中断，如果被中断则不存在FLOODGATE，程序退出
  if [[ ! -p ${FLOODGATE} ]];then
    exit 1
  fi

  func_detect_restore_bg "gem5.opt -d ${WORK_DIR}/[\/\w\.]+/output_ckp\d+" true
  echo "func_with_restore_all_benchmarks ${FLOODGATE} ${begin_time} done @ $(date +"%Y-%m-%d %H:%M:%S.%N"| cut -b 1-23)" >>nohup.out 2>&1
  date2=$(date +"%Y-%m-%d %H:%M:%S")
  sys_date1=$(date -d "$date1" +%s)
  sys_date2=$(date -d "$date2" +%s)
  seconds=`expr $sys_date2 - $sys_date1`
  hour=$(( $seconds/3600 ))
  min=$(( ($seconds-${hour}*3600)/60 ))
  sec=$(( $seconds-${hour}*3600-${min}*60 ))
  HMS=`echo ${hour}:${min}:${sec}`

  echo "restore_all consumed time : ${HMS} at ${date1} "|tee ./runspec_gem5_power/restore_all_consumed_time.log
  # backup
  if [[ $is_gem5 == true ]]; then
    # 统计数据
    func_gen_restore_compare_excel "${begin_time}"
    # 备份数据
    for FILE in ${bm[@]}
    do
        mkdir -p ./data/gem5/"${begin_time}"/"${FILE}"
        find ./runspec_gem5_power/"${FILE}"/ -name "*.csv" -exec cp -r {} ./data/gem5/"${begin_time}"/"${FILE}" \;
        # cp -r ./runspec_gem5_power/"${FILE}"/gem5_stats.log ./data/gem5/"${begin_time}"/"${FILE}"
        # cp -r ./runspec_gem5_power/"${FILE}"/stdout_gem5.log ./data/gem5/"${begin_time}"/"${FILE}"
        # cp -r ./runspec_gem5_power/"${FILE}"/stderr_gem5.log ./data/gem5/"${begin_time}"/"${FILE}"
    done
    mv ./runspec_gem5_power/restore_all_consumed_time.log ./data/gem5/"${begin_time}"/ 2>/dev/null
    mv ./nohup.out ./data/gem5/"${begin_time}"/ 2>/dev/null
  elif [[ $is_m1 == true ]]; then
    func_collect_handle_all_m1_restore_data
    for FILE in ${bm[@]}
    do
      mkdir -p ./data/M1/"${begin_time}"/"${FILE}"
      mv ./runspec_gem5_power/"${FILE}"/*.csv ./data/M1/"${begin_time}"/"${FILE}"/ 2>/dev/null
    done
    mv *.csv ./data/M1/"${begin_time}"/ 2>/dev/null
    mv ./nohup.out ./data/M1/"${begin_time}"/ 2>/dev/null
    mv ./runspec_gem5_power/restore_all_consumed_time.log ./data/M1/"${begin_time}"/ 2>/dev/null
  fi
  exec 6>&-
  exec 6<&-
  # delete job pool
  rm -rf $(dirname ${FLOODGATE})
}

func_with_restore_all_benchmarks_n4(){
  bm=(
    "500.perlbench_r" "502.gcc_r" "505.mcf_r" "520.omnetpp_r" "523.xalancbmk_r" "525.x264_r" "531.deepsjeng_r" "541.leela_r" "548.exchange2_r" "557.xz_r"
    "503.bwaves_r" "507.cactuBSSN_r" "508.namd_r" "510.parest_r" "511.povray_r" "519.lbm_r" "521.wrf_r" "526.blender_r" "527.cam4_r" "538.imagick_r" "544.nab_r" "549.fotonik3d_r" "554.roms_r" "999.specrand_ir"
  )
  FLOODGATE=${1}
  begin_time=${2}
  WORK_DIR=${3}
  parallel_jobs=${4}
  date1=$(date +"%Y-%m-%d %H:%M:%S")
  for FILE in ${bm[@]}
  do
    read -u6
    {
      echo >&6
      if [[ $is_gem5 == true ]]; then
        mkdir -p ./data/gem5/"${begin_time}"/"${FILE}"
        opt="make restore_all_4 -C runspec_gem5_power/${FILE} FLOODGATE=${FLOODGATE} WORK_DIR=${WORK_DIR}"
        ${opt} >>nohup.out 2>&1
        # 每运行完一个benchmark做出统计
        wait
#        func_detect_restore_bg "gem5.opt -d ${WORK_DIR}/${FILE}/output_ckp\d+" false
#        opt="make cpi -C runspec_gem5_power/${FILE} FLOODGATE=${FLOODGATE} WORK_DIR=${WORK_DIR}"
#        ${opt} >/dev/null 2>&1
      elif [[ $is_m1 == true ]]; then
        mkdir -p ./data/M1/"${begin_time}"/"${FILE}"
        opt="make find_interval_size -C runspec_gem5_power/${FILE} BACKUP_PATH=$(cd "$(dirname "${0}")" && pwd )/data/M1/${begin_time}/${FILE}/ FLOODGATE=${FLOODGATE}"
        ${opt} >>nohup.out 2>&1
      fi
    }&
  done
  wait

  # 检测是否被中断，如果被中断则不存在FLOODGATE，程序退出
  if [[ ! -p ${FLOODGATE} ]];then
    exit 1
  fi

  func_detect_restore_bg "gem5.opt -d ${WORK_DIR}/[\/\w\.]+/output_ckp\d+" true
  echo "func_with_restore_all_benchmarks_n4 ${FLOODGATE} ${begin_time} done @ $(date +"%Y-%m-%d %H:%M:%S.%N"| cut -b 1-23)" >>nohup.out 2>&1
  date2=$(date +"%Y-%m-%d %H:%M:%S")
  sys_date1=$(date -d "$date1" +%s)
  sys_date2=$(date -d "$date2" +%s)
  seconds=`expr $sys_date2 - $sys_date1`
  hour=$(( $seconds/3600 ))
  min=$(( ($seconds-${hour}*3600)/60 ))
  sec=$(( $seconds-${hour}*3600-${min}*60 ))
  HMS=`echo ${hour}:${min}:${sec}`

  echo "restore_all_4 consumed time : ${HMS} at ${date1} "|tee ./runspec_gem5_power/restore_all_consumed_time.log
#  # backup
#  if [[ $is_gem5 == true ]]; then
#    # 统计数据
#    func_gen_restore_compare_excel "${begin_time}"
#    # 备份数据
#    for FILE in ${bm[@]}
#    do
#        mkdir -p ./data/gem5/"${begin_time}"/"${FILE}"
#        find ./runspec_gem5_power/"${FILE}"/ -name "*.csv" -exec cp -r {} ./data/gem5/"${begin_time}"/"${FILE}" \;
#        # cp -r ./runspec_gem5_power/"${FILE}"/gem5_stats.log ./data/gem5/"${begin_time}"/"${FILE}"
#        # cp -r ./runspec_gem5_power/"${FILE}"/stdout_gem5.log ./data/gem5/"${begin_time}"/"${FILE}"
#        # cp -r ./runspec_gem5_power/"${FILE}"/stderr_gem5.log ./data/gem5/"${begin_time}"/"${FILE}"
#    done
#    mv ./runspec_gem5_power/restore_all_consumed_time.log ./data/gem5/"${begin_time}"/ 2>/dev/null
#    mv ./nohup.out ./data/gem5/"${begin_time}"/ 2>/dev/null
#  elif [[ $is_m1 == true ]]; then
#    func_collect_handle_all_m1_restore_data
#    for FILE in ${bm[@]}
#    do
#      mkdir -p ./data/M1/"${begin_time}"/"${FILE}"
#      mv ./runspec_gem5_power/"${FILE}"/*.csv ./data/M1/"${begin_time}"/"${FILE}"/ 2>/dev/null
#    done
#    mv *.csv ./data/M1/"${begin_time}"/ 2>/dev/null
#    mv ./nohup.out ./data/M1/"${begin_time}"/ 2>/dev/null
#    mv ./runspec_gem5_power/restore_all_consumed_time.log ./data/M1/"${begin_time}"/ 2>/dev/null
#  fi
  exec 6>&-
  exec 6<&-
  # delete job pool
  rm -rf $(dirname ${FLOODGATE})
}

func_with_cpi_all_benchmarks(){
  if [[ $is_gem5 == true ]]; then
    opts=(
      "make cpi -C runspec_gem5_power/${bm[502]} "
      "make cpi -C runspec_gem5_power/${bm[999]} "
      "make cpi -C runspec_gem5_power/${bm[538]} "
      "make cpi -C runspec_gem5_power/${bm[523]} "
      "make cpi -C runspec_gem5_power/${bm[557]} "
      "make cpi -C runspec_gem5_power/${bm[526]} "
      "make cpi -C runspec_gem5_power/${bm[525]} "
      "make cpi -C runspec_gem5_power/${bm[511]} "
      "make cpi -C runspec_gem5_power/${bm[500]} "
      "make cpi -C runspec_gem5_power/${bm[519]} "
      "make cpi -C runspec_gem5_power/${bm[544]} "
      "make cpi -C runspec_gem5_power/${bm[503]} "
      "make cpi -C runspec_gem5_power/${bm[520]} "
      "make cpi -C runspec_gem5_power/${bm[554]} "
      "make cpi -C runspec_gem5_power/${bm[507]} "
      "make cpi -C runspec_gem5_power/${bm[541]} "
      "make cpi -C runspec_gem5_power/${bm[505]} "
      "make cpi -C runspec_gem5_power/${bm[510]} "
      "make cpi -C runspec_gem5_power/${bm[531]} "
      "make cpi -C runspec_gem5_power/${bm[521]} "
      "make cpi -C runspec_gem5_power/${bm[549]} "
      "make cpi -C runspec_gem5_power/${bm[508]} "
      "make cpi -C runspec_gem5_power/${bm[548]} "
      "make cpi -C runspec_gem5_power/${bm[527]} "
    )
    for opt in "${opts[@]}" ;do
      read -u6
      {
        ${opt} >>nohup.out 2>&1
        echo >&6
      }&
    done
    wait
    make cpi_all -C runspec_gem5_power
  elif [[ $is_m1 == true ]]; then
    find ./runspec_gem5_power/*r/CPI_result/*CPI_result*.log -exec basename {} \;|grep -oP "(\d+).*CPI_result_(\d+\.*\d+)"|awk -F "_CPI_result_" 'BEGIN{print "Benchmark","WeightedCPI"} {print $1" "$2}'|column -t >m1_restore.csv
  fi

}

func_m1_args_parser(){
  # echo "320"
  # echo $1
  while [[ -n "${1#*=}" ]]
  do
    case "${1#*=}" in
      --i_insts|--NUM_INSNS_TO_COLLECT)
        with_i_insts=true
        NUM_INSNS_TO_COLLECT="${2#*=}"
        args+="NUM_INSNS_TO_COLLECT="${2#*=}" "
        shift
        ;;
      -j|--q_jump|--JUMP_NUM)
        with_q_jump=true
        JUMP_NUM="${2#*=}"
        args+="JUMP_NUM="${2#*=}" "
        shift
        ;;
      -c|--q_convert|--CONVERT_NUM_Vgi_RECS)
        with_q_convert=true
        CONVERT_NUM_Vgi_RECS="${2#*=}"
        args+="CONVERT_NUM_Vgi_RECS="${2#*=}" "
        shift
        ;;
      --r_insts|--NUM_INST)
        with_r_insts=true
        NUM_INST="${2#*=}"
        args+="NUM_INST="${2#*=}" "
        shift
        ;;
      --r_cpi_interval|--CPI_INTERVAL)
        with_r_cpi_interval=true
        CPI_INTERVAL="${2#*=}"
        args+="CPI_INTERVAL="${2#*=}" "
        shift
        ;;
      --r_reset_stats|--RESET_STATS)
        with_r_reset_stats=true
        RESET_STATS="${2#*=}"
        args+="RESET_STATS="${2#*=}" "
        shift
        ;;
      --r_pipe_type|--SCROLL_PIPE)
        with_r_pipe_type=true
        SCROLL_PIPE="${2#*=}"
        args+="SCROLL_PIPE="${2#*=}" "
        shift
        ;;
      -b|--r_pipe_begin|--SCROLL_BEGIN)
        with_r_pipe_begin=true
        SCROLL_BEGIN="${2#*=}"
        args+="SCROLL_BEGIN="${2#*=}" "
        # echo $SCROLL_BEGIN
        shift
        ;;
      -e|--r_pipe_end|--SCROLL_END)
        with_r_pipe_end=true
        SCROLL_END="${2#*=}"
        args+="SCROLL_END="${2#*=}" "
        # echo $SCROLL_END
        shift
        ;;
      --gen_txt)
        :
        ;;
      --)
        shift
        ;;
      *)
        exit 1
        ;;
    esac
    shift
  done
  # echo $args
}

func_itrace_all_benchmarks(){
  make itrace -C runspec_gem5_power/${bm[502]} NUM_INSNS_TO_COLLECT=${bm_insts[502]} &
  make itrace -C runspec_gem5_power/${bm[999]} NUM_INSNS_TO_COLLECT=${bm_insts[999]} &
  make itrace -C runspec_gem5_power/${bm[538]} NUM_INSNS_TO_COLLECT=${bm_insts[538]} &
  make itrace -C runspec_gem5_power/${bm[523]} NUM_INSNS_TO_COLLECT=${bm_insts[523]} &
  make itrace -C runspec_gem5_power/${bm[557]} NUM_INSNS_TO_COLLECT=${bm_insts[557]} &
  make itrace -C runspec_gem5_power/${bm[526]} NUM_INSNS_TO_COLLECT=${bm_insts[526]} &
  make itrace -C runspec_gem5_power/${bm[525]} NUM_INSNS_TO_COLLECT=${bm_insts[525]} &
  make itrace -C runspec_gem5_power/${bm[511]} NUM_INSNS_TO_COLLECT=${bm_insts[511]} &
  make itrace -C runspec_gem5_power/${bm[500]} NUM_INSNS_TO_COLLECT=${bm_insts[500]} &
  make itrace -C runspec_gem5_power/${bm[519]} NUM_INSNS_TO_COLLECT=${bm_insts[519]} &
  make itrace -C runspec_gem5_power/${bm[544]} NUM_INSNS_TO_COLLECT=${bm_insts[544]} &
  make itrace -C runspec_gem5_power/${bm[503]} NUM_INSNS_TO_COLLECT=${bm_insts[503]} &
  make itrace -C runspec_gem5_power/${bm[520]} NUM_INSNS_TO_COLLECT=${bm_insts[520]} &
  make itrace -C runspec_gem5_power/${bm[554]} NUM_INSNS_TO_COLLECT=${bm_insts[554]} &
  make itrace -C runspec_gem5_power/${bm[507]} NUM_INSNS_TO_COLLECT=${bm_insts[507]} &
  make itrace -C runspec_gem5_power/${bm[541]} NUM_INSNS_TO_COLLECT=${bm_insts[541]} &
  make itrace -C runspec_gem5_power/${bm[505]} NUM_INSNS_TO_COLLECT=${bm_insts[505]} &
  make itrace -C runspec_gem5_power/${bm[510]} NUM_INSNS_TO_COLLECT=${bm_insts[510]} &
  make itrace -C runspec_gem5_power/${bm[531]} NUM_INSNS_TO_COLLECT=${bm_insts[531]} &
  make itrace -C runspec_gem5_power/${bm[521]} NUM_INSNS_TO_COLLECT=${bm_insts[521]} &
  make itrace -C runspec_gem5_power/${bm[549]} NUM_INSNS_TO_COLLECT=${bm_insts[549]} &
  make itrace -C runspec_gem5_power/${bm[508]} NUM_INSNS_TO_COLLECT=${bm_insts[508]} &
  make itrace -C runspec_gem5_power/${bm[548]} NUM_INSNS_TO_COLLECT=${bm_insts[548]} &
  make itrace -C runspec_gem5_power/${bm[527]} NUM_INSNS_TO_COLLECT=${bm_insts[527]} &
}

func_collect_all_m1_restore_data(){
  sed -i '$G' ./runspec_gem5_power/*r/CPI_result/*_CPI_result.merge
  cat ./runspec_gem5_power/*r/CPI_result/*_CPI_result.merge >>each_bm_cpt_m1.csv
}

# kill 之后会删除线程池
func_kill_restore_all_jobs(){
  FLOODGATE=${2}
  while : ; do
    # check job run
    if [[ ! -p ${FLOODGATE} ]];then
      mkfifo ${FLOODGATE}
      rm -rf runJobPoolSize*.log
      touch "$(dirname ${FLOODGATE})"/runJobPoolSize_0.log
    fi
    exec 6<>${FLOODGATE}
    echo >&6;echo >&6;echo >&6;echo >&6;echo >&6;echo >&6;echo >&6;echo >&6;
    max_jobs=$(find $(dirname ${FLOODGATE})/runJobPoolSize_*.log -exec basename {} \;|grep -oP "\d+")
    ((max_jobs+=8))
    if [[ -p ${FLOODGATE} ]];then
      rename "s/runJobPoolSize_\d+/runJobPoolSize_${max_jobs}/" "$(dirname ${FLOODGATE})"/runJobPoolSize_*.log
    fi
    # kill run job
    run_names=(`ps -o pid,time,command -u $(whoami) | grep -P "${1}" | grep -v grep| awk '{print \$5}'`)
    run_nums=(`ps -o pid,time,command -u $(whoami) | grep -P "${1}" | grep -v grep| awk '{print \$1}'`)
    if [[ ${#run_nums[@]} -gt 0 ]]; then
      for run_name in ${run_names[@]}; do
        if [[ ${run_name} =~ .*output_ckp.* ]]; then
          echo "RUNNING: kill ${run_name}..."
        fi
      done
      echo ${run_nums[@]}|xargs kill
    else
      break
    fi
  done
  # delete job pool
  rm -rf $(dirname ${FLOODGATE})
}

# 进入单个benchmark目录下运行，若第一次运行时生成了each_bm_cpt_m1.csv，受到异常被中断后继续运行，M1的结果已保存在M1_result目录，
# 将根据each_bm_cpt_m1.csv和M1_result中的results文件进行结果合并，恢复数据
func_recovery(){
  FILE=$(basename $PWD)
  Simpts_Array=(`awk '{print $(NF-1)}' ${FILE}.merge`)
  Weight_Array=(`awk '{print $(NF)}' ${FILE}.merge`)
  Interval_size=5000000

  rm ./CPI_result/${Interval_size}_Calculate_WeightedCPI.log
  for (( j=0;j<${#Simpts_Array[@]};j++)) do
    Simpts=${Simpts_Array[j]}
    Weight=${Weight_Array[j]}
    had_result=false
    if [[ -e ../../each_bm_cpt_m1.csv ]]; then
      array=(`grep -oP "(.*${FILE}.*),(${Simpts}),(.*${Weight}.*),(.*\d+\.*\d*),(.*)" ../../each_bm_cpt_m1.csv|awk -F ',' '{print $1,$2,$3,$4,$5}'`)
      #echo ${array[@]}
      if [[ ${#array[@]} == 4 || ${#array[@]} == 5 ]]; then
        echo "existing,FILE=${FILE},Simpts=${Simpts},Weight=${Weight},,"${array[1]}"_${Interval_size}_"${array[0]}".results"|tee -a gen_m1_results.csv
        echo "${array[1]} ${array[2]} ${array[3]} ${array[4]}">>./CPI_result/${Interval_size}_Calculate_WeightedCPI.log
        had_result=true
      elif [ ${#array[@]} -gt 0 ]; then
        echo "exception,"${array[0]}","${array[1]}"_${Interval_size}_"${array[0]}".results"|tee -a gen_m1_results.csv
        had_result=false
      else
        echo "not existing,FILE=${FILE},Simpts=${Simpts},Weight=${Weight},${Simpts}_${Interval_size}_${FILE}.results"|tee -a gen_m1_results.csv
        had_result=false
      fi
    fi
    if [[ $had_result == false ]]; then
      qt_records=0
      qt_records=$(grep -oP "Created \d+ qt records" M1_result/"${Simpts}"_${Interval_size}_${FILE}_trace.log |grep -oP "\d+")
      if [[ $qt_records == 5000000 ]]; then
        CPI=`grep 'CMPL: CPI--------------------------------------- .* inst.*' ./M1_result/${Simpts}_${Interval_size}_${FILE}.results |awk '{print $3}'`
        echo ${Simpts} $Weight $CPI | awk '{print($1" "$2" "$3" "$2*$3)}' >> ./CPI_result/${Interval_size}_Calculate_WeightedCPI.log
      elif [[ $qt_records == 0 ]]; then
        CPI=0
        echo ${Simpts} $Weight $CPI | awk '{print($1" "$2" "$3" ")}' >> ./CPI_result/${Interval_size}_Calculate_WeightedCPI.log
      else
        CPI=-1
        echo ${Simpts} $Weight $CPI | awk '{print($1" "$2" "$3" ")}' >> ./CPI_result/${Interval_size}_Calculate_WeightedCPI.log
      fi
    fi
  done
}