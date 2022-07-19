

version="1.0.0"

#解析命令行选项<optstring>及参数<parameters>

getopt_cmd=$(getopt \
-o aiqrphvVj:c:b:e: \
-l m1,spec2017:,myexe:,\
all,all_steps,entire,itrace,qtrace,run_timer,pipe_view,\
i_insts:,q_jump:,q_convert:,r_insts:,r_cpi_interval:,r_pipe_type:,r_pipe_begin:,r_pipe_end:,\
version,verbose,help \
-n "$(basename "$0")" -- "$@"
)

[ $? -ne 0 ] && exit 1
eval set -- "${getopt_cmd}"

#判断选项
is_m1=false
is_gem5=false
is_host=false
is_myexe=false
is_spec2017=false
with_all_benchmarks=false
with_entire_all_benchmarks=false
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


#spec2017 benchmark
bm_insts=(\
[502]=19000000 [999]=62000000 [538]=110000000 [523]=380000000 [557]=740000000 [526]=1400000000 [525]=2400000000 [511]=2800000000 \
[500]=3300000000 [519]=6800000000 [544]=7000000000 [503]=15000000000 [520]=15000000000 [554]=18000000000 [507]=19000000000 [541]=29000000000 \
[505]=32000000000 [510]=33000000000 [531]=45000000000 [521]=46000000000 [549]=48000000000 [508]=72000000000 [548]=100000000000 [527]=130000000000 )

bm=(\
[502]="502.gcc_r" [999]="999.specrand_ir" [538]="538.imagick_r" [523]="523.xalancbmk_r" [557]="557.xz_r" [526]="526.blender_r" [525]="525.x264_r" [511]="511.povray_r" \
[500]="500.perlbench_r" [519]="519.lbm_r" [544]="544.nab_r" [503]="503.bwaves_r" [520]="520.omnetpp_r" [554]="554.roms_r" [507]="507.cactuBSSN_r" [541]="541.leela_r" \
[505]="505.mcf_r" [510]="510.parest_r" [531]="531.deepsjeng_r" [521]="521.wrf_r" [549]="549.fotonik3d_r" [508]="508.namd_r" [548]="548.exchange2_r" [527]="527.cam4_r")
#${bm[502]}

#echo ${@}

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

