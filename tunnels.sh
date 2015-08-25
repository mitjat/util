#!/bin/sh

HERE="$(cd "$(dirname "$0")"; pwd)"

source "$HERE/tunnels_base.sh"

echo "Set up SSH tunnels"
tunnel pink_unsafe_core $UNSAFE_CORE_HOST $UNSAFE_CORE_PORT $UNSAFE_CORE_PORT $BASTION
zk_tunnel roastduck $ROASTDUCK_ZK $ROASTDUCK_PORT $BASTION
#zk_tunnel adama $MANHATTAN_ADAMA_ZK $MANHATTAN_ADAMA_PORT $BASTION
#zk_tunnel omega $MANHATTAN_OMEGA_ZK $MANHATTAN_OMEGA_PORT $BASTION
#zk_tunnel starbuck $MANHATTAN_STARBUCK_ZK $MANHATTAN_STARBUCK_PORT $BASTION
zk_tunnel jubjub $JUBJUB_ZK $JUBJUB_PORT $BASTION
zk_tunnel blender $BLENDER_ZK $BLENDER_PORT $BASTION
zk_tunnel tflock $TFLOCK_ZK $TFLOCK_PORT $BASTION
zk_tunnel flock $FLOCK_ZK $FLOCK_PORT $BASTION
#zk_tunnel gizmoduck $GIZMODUCK_ZK $GIZMODUCK_PORT $BASTION
#zk_tunnel tweetypie $TWEETYPIE_ZK $TWEETYPIE_PORT $BASTION
zk_tunnel pink_safe_core $PINK_SAFE_CORE_ZK $PINK_SAFE_CORE_PORT $BASTION
zk_tunnel pink_store $PINK_STORE_ZK $PINK_STORE_PORT $BASTION
#zk_tunnel timeline_service $TIMELINE_SERVICE_ZK $TIMELINE_SERVICE_PORT $BASTION

#zk_tunnel manhattan.adama t.sd.manhattan.prod.adama.native-thrift.alive.main 5996
#zk_tunnel manhattan.omega t.sd.manhattan.prod.omega.native-thrift.alive.main 5995
#zk_tunnel blender t.sd.search-blender.prod.blender.alive.main 8686
