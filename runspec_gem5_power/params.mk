# SPEC2017
SPEC_HOME      ?= /home/${USER}/cpu2017
LABEL          ?= ppc

# gem5
GEM5_REPO_PATH ?= /home/${USER}/prj/gem5
GEM5            = $(GEM5_REPO_PATH)/build/POWER_MI/gem5.opt
BUILD_GEM5_J    = 16
GEM5_OPT        =
GEM5_PY         = $(GEM5_REPO_PATH)/configs/example/se.py
GEM5_PY_OPT    += --cpu-type=4.0GHz
GEM5_PY_OPT    += --cpu-clock=P8CPU
GEM5_PY_OPT    += --ruby-clock=4.0GHz --ruby --caches --l1d_size=64kB --l1d_assoc=8 --l1i_size=32kB --l1i_assoc=8 --l2cache --l2_size=512kB --l2_assoc=8 --l3_size=8MB --l3_assoc=8 --cacheline_size=128
GEM5_PY_OPT    += --mem-size=16384MB --mem-type=DDR4_2933_16x4 --enable-mem-param-override=True --dram-addr-mapping=RoCoRaBaCh --dram-max-accesses-per-row=16 --dram-page-policy close_adaptive --dram-read-buffer-size=64 --dram-write-buffer-size=128 --mc-be-latency=10ns --mc-fe-latency=35ns --mc-mem-sched-policy=frfcfs

# Simpoint
SIMPOINT_EXE    = /home/${USER}/SimPoint.3.2/bin/simpoint
INTERVAL_SIZE   = 5000000
MAXK            = 35
WARMUP_LENGTH   = 1000000
NUM_CKP         = 1

# Valgrind
VALGRIND_EXE    = /home/${USER}/valgrind-install/bin/valgrind

# others
TIME = /usr/bin/time --format="Consumed Time: %E  --  $$(basename $${PWD})"

FLOODGATE=../../running/run.fifo
BACKUP_PATH=
WORK_DIR=

TIMEH           = /usr/bin/time --format="Host Consumed Time: %E  --  $$(basename $${PWD})"
TIMEG           = /usr/bin/time --format="GEM5 Consumed Time: %E  --  $$(basename $${PWD})"

SHELL          := /bin/bash

