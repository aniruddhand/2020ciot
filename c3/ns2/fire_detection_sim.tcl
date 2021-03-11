# Turn on multicasting to depict data transfer from central
# coordinator to sensors at each home
set ns [new Simulator -multicast on]
set nf [open fire_detection_out.nam w]

$ns namtrace-all $nf

# Creates and configures toplogy for the entire society
#
# Agents:
# -------
# 1. Null agent for receving data from all local coordinators
# 2. UDP agent with multicasting for sending alarm data to all sensor nodes
#
# Traffic Generators
# ------------------
# 1. CBR for sending alarm data
#
# At Events:
# -----------
# 1. Start sending alarm data at 10.0
# 2. Stop sending alarm data at 10.01
proc create_society_topology {} {
  global ns alarm_receivers num_of_homes cc_fid
  
  set cc_node [$ns node]

  # Data from all local coordinators reach here
  set cc_sink [new Agent/Null]
  $ns attach-agent $cc_node $cc_sink

  set cc_alarm_udp [new Agent/UDP]
  $cc_alarm_udp set dst_addr_ $alarm_receivers
  $cc_alarm_udp set dst_port_ 0
  $cc_alarm_udp set fid_ $cc_fid

  $ns attach-agent $cc_node $cc_alarm_udp

  set alarm_data [new Application/Traffic/CBR]
  $alarm_data attach-agent $cc_alarm_udp

  $ns at 10.0 "$alarm_data start"
  $ns at 10.01 "$alarm_data stop"

  # Create home topology for each home in the society
  for {set i 0} {$i < $num_of_homes} {incr i} {
    create_home_topology $cc_node $cc_sink
  }
}

# Creates and configures local coordinator for a home.
#
# This procedure creates local coordinator and configures it
# by attaching agents and traffic generator. It then finally
# creates 4 other sensors and configures them by invoking
# create_home_topology procedure.
#
# Agents:
# -------
# 1. Null agent for receving data from sensor nodes
# 2. UDP agent for sending data to central coordinator
#
# Traffic Generators
# ------------------
# 1. CBR for sending data to central coordinator
#
# At Events:
# -----------
# 1. Start sending data to the central coordinator at 5.0 mins
# 2. Stop sending data to the central coordinator at 5.01 mins
proc create_home_topology {cc_node cc_sink} {
  global ns alarm_receivers num_of_rooms lc_fid
  
  set lc_node [$ns node]
  
  $ns duplex-link $lc_node $cc_node 1Mb 10ms DropTail

  set sink [new Agent/Null]
  $ns attach-agent $lc_node $sink
    
  set udp [new Agent/UDP]
  $udp set fid_ $lc_fid
  
  $ns attach-agent $lc_node $udp
  $ns connect $udp $cc_sink 

  set sync_data [new Application/Traffic/CBR]
  $sync_data attach-agent $udp

  $ns at 5.0  "$sync_data start"
  $ns at 5.01 "$sync_data stop"
  
  # Create and configure sensors in remaining rooms
  for {set i 0} {$i < [expr {$num_of_rooms-1}]} {incr i} {
    create_room_topology $lc_node $sink $i
  }
}

# Creates and configures a sensor node in a room.
#
# This procedure creates a sensor node and configures it by
# attaching it to the multi case address so that it receives
# the data sent by central coordinator in case of any alarm.
#
# Agents:
# -------
# 1. Null agent for receving data from central coordinator
# 2. UDP agent for sending data to the local coordinator
#
# Traffic Generators
# ------------------
# 1. CBR for sending data to local coordinator
#
# At Events:
# -----------
# 1. Start sending data to the local coordinator at the begining
# 2. Stop sending data to the local coordinator at 10.0 mins
proc create_room_topology {lc_node lc_sink index} {
  global ns alarm_receivers sensor_fid
  
  set node [$ns node]
  
  $ns duplex-link $node $lc_node 256Kb 10ms DropTail
  
  set alarm_sink [new Agent/Null]
  $ns attach-agent $node $alarm_sink
  $node join-group $alarm_sink $alarm_receivers

  set udp [new Agent/UDP]
  $udp set fid_ $sensor_fid
  
  $ns attach-agent $node $udp
  $ns connect $udp $lc_sink
  
  set sensor_data [new Application/Traffic/CBR]
  $sensor_data set packetSize_ 500
  $sensor_data set interval_ 0.30
  $sensor_data attach-agent $udp
  
  set gap_btw_sensors [expr {0.1 +[expr {double($index)/10}]}]
  
  $ns at $gap_btw_sensors "$sensor_data start"
  $ns at 10.0 "$sensor_data stop"
  $ns at 10.01 "$node leave-group $alarm_sink $alarm_receivers"
}

# Simlulation wide configurations
proc configure_simulation {} {
  global ns nf sensor_fid lc_fid cc_fid
  
  $ns namtrace-all $nf
  
  # Make nodes ready for multicast protocol
  set mproto DM
  set mrthandle [$ns mrtproto $mproto {}]

  $ns color $sensor_fid green
  $ns color $lc_fid blue
  $ns color $cc_fid red

  $ns set-animation-rate 5ms
  $ns at 10.2 "finish"
}

proc finish {} {
  global ns nf
  
  $ns flush-trace
  
  close $nf
  exec nam fire_detection_out.nam &
  exit 0
}

# Flow identifiers for coloring packets sent and received
# in different flows
set sensor_fid 0
set lc_fid 1
set cc_fid 2

set num_of_homes 15
set num_of_rooms 5

# Multicast address to which all sensor nodes are added
set alarm_receivers [Node allocaddr]

create_society_topology

# Must be called ** after ** creating nodes
configure_simulation

$ns run
