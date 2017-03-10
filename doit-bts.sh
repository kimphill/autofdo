#!/bin/bash -x
#building create_gcov from akleen's github branch:
#./configure
#make
# to avoid this:
# $ ./create_gcov --binary=./sort_O3 --profile=profile.inj --gcov=sort_O3.gcov -gcov_version=1
# F0120 15:44:03.920500 17343 perf_reader.cc:1621] Check failed: attr_size <= sizeof(perf_event_attr) (112 vs. 104) 
# cp $HOME/git/linux-perf-acme/include/uapi/linux/perf_event.h chromiumos-wide-profiling/kernel/perf_event.h
# yeah that didnt work:
# F0120 16:02:39.209450 19054 perf_reader.cc:224] Check failed: sizeof(attr) == (reinterpret_cast<u64>(&attr.__reserved_2) - reinterpret_cast<u64>(&attr)) + 4 + sizeof(attr.sample_regs_intr) (112 vs. 122) 
#commit ba11ba65e02836c475427ae199adfc2d8cc4a900
#Author: Adrian Hunter <adrian.hunter@intel.com>
#Date:   Fri Sep 25 16:15:56 2015 +0300
#    perf intel-pt: Add mispred-all config option to aid use with autofdo
# $ git describe ba11ba65e02836c475427ae199adfc2d8cc4a900
# v4.3-rc3-179-gba11ba6

export PERF=$HOME/git/linux-perf-tip-mingo/tools/perf/perf
export TARGET=./sort
#export TARGET=$HOME/git/RichardBarrell-snippets/rev26
gcc -g -O3 ${TARGET}.c -o ${TARGET}_O3 -lpthread -Wall -DUSE_A_SPIN_BARRIER
time ${TARGET}_O3 
echo "[intel-bts]" > ~/.perfconfig  # macht nichts fuer bts!
echo "	mispred-all = true" >> ~/.perfconfig
sudo chown root ~/.perfconfig
sudo chmod go+rw perf.data
sudo $PERF record -o perf.data -e intel_bts//u --per-thread ${TARGET}_O3
sudo chown kim perf.data
sudo chmod go+rw perf.data
$PERF inject -i perf.data -o profile.inj --itrace=i100usle --strip
./create_gcov --binary=${TARGET}_O3 --profile=profile.inj --gcov=${TARGET}_O3.gcov -gcov_version=1
gcc -O3 -fauto-profile=${TARGET}_O3.gcov ${TARGET}.c -o ${TARGET}_autofdo -lpthread -Wall -DUSE_A_SPIN_BARRIER
time ${TARGET}_autofdo
rm -f ~/.perfconfig
exit

kim@dupont autofdo-andikleen perf4-3+kp2$ gcc -O3 -fauto-profile=sort_O3.gcov sort.c -o sort_autofdo
$ ./sort_autofdo
Bubble sorting array of 30000 elements
1383 ms
$ ./sort_autofdo
Bubble sorting array of 30000 elements
1399 ms
$ ./sort_O3
Bubble sorting array of 30000 elements
1463 ms
$ ./sort_O3
Bubble sorting array of 30000 elements
1478 ms
$ ./sort_autofdo
Bubble sorting array of 30000 elements
1367 ms
$ ./sort_autofdo
Bubble sorting array of 30000 elements
1390 ms