func_help(){
  cat <<- EOF
  Desc: run some spec2017 benchmarks and custom programs help
  Notion: []内表示可选，｜表示选择一个，<>内表示必须填
  Usage: ./run.sh MAIN_OPTS FIR_OPTS SEC_OPTS

    MAIN_OPTS:
    |  --m1,                                                                     使用power8模拟器
    FIR_OPTS:
    |  --myexe <exepath> [--entire]                                              使用自定义的程序(编译后的)
                          --entire                                               按最大指令数执行，超过700,000,000条指令的将按照700,000,000分段执行
    |  --spec2017 <benchmark num>|--all_benchmarks|--entire_all_benchmarks       使用spec2017某一个或者全部
                  --all_benchmarks -j=<num> -c=<num> -b=<num> -e=<num>           所有的benchmark执行指令数均为-c指定,itrace按最大指令数转换,流水线图指令区间为[j+b,j+e-b+1]
                  --entire_all_benchmarks                                        所有的benchmark按最大指令数执行,超过700,000,000条指令的将按照700,000,000分段执行
                  <benchmark num>                                                [502|999|538|523|557|526|525|511|500|519|544|503|520|554|507|541|505|510|531|521|549|508|548|527]

    SEC_OPTS:
    |  -a --i_insts=<num> -j=<num> -c=<num> --r_insts=<num> -b=<num> -e=<num>
    |  -i --i_insts=<num>                                                        生成i_insts条指令的itrace
    |  -q -j=<num> -c=<num>                                                      生成[j,j+c]指令区间的qtrace
    |  -r --r_insts=<num> -b=<num> -e=<num>                                      在qtrace区间中执行r_insts条指令,流水线图指令区间为[j+b,j+e-b+1]
    |  -p                                                                        查看流水线图

    OPTS解释:
    --m1
    |  -a | --all             | --all_steps                                      执行使用m1的所有步骤
    |  -i | --itrace                                                             只生成itrace
    |  -q | --qtrace                                                             只转换qtrace
    |  -r | --run_timer                                                          只执行run_timer
    |  -p | --pipe_view                                                          只查看流水线
    |       --i_insts         | --NUM_INSNS_TO_COLLECT                           生成itrace指定的指令数
    |  -j | --q_jump          | --JUMP_NUM                                       生成qtrace跳过的指令数
    |  -c | --q_convert       | --CONVERT_NUM_Vgi_RECS                           生成qtrace转换的指令数
    |       --r_insts         | --NUM_INST                                       run_timer执行的指令数
    |       --r_cpi_interval  | --CPI_INTERVAL                                   可打印CPI的INTERVAL大小
    |       --r_reset_stats   | --RESET_STATS
    |       --r_pipe_type     | --SCROLL_PIPE                                    流水线类型 1为architected inst, 2为internal instruction, 3为cycle count
    |  -b | --r_pipe_begin    | --SCROLL_BEGIN                                   流水线图指令区间起始位置
    |  -e | --r_pipe_end      | --SCROLL_END                                     流水线图指令区间结束位置

    运行:
    PATTERN-1: 完整参数模式

    |  运行m1的整个流程,生成前2000000条指令的itrace,转换[9999,19999]条指令的qtrace,执行10000条,查看qtrace中前400条指令的流水线
       ./run.sh --m1 --spec2017 999 -a --i_insts=2000000 -j=9999 -c=10000 --r_insts=10000 -b=1 -e=400
       ./run.sh --m1 --myexe ./test -a --i_insts=2000000 -j=9999 -c=10000 --r_insts=10000 -b=1 -e=400

    |  所有的benchmark执行指令数均为5,000,000(q_convert\r_insts),itrace按最大指令数转换,流水线区间为[jump+1,jump+400]
       ./run.sh --m1 --spec2017 --all_benchmarks --q_jump=9999 --q_convert=5000000 --r_pipe_begin=1 --r_pipe_end=400

    |  所有的benchmark按最大指令数执行,超过700,000,000条指令的将按照700,000,000分段执行
       ./run.sh --m1 --spec2017 --entire_all_benchmarks

    |  test-p8按最大指令数执行，超过700,000,000条指令的将按照700,000,000分段执行
       ./run.sh --m1 --myexe ./test-p8 --entire

    PATTERN-2: 缺省参数模式【推荐】

    |  运行m1的整个流程,生成前最大指令数的itrace,qtrace区间为[begin,end],执行400条(end-begin+1),流水线区间为[begin,end]
       ./run.sh --m1 --spec2017 999 -b=1 -e=400
       ./run.sh --m1 --myexe ./test -b=1 -e=400
    
  :)END
EOF
    exit 0
}

case "${1#*=}" in
  -v|-h|--help|--verbose)
    func_help
    shift
    ;;
  -V|--version)
    echo "version=1.0.0"
    shift
    ;;
esac

case "${1#*=}" in
  --m1)
    is_m1=true
    shift
    ;;
esac


case "${1#*=}" in
  --myexe)
    is_myexe=true
    WORK_DIR=$(cd "$(dirname "${0}")" && pwd )
    EXE="${2#*=}"
    #OUTPUT="${WORK_DIR}"/$(basename "$EXE")
    EXE=$(dirname "$EXE")/$(basename "$EXE")
    shift 2
    ;;
  --spec2017)
    is_spec2017=true
    WORK_DIR=$(cd "$(dirname "${0}")" && pwd )/runspec_gem5_power
    case "${2#*=}" in
      502|999|538|523|557|526|525|511|500|519|544|503|520|554|507|541|505|510|531|521|549|508|548|527)
        spec2017_bm="${2#*=}"
        shift 2
        ;;
      --all_benchmarks)
        with_all_benchmarks=true
        shift 2
        while [ -n "${1#*=}" ]; do
            case "${1#*=}" in
              -j|--q_jump|--JUMP_NUM)
                JUMP_NUM="${2#*=}"
                shift
                ;;
              -c|--q_convert|--CONVERT_NUM_Vgi_RECS)
                CONVERT_NUM_Vgi_RECS="${2#*=}"
                NUM_INST="${2#*=}"
                shift
                ;;
              -b|--r_pipe_begin|--SCROLL_BEGIN)
                SCROLL_BEGIN="${2#*=}"
                shift
                ;;
              -e|--r_pipe_end|--SCROLL_END)
                SCROLL_END="${2#*=}"
                shift
                ;;
              --)
                shift
                ;;
              *)
                break
                ;;
            esac
            shift
        done
        ;;
      --entire_all_benchmarks)#用于查看整体CPI等数据
        with_entire_all_benchmarks=true
        shift 2
        ;;
      --)
        shift 2
        ;;
      *)
        exit 1
        ;;
    esac
    ;;
  --)
    shift
    ;;
  *)
    exit 1
    ;;
