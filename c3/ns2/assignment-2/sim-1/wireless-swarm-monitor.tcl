set nn 25

set val(chan)         Channel/WirelessChannel  ;# channel type
set val(prop)         Propagation/TwoRayGround ;# radio-propagation model
set val(ant)          Antenna/OmniAntenna      ;# Antenna type
set val(x)            800                      ;# X dimension of the topography
set val(y)            800                      ;# Y dimension of the topography
set val(seed)         1.0
set val(ll)           LL                       ;# Link layer type
set val(ifq)          Queue/DropTail/PriQueue  ;# Interface queue type
set val(ifqlen)       50                       ;# max packet in ifq
set val(netif)        Phy/WirelessPhy          ;# network interface type
set val(mac)          Mac/802_11               ;# MAC type
set val(adhocRouting) AODV                      ;# ad-hoc routing protocol 
set val(nn)           $nn                      ;# number of mobilenodes
set val(cp)           "./sim-1/scene/cbr-25-15-8-512" 
set val(sc)           "./sim-1/scene/scen-800x800-50-2"
set val(stop)         500.0                   ;# simulation time

set ns_ [new Simulator]

set out_file_pattern "sim-1/out/AODV-1-8-50-out"

set tracefd [open $out_file_pattern.tr w]
$ns_ trace-all $tracefd

set namtrace [open $out_file_pattern.nam w];# for nam tracing
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)

set topo [new Topography]

$topo load_flatgrid 800 800

set god_ [create-god $val(nn)]

$ns_ node-config -adhocRouting $val(adhocRouting) \
                 -llType $val(ll) \
                 -macType $val(mac) \
                 -ifqType $val(ifq) \
                 -ifqLen $val(ifqlen) \
                 -antType $val(ant) \
                 -propType $val(prop) \
                 -phyType $val(netif) \
                 -topoInstance $topo \
                 -channel [new $val(chan)] \
                 -agentTrace ON \
                 -routerTrace ON \
                 -macTrace OFF \
                 -movementTrace OFF
                 
for {set i 0} {$i < $val(nn) } {incr i} {
  set node_($i) [$ns_ node]
}

puts "Loading scenario file..."
source $val(sc)

puts "Loading connection pattern..."
source $val(cp)

for {set i 0} {$i < $val(nn)} {incr i} {
  $ns_ initial_node_pos $node_($i) 30
}

for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at $val(stop) "$node_($i) reset";
}

$ns_ at $val(stop).0001 "stop"
$ns_ at $val(stop).0002 "puts \"NS EXITING...\" ; $ns_ halt"

proc stop {} {
  global ns tracefd
  close $tracefd
}

puts "Starting Simulation..."

$ns_ run
