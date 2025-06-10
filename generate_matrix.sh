#!/bin/bash

mkdir -p output
mkdir -p log

echo "Variable definition";

restart=0

dim=(1000 2000 3000 4000 5000 6000 7000 8000 9000 10000 15000 20000 25000 30000 35000 40000 45000 50000 60000 70000 80000 90000 100000 150000 200000 250000 500000 750000 1000000)
type=(non-herm non-symm)
nb_diag=(10 20 30 40 50 100 200 300 400 500)

nb_it=$((${#dim[@]} * ${#type[@]} * ${#nb_diag[@]}))
cit=0

for d in $(seq 0 $((${#dim[@]} - 1)))
do
    #echo $b
    #echo ${batchsize[${b}]}
    echo "${cit} on ${nb_it} : "

    for nb in $(seq 0 $((${#nb_diag[@]} - 1)))
    do
        cit=$(($cit + 1))

        { srun -p cpu_short --ntasks=100 ./generate_matrix.exe -D ${dim[${d}]} -M non-symm -L ${nb_diag[${nb}]} -P output/${dim[${d}]}_${nb_diag[${nb}]}_nnsymm.mtx  ; } > log/${dim[${d}]}_${nb_diag[${nb}]}_nnsymm.mtx &
        { srun -p cpu_short --ntasks=100 ./generate_matrix.exe -D ${dim[${d}]} -M non-herm -L ${nb_diag[${nb}]} -P output/${dim[${d}]}_${nb_diag[${nb}]}_nnsherm.mtx ; } > log/${dim[${d}]}_${nb_diag[${nb}]}_nnherm.mtx &
    done
    wait
done

wait

wait