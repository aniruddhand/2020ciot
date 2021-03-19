#! /bin/bash

for siml in 1 2 3 4 5
do
  printf "\nGenerating traffic and node movements data for simulation: $siml..."
  
  printf "\n  generating node movements data with pause time:"
  for pause in 50 25 0
  do
    printf " ${pause}"
    setdest -v 2 -n 25 -m 2.7 -M 2.7 -t 100 -P 1 -p ${pause} -x 800 -y 800 > sim-${siml}/scene/scen-800x800-${pause}-2
  done
  
  printf "\n  generating CBR traffic data with data rate:"
  for rate in "2.0" "4.0" "8.0"
  do
    printf " ${rate}"
    # Number of nodes is deliberately set to 24, as node indexes are getting generated from 1?
    ns ../../../../ns-allinone-2.35/ns-2.35/indep-utils/cmu-scen-gen/cbrgen.tcl -type cbr -nn 24 -mc 15 -seed ${siml}.0 -rate ${rate} > sim-${siml}/scene/cbr-25-15-${rate}-512
  done
done

printf "\nDone!\n"
