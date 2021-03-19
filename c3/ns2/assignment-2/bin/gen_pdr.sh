#! /bin/bash

for proto in "AODV" "DSDV" "DSR"
do
  printf "Computing PDR for $proto"
  
  pdr_out=$'Itr,Rate,P0,P25,P50\r\n'
  pdr_proto_avg=0
  
  for siml in 1 2 3 4 5
  do
    printf "\n  using data from simulation $siml"
    
    for rate in "2.0" "4.0" "8.0"
    do
      printf "."
      pdr_out="${pdr_out}${siml},${rate}"
      
      for pause in "0" "25" "50"
      do
        perl ./bin/column.pl 0 3 18 < ./sim-${siml}/out/${proto}-${siml}-${rate}-${pause}-out.tr > ./temp.out
        
        pdr=$(perl ./bin/del_ratio.pl < ./temp.out)
        pdr_proto_avg=$(bc <<<"$pdr_proto_avg + $pdr")
        pdr_out="$pdr_out,$pdr"
      done
      
      pdr_out=${pdr_out}$'\r\n'
    done
  done

  pdr_out="${pdr_out}xx,Average,"$(bc -l <<<"$pdr_proto_avg/45")",,"
  
  echo $pdr_out > ./${proto}-pdr-data.csv
  printf "\n"
done

printf "\nDone!\n\n"
rm ./temp.out