esac


if [[ $is_myexe == true ]]; then
  target=""
  args=""
  while [[ -n "${1#*=}" ]]
  do
    case "${1#*=}" in
      -a|--all|--all_steps)
        with_all_steps=true
        target=all
        ;;
      -i|--itrace)
        with_itrace=true
        target=itrace
        ;;
      -q|--qtrace)
        with_qtrace=true
        target=qtrace
        ;;
      -r|--run_timer)
        with_run_timer=true
        target=run_timer
        ;;
      -p|--pipe_view)
        with_pipe_view=true
        target=m1_pipeview
        ;;
      --entire)
        with_entire=true
        target=entire
        ;;
      --i_insts|--NUM_INSNS_TO_COLLECT)
        with_i_insts=true
        NUM_INSNS_TO_COLLECT="${2#*=}"
        shift
        ;;
      -j|--q_jump|--JUMP_NUM)
        with_q_jump=true
        JUMP_NUM="${2#*=}"
        shift
        ;;
      -c|--q_convert|--CONVERT_NUM_Vgi_RECS)
        with_q_convert=true
        CONVERT_NUM_Vgi_RECS="${2#*=}"
        shift
        ;;
      --r_insts|--NUM_INST)
        with_r_insts=true
        NUM_INST="${2#*=}"
        shift
        ;;
      --r_cpi_interval|--CPI_INTERVAL)
        with_r_cpi_interval=true
        CPI_INTERVAL="${2#*=}"
        shift
        ;;
      --r_reset_stats|--RESET_STATS)
        with_r_reset_stats=true
        RESET_STATS="${2#*=}"
        shift
        ;;
      --r_pipe_type|--SCROLL_PIPE)
        with_r_pipe_type=true
        SCROLL_PIPE="${2#*=}"
        shift
        ;;
      -b|--r_pipe_begin|--SCROLL_BEGIN)
        with_r_pipe_begin=true
        SCROLL_BEGIN="${2#*=}"
        shift
        ;;
      -e|--r_pipe_end|--SCROLL_END)
        with_r_pipe_end=true
        SCROLL_END="${2#*=}"
        shift
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
  #完整参数模式
  if [[ $with_all_steps == true || $with_itrace == true || $with_qtrace == true || $with_run_timer == true || $with_pipe_view == true || $with_entire == true ]] ; then
    if [[ "${CPI_INTERVAL}" == "-1" ]];then
      CPI_INTERVAL="${NUM_INST}"
    fi
#    ./p8-m1.sh "${EXE}" ${target} "${NUM_INSNS_TO_COLLECT}" "${JUMP_NUM}" "${CONVERT_NUM_Vgi_RECS}" "${NUM_INST}" "${CPI_INTERVAL}" "${RESET_STATS}" "${SCROLL_PIPE}" "${SCROLL_BEGIN}" "${SCROLL_END}"
    ./p8-m1.sh "${EXE}" --${target} "${NUM_INSNS_TO_COLLECT}" "${JUMP_NUM}" "${CONVERT_NUM_Vgi_RECS}" "${NUM_INST}" "${CPI_INTERVAL}" "${RESET_STATS}" "${SCROLL_PIPE}" "${SCROLL_BEGIN}" "${SCROLL_END}"
  #缺省参数模式1
  elif [[ $with_r_pipe_begin == true && $with_r_pipe_end == true ]]; then
    (( SCROLL_BEGIN = SCROLL_BEGIN - 1 ))
    (( insts = SCROLL_END - SCROLL_BEGIN ))
    JUMP_NUM=${SCROLL_BEGIN}
    CONVERT_NUM_Vgi_RECS=${insts}
    NUM_INST=${insts}
    CPI_INTERVAL="${NUM_INST}"
    SCROLL_BEGIN=1
    SCROLL_END=${insts}
    ./p8-m1.sh "${EXE}" -- "${NUM_INSNS_TO_COLLECT}" "${JUMP_NUM}" "${CONVERT_NUM_Vgi_RECS}" "${NUM_INST}" "${CPI_INTERVAL}" "${RESET_STATS}" "${SCROLL_PIPE}" "${SCROLL_BEGIN}" "${SCROLL_END}"
