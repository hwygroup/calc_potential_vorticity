#!/bin/bash
for ((j=1948;j<2016;j++));do 
ref_s=$j
ref_e=$(($j+4))
j=$ref_e
echo $ref_s "_" $ref_e
    for ((i=$ref_s;i<=$ref_e;i++));do
        {
            ncl year=$i cal_pv_year.ncl > log.$i
        }&
    done
wait
done
