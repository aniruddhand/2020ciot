#! /bin/bash

for proto in "AODV" "DSDV" "DSR"
do
  printf "\nRunning simulations for $proto..."
   
  for siml in 1 2 3 4 5
  do
    qType="Queue\/DropTail\/PriQueue"
    
    if [ $proto == "DSR" ]; then qType="CMUPriQueue"; fi
    
    printf "\n  simulation $siml"
    printf "\n  ------------"
    for rate in "2.0" "4.0" "8.0"
    do
      printf "\n    with rate->$rate, pause->"
      for pause in "0" "25" "50"
      do
        printf "$pause/"

        cp -f wireless-swarm-monitor.template sim-${siml}/wireless-swarm-monitor.tcl

        sed -i "s/__QTYPE__/${qType}/g" sim-${siml}/wireless-swarm-monitor.tcl
        sed -i "s/__COUNT__/${siml}/g" sim-${siml}/wireless-swarm-monitor.tcl
        sed -i "s/__PROTO__/${proto}/g" sim-${siml}/wireless-swarm-monitor.tcl
        sed -i "s/__RATE__/${rate}/g" sim-${siml}/wireless-swarm-monitor.tcl
        sed -i "s/__PAUSE__/${pause}/g" sim-${siml}/wireless-swarm-monitor.tcl
        
        timeout 15 ns sim-${siml}/wireless-swarm-monitor.tcl >/dev/null 2>&1
        
        #rm sim-${siml}/wireless-swarm-monitor.tcl
      done
    done
    printf "\n"
  done
done

printf "\nDone!\n\n"
