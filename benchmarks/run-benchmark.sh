#!/bin/bash

# Compile and run regregator benchmark

# Fail on error
set -e

source ../../env.sh
source ../../config.common

BENCHMARKS=($(ls -d beebs/src/*/ | xargs -n 1 basename))

EXCLUDE_BENCHMARKS=(ctl matmult sglib-arraysort trio)

# memmove in RTOS TODO?
#EXCLUDE_BENCHMARKS+=(ctl-string ctl-vector cubic dtoa fdct matmult-float frac miniz nbody nettle-aes nettle-sha256 qrduino slre st stb_perlin stringsearch1 trio-snprintf trio-sscanf whetstone wikisort)

# I dont know why it fails in RTOS TODO
#EXCLUDE_BENCHMARKS+=(cnt crc32 duff fasta huffbench insertsort lcdnum levenshtein ludcmp mergesort minver ndes nettle-arcfour nettle-cast128 nettle-md5 newlib-exp newlib-log newlib-mod newlib-sqrt picojpeg qsort qurt recursion rijndael select sglib-arraysort sglib-listsort sglib-queue sglib-rbtree statemate strstr tarai) 

for i in "${EXCLUDE_BENCHMARKS[@]}"; do
    DISABLE_BENCHMARKS="$DISABLE_BENCHMARKS --disable-benchmark-$i"
done

if [[ $RISCV_KERNEL = "freertos" ]]; then
    echo "Using FreeRTOS"
    CHIP=freertos
    BOARD=freertos
    SPIKE="spike -l"
else
    echo "Using Proxy Kernel"
    CHIP=generic
    BOARD=none
    SPIKE="spike -l $PK"
fi

rm -rf results/*.elf
rm -rf results/*.out
rm -rf results/*.log

# compile beebs
cd beebs

#baseline
./configure --host=riscv${RISCV_XLEN}-unknown-elf --with-chip=$CHIP --with-board=$BOARD $DISABLE_BENCHMARKS
make clean
make
for i in "${BENCHMARKS[@]}"; do
    if [[ ${EXCLUDE_BENCHMARKS[*]} =~ $i ]]; then
        continue
    fi

    cp src/$i/$i ../results/$i.elf 
    echo -n "Executing $i.."
    ${SPIKE} ../results/$i.elf 1> ../results/$i.out 2> ../results/$i.log || true
    ../parse-log ../results/$i.log > ../results/$i.hist
    echo "done"
done

#segregator TODO

#segregator + security TODO

cd - > /dev/null
echo "DONE"