#      make trace -C runspec_gem5_power/"${bm[${spec2017_bm}]}" "NUM_INSNS_TO_COLLECT=${bm_insts[${spec2017_bm}]} JUMP_NUM=${pipe_b} CONVERT_NUM_Vgi_RECS=${insts} NUM_INST=${insts} CPI_INTERVAL=${insts} RESET_STATS=1 SCROLL_BEGIN=1 SCROLL_END=${insts}"
#      make m1_pipeview -C runspec_gem5_power/"${bm[${spec2017_bm}]}"
  fi
elif [[ $is_spec2017 == true ]]; then
  if [[ $with_all_benchmarks == true ]]; then
    (make trace -C runspec_gem5_power/500.perlbench_r NUM_INSNS_TO_COLLECT="${bm_insts[500]}" JUMP_NUM="${JUMP_NUM}" CONVERT_NUM_Vgi_RECS="${CONVERT_NUM_Vgi_RECS}" NUM_INST="${NUM_INST}" CPI_INTERVAL="${NUM_INST}" SCROLL_BEGIN="${SCROLL_BEGIN}" SCROLL_END="${SCROLL_END}" >>nohup.out 2>&1 &)
    (make trace -C runspec_gem5_power/502.gcc_r       NUM_INSNS_TO_COLLECT="${bm_insts[502]}" JUMP_NUM="${JUMP_NUM}" CONVERT_NUM_Vgi_RECS="${CONVERT_NUM_Vgi_RECS}" NUM_INST="${NUM_INST}" CPI_INTERVAL="${NUM_INST}" SCROLL_BEGIN="${SCROLL_BEGIN}" SCROLL_END="${SCROLL_END}" >>nohup.out 2>&1 &)
    (make trace -C runspec_gem5_power/503.bwaves_r    NUM_INSNS_TO_COLLECT="${bm_insts[503]}" JUMP_NUM="${JUMP_NUM}" CONVERT_NUM_Vgi_RECS="${CONVERT_NUM_Vgi_RECS}" NUM_INST="${NUM_INST}" CPI_INTERVAL="${NUM_INST}" SCROLL_BEGIN="${SCROLL_BEGIN}" SCROLL_END="${SCROLL_END}" >>nohup.out 2>&1 &)
    (make trace -C runspec_gem5_power/505.mcf_r       NUM_INSNS_TO_COLLECT="${bm_insts[505]}" JUMP_NUM="${JUMP_NUM}" CONVERT_NUM_Vgi_RECS="${CONVERT_NUM_Vgi_RECS}" NUM_INST="${NUM_INST}" CPI_INTERVAL="${NUM_INST}" SCROLL_BEGIN="${SCROLL_BEGIN}" SCROLL_END="${SCROLL_END}" >>nohup.out 2>&1 &)
    (make trace -C runspec_gem5_power/507.cactuBSSN_r NUM_INSNS_TO_COLLECT="${bm_insts[507]}" JUMP_NUM="${JUMP_NUM}" CONVERT_NUM_Vgi_RECS="${CONVERT_NUM_Vgi_RECS}" NUM_INST="${NUM_INST}" CPI_INTERVAL="${NUM_INST}" SCROLL_BEGIN="${SCROLL_BEGIN}" SCROLL_END="${SCROLL_END}" >>nohup.out 2>&1 &)
    (make trace -C runspec_gem5_power/508.namd_r      NUM_INSNS_TO_COLLECT="${bm_insts[508]}" JUMP_NUM="${JUMP_NUM}" CONVERT_NUM_Vgi_RECS="${CONVERT_NUM_Vgi_RECS}" NUM_INST="${NUM_INST}" CPI_INTERVAL="${NUM_INST}" SCROLL_BEGIN="${SCROLL_BEGIN}" SCROLL_END="${SCROLL_END}" >>nohup.out 2>&1 &)
    (make trace -C runspec_gem5_power/510.parest_r    NUM_INSNS_TO_COLLECT="${bm_insts[510]}" JUMP_NUM="${JUMP_NUM}" CONVERT_NUM_Vgi_RECS="${CONVERT_NUM_Vgi_RECS}" NUM_INST="${NUM_INST}" CPI_INTERVAL="${NUM_INST}" SCROLL_BEGIN="${SCROLL_BEGIN}" SCROLL_END="${SCROLL_END}" >>nohup.out 2>&1 &)
    (make trace -C runspec_gem5_power/511.povray_r    NUM_INSNS_TO_COLLECT="${bm_insts[511]}" JUMP_NUM="${JUMP_NUM}" CONVERT_NUM_Vgi_RECS="${CONVERT_NUM_Vgi_RECS}" NUM_INST="${NUM_INST}" CPI_INTERVAL="${NUM_INST}" SCROLL_BEGIN="${SCROLL_BEGIN}" SCROLL_END="${SCROLL_END}" >>nohup.out 2>&1 &)
    (make trace -C runspec_gem5_power/519.lbm_r       NUM_INSNS_TO_COLLECT="${bm_insts[519]}" JUMP_NUM="${JUMP_NUM}" CONVERT_NUM_Vgi_RECS="${CONVERT_NUM_Vgi_RECS}" NUM_INST="${NUM_INST}" CPI_INTERVAL="${NUM_INST}" SCROLL_BEGIN="${SCROLL_BEGIN}" SCROLL_END="${SCROLL_END}" >>nohup.out 2>&1 &)
    (make trace -C runspec_gem5_power/520.omnetpp_r   NUM_INSNS_TO_COLLECT="${bm_insts[520]}" JUMP_NUM="${JUMP_NUM}" CONVERT_NUM_Vgi_RECS="${CONVERT_NUM_Vgi_RECS}" NUM_INST="${NUM_INST}" CPI_INTERVAL="${NUM_INST}" SCROLL_BEGIN="${SCROLL_BEGIN}" SCROLL_END="${SCROLL_END}" >>nohup.out 2>&1 &)
    (make trace -C runspec_gem5_power/521.wrf_r       NUM_INSNS_TO_COLLECT="${bm_insts[521]}" JUMP_NUM="${JUMP_NUM}" CONVERT_NUM_Vgi_RECS="${CONVERT_NUM_Vgi_RECS}" NUM_INST="${NUM_INST}" CPI_INTERVAL="${NUM_INST}" SCROLL_BEGIN="${SCROLL_BEGIN}" SCROLL_END="${SCROLL_END}" >>nohup.out 2>&1 &)
    (make trace -C runspec_gem5_power/523.xalancbmk_r NUM_INSNS_TO_COLLECT="${bm_insts[523]}" JUMP_NUM="${JUMP_NUM}" CONVERT_NUM_Vgi_RECS="${CONVERT_NUM_Vgi_RECS}" NUM_INST="${NUM_INST}" CPI_INTERVAL="${NUM_INST}" SCROLL_BEGIN="${SCROLL_BEGIN}" SCROLL_END="${SCROLL_END}" >>nohup.out 2>&1 &)
    (make trace -C runspec_gem5_power/525.x264_r      NUM_INSNS_TO_COLLECT="${bm_insts[525]}" JUMP_NUM="${JUMP_NUM}" CONVERT_NUM_Vgi_RECS="${CONVERT_NUM_Vgi_RECS}" NUM_INST="${NUM_INST}" CPI_INTERVAL="${NUM_INST}" SCROLL_BEGIN="${SCROLL_BEGIN}" SCROLL_END="${SCROLL_END}" >>nohup.out 2>&1 &)
    (make trace -C runspec_gem5_power/526.blender_r   NUM_INSNS_TO_COLLECT="${bm_insts[526]}" JUMP_NUM="${JUMP_NUM}" CONVERT_NUM_Vgi_RECS="${CONVERT_NUM_Vgi_RECS}" NUM_INST="${NUM_INST}" CPI_INTERVAL="${NUM_INST}" SCROLL_BEGIN="${SCROLL_BEGIN}" SCROLL_END="${SCROLL_END}" >>nohup.out 2>&1 &)
    (make trace -C runspec_gem5_power/527.cam4_r      NUM_INSNS_TO_COLLECT="${bm_insts[527]}" JUMP_NUM="${JUMP_NUM}" CONVERT_NUM_Vgi_RECS="${CONVERT_NUM_Vgi_RECS}" NUM_INST="${NUM_INST}" CPI_INTERVAL="${NUM_INST}" SCROLL_BEGIN="${SCROLL_BEGIN}" SCROLL_END="${SCROLL_END}" >>nohup.out 2>&1 &)
    (make trace -C runspec_gem5_power/531.deepsjeng_r NUM_INSNS_TO_COLLECT="${bm_insts[531]}" JUMP_NUM="${JUMP_NUM}" CONVERT_NUM_Vgi_RECS="${CONVERT_NUM_Vgi_RECS}" NUM_INST="${NUM_INST}" CPI_INTERVAL="${NUM_INST}" SCROLL_BEGIN="${SCROLL_BEGIN}" SCROLL_END="${SCROLL_END}" >>nohup.out 2>&1 &)
    (make trace -C runspec_gem5_power/538.imagick_r   NUM_INSNS_TO_COLLECT="${bm_insts[538]}" JUMP_NUM="${JUMP_NUM}" CONVERT_NUM_Vgi_RECS="${CONVERT_NUM_Vgi_RECS}" NUM_INST="${NUM_INST}" CPI_INTERVAL="${NUM_INST}" SCROLL_BEGIN="${SCROLL_BEGIN}" SCROLL_END="${SCROLL_END}" >>nohup.out 2>&1 &)
    (make trace -C runspec_gem5_power/541.leela_r     NUM_INSNS_TO_COLLECT="${bm_insts[541]}" JUMP_NUM="${JUMP_NUM}" CONVERT_NUM_Vgi_RECS="${CONVERT_NUM_Vgi_RECS}" NUM_INST="${NUM_INST}" CPI_INTERVAL="${NUM_INST}" SCROLL_BEGIN="${SCROLL_BEGIN}" SCROLL_END="${SCROLL_END}" >>nohup.out 2>&1 &)
    (make trace -C runspec_gem5_power/544.nab_r       NUM_INSNS_TO_COLLECT="${bm_insts[544]}" JUMP_NUM="${JUMP_NUM}" CONVERT_NUM_Vgi_RECS="${CONVERT_NUM_Vgi_RECS}" NUM_INST="${NUM_INST}" CPI_INTERVAL="${NUM_INST}" SCROLL_BEGIN="${SCROLL_BEGIN}" SCROLL_END="${SCROLL_END}" >>nohup.out 2>&1 &)
    (make trace -C runspec_gem5_power/548.exchange2_r NUM_INSNS_TO_COLLECT="${bm_insts[548]}" JUMP_NUM="${JUMP_NUM}" CONVERT_NUM_Vgi_RECS="${CONVERT_NUM_Vgi_RECS}" NUM_INST="${NUM_INST}" CPI_INTERVAL="${NUM_INST}" SCROLL_BEGIN="${SCROLL_BEGIN}" SCROLL_END="${SCROLL_END}" >>nohup.out 2>&1 &)
    (make trace -C runspec_gem5_power/549.fotonik3d_r NUM_INSNS_TO_COLLECT="${bm_insts[549]}" JUMP_NUM="${JUMP_NUM}" CONVERT_NUM_Vgi_RECS="${CONVERT_NUM_Vgi_RECS}" NUM_INST="${NUM_INST}" CPI_INTERVAL="${NUM_INST}" SCROLL_BEGIN="${SCROLL_BEGIN}" SCROLL_END="${SCROLL_END}" >>nohup.out 2>&1 &)
    (make trace -C runspec_gem5_power/554.roms_r      NUM_INSNS_TO_COLLECT="${bm_insts[554]}" JUMP_NUM="${JUMP_NUM}" CONVERT_NUM_Vgi_RECS="${CONVERT_NUM_Vgi_RECS}" NUM_INST="${NUM_INST}" CPI_INTERVAL="${NUM_INST}" SCROLL_BEGIN="${SCROLL_BEGIN}" SCROLL_END="${SCROLL_END}" >>nohup.out 2>&1 &)
    (make trace -C runspec_gem5_power/557.xz_r        NUM_INSNS_TO_COLLECT="${bm_insts[557]}" JUMP_NUM="${JUMP_NUM}" CONVERT_NUM_Vgi_RECS="${CONVERT_NUM_Vgi_RECS}" NUM_INST="${NUM_INST}" CPI_INTERVAL="${NUM_INST}" SCROLL_BEGIN="${SCROLL_BEGIN}" SCROLL_END="${SCROLL_END}" >>nohup.out 2>&1 &)
    (make trace -C runspec_gem5_power/999.specrand_ir NUM_INSNS_TO_COLLECT="${bm_insts[999]}" JUMP_NUM="${JUMP_NUM}" CONVERT_NUM_Vgi_RECS="${CONVERT_NUM_Vgi_RECS}" NUM_INST="${NUM_INST}" CPI_INTERVAL="${NUM_INST}" SCROLL_BEGIN="${SCROLL_BEGIN}" SCROLL_END="${SCROLL_END}" >>nohup.out 2>&1 &)
  elif [[ $with_entire_all_benchmarks == true ]]; then
    nohup make trace -C runspec_gem5_power/502.gcc_r       NUM_INSNS_TO_COLLECT="${bm_insts[502]}" JUMP_NUM=0 NUM_INST="${bm_insts[502]}" CPI_INTERVAL="${bm_insts[502]}" RESET_STATS=1 >>nohup.out 2>&1 &
    nohup make trace -C runspec_gem5_power/999.specrand_ir NUM_INSNS_TO_COLLECT="${bm_insts[999]}" JUMP_NUM=0 NUM_INST="${bm_insts[999]}" CPI_INTERVAL="${bm_insts[999]}" RESET_STATS=1 >>nohup.out 2>&1 &
    nohup make trace -C runspec_gem5_power/538.imagick_r   NUM_INSNS_TO_COLLECT="${bm_insts[538]}" JUMP_NUM=0 NUM_INST="${bm_insts[538]}" CPI_INTERVAL="${bm_insts[538]}" RESET_STATS=1 >>nohup.out 2>&1 &
    nohup make trace -C runspec_gem5_power/523.xalancbmk_r NUM_INSNS_TO_COLLECT="${bm_insts[523]}" JUMP_NUM=0 NUM_INST="${bm_insts[523]}" CPI_INTERVAL="${bm_insts[523]}" RESET_STATS=1 >>nohup.out 2>&1 &
    nohup make trace -C runspec_gem5_power/557.xz_r        NUM_INSNS_TO_COLLECT="${bm_insts[557]}" JUMP_NUM=0 NUM_INST="${bm_insts[557]}" CPI_INTERVAL="${bm_insts[557]}" RESET_STATS=1 >>nohup.out 2>&1 &
    (./partition_run_spec2017_m1.sh "${WORK_DIR}" "${bm[526]}" "${bm_insts[526]}" 2 >>nohup.out 2>&1 &)
    (./partition_run_spec2017_m1.sh "${WORK_DIR}" "${bm[525]}" "${bm_insts[525]}" 4 >>nohup.out 2>&1 &)
    (./partition_run_spec2017_m1.sh "${WORK_DIR}" "${bm[511]}" "${bm_insts[511]}" 4 >>nohup.out 2>&1 &)
    (./partition_run_spec2017_m1.sh "${WORK_DIR}" "${bm[500]}" "${bm_insts[500]}" 5 >>nohup.out 2>&1 &)
    (./partition_run_spec2017_m1.sh "${WORK_DIR}" "${bm[519]}" "${bm_insts[519]}" 10 >>nohup.out 2>&1 &)
    (./partition_run_spec2017_m1.sh "${WORK_DIR}" "${bm[544]}" "${bm_insts[544]}" 10 >>nohup.out 2>&1 &)
    (./partition_run_spec2017_m1.sh "${WORK_DIR}" "${bm[503]}" "${bm_insts[503]}" 20 >>nohup.out 2>&1 &)
    (./partition_run_spec2017_m1.sh "${WORK_DIR}" "${bm[520]}" "${bm_insts[520]}" 21 >>nohup.out 2>&1 &)
    (./partition_run_spec2017_m1.sh "${WORK_DIR}" "${bm[554]}" "${bm_insts[554]}" 25 >>nohup.out 2>&1 &)
    (./partition_run_spec2017_m1.sh "${WORK_DIR}" "${bm[507]}" "${bm_insts[507]}" 27 >>nohup.out 2>&1 &)
    (./partition_run_spec2017_m1.sh "${WORK_DIR}" "${bm[541]}" "${bm_insts[541]}" 41 >>nohup.out 2>&1 &)
    (./partition_run_spec2017_m1.sh "${WORK_DIR}" "${bm[505]}" "${bm_insts[505]}" 45 >>nohup.out 2>&1 &)
    (./partition_run_spec2017_m1.sh "${WORK_DIR}" "${bm[510]}" "${bm_insts[510]}" 46 >>nohup.out 2>&1 &)
    (./partition_run_spec2017_m1.sh "${WORK_DIR}" "${bm[531]}" "${bm_insts[531]}" 64 >>nohup.out 2>&1 &)
    (./partition_run_spec2017_m1.sh "${WORK_DIR}" "${bm[521]}" "${bm_insts[521]}" 65 >>nohup.out 2>&1 &)
    (./partition_run_spec2017_m1.sh "${WORK_DIR}" "${bm[549]}" "${bm_insts[549]}" 68 >>nohup.out 2>&1 &)
    (./partition_run_spec2017_m1.sh "${WORK_DIR}" "${bm[508]}" "${bm_insts[508]}" 102 >>nohup.out 2>&1 &)
    (./partition_run_spec2017_m1.sh "${WORK_DIR}" "${bm[548]}" "${bm_insts[548]}" 143 >>nohup.out 2>&1 &)
    (./partition_run_spec2017_m1.sh "${WORK_DIR}" "${bm[527]}" "${bm_insts[527]}" 184 >>nohup.out 2>&1 &)
  else
    target=""
    args=""
    while [[ -n "${1#*=}" ]]
    do
      case "${1#*=}" in
        -a|--all|--all_steps)
          with_all_steps=true
          target=trace
          ;;
        -i|--itrace)
          with_itrace=true
          target=itrace
          ;;
        -q|--qtrace)
          with_qtrace=true
          target=qtrace
          ;;
        -r|--run_timer)
          with_run_timer=true
          target=m1
          ;;
        -p|--pipe_view)
          with_pipe_view=true
          target=m1_pipeview
          ;;
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
          shift
          ;;
        -e|--r_pipe_end|--SCROLL_END)
          with_r_pipe_end=true
          SCROLL_END="${2#*=}"
          args+="SCROLL_END="${2#*=}" "
          shift
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
    #完整参数模式
    if [[ $with_all_steps == true ]] ; then
      if [[ ${CPI_INTERVAL} == -1 ]];then
        CPI_INTERVAL=${NUM_INST}
      fi
      make trace -C runspec_gem5_power/"${bm[${spec2017_bm}]}" NUM_INSNS_TO_COLLECT=${NUM_INSNS_TO_COLLECT} JUMP_NUM=${JUMP_NUM} CONVERT_NUM_Vgi_RECS=${CONVERT_NUM_Vgi_RECS} NUM_INST=${NUM_INST} CPI_INTERVAL=${CPI_INTERVAL} RESET_STATS=${RESET_STATS} SCROLL_PIPE=${SCROLL_PIPE} SCROLL_BEGIN=${SCROLL_BEGIN} SCROLL_END=${SCROLL_END}
      make m1_pipeview -C runspec_gem5_power/"${bm[${spec2017_bm}]}" ${args}
    elif [[ $with_itrace == true || $with_qtrace == true || $with_run_timer == true || $with_pipe_view == true  ]]; then
      make ${target} -C runspec_gem5_power/"${bm[${spec2017_bm}]}" ${args}
    #缺省参数模式1
    elif [[ $with_r_pipe_begin == true && $with_r_pipe_end == true ]]; then
      #args=("${args}")
      #pipe_b="${args[0]##*=}"
      #pipe_e="${args[1]##*=}"
      pipe_b=$(echo "${args[@]}" | grep -oP "SCROLL_BEGIN=\d+" | grep -oP "\d+")
      (( pipe_b=pipe_b-1 ))
      pipe_e=$(echo "${args[@]}" | grep -oP "SCROLL_END=\d+" | grep -oP "\d+")
      (( insts = pipe_e - pipe_b ))
      make trace -C runspec_gem5_power/"${bm[${spec2017_bm}]}" NUM_INSNS_TO_COLLECT=${bm_insts[${spec2017_bm}]} JUMP_NUM=${pipe_b} CONVERT_NUM_Vgi_RECS=${insts} NUM_INST=${insts} CPI_INTERVAL=${insts} RESET_STATS=1 SCROLL_PIPE=1 SCROLL_BEGIN=1 SCROLL_END=${insts}
      make m1_pipeview -C runspec_gem5_power/"${bm[${spec2017_bm}]}"
    fi
  fi
else
  exit 1
fi
