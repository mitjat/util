#!/bin/sh

HERE="$(cd "$(dirname "$0")"; pwd)"

source "$HERE/tunnels_base.sh"

echo "Kill SSH tunnel"
kill_tunnel pink_unsafe_core $UNSAFE_CORE_HOST $UNSAFE_CORE_PORT $UNSAFE_CORE_PORT $BASTION
kill_zk_tunnel adama $MANHATTAN_ADAMA_ZK $MANHATTAN_ADAMA_PORT $BASTION
kill_zk_tunnel omega $MANHATTAN_OMEGA_ZK $MANHATTAN_OMEGA_PORT $BASTION
kill_zk_tunnel starbuck $MANHATTAN_STARBUCK_ZK $MANHATTAN_STARBUCK_PORT $BASTION
kill_zk_tunnel jubjub $JUBJUB_ZK $JUBJUB_PORT $BASTION
kill_zk_tunnel roastduck $ROASTDUCK_ZK $ROASTDUCK_PORT $BASTION
kill_zk_tunnel blender $BLENDER_ZK $BLENDER_PORT $BASTION
kill_zk_tunnel tflock $TFLOCK_ZK $TFLOCK_PORT $BASTION
kill_zk_tunnel flock $FLOCK_ZK $FLOCK_PORT $BASTION
kill_zk_tunnel gizmoduck $GIZMODUCK_ZK $GIZMODUCK_PORT $BASTION
kill_zk_tunnel tweetypie $TWEETYPIE_ZK $TWEETYPIE_PORT $BASTION
kill_zk_tunnel pink_safe_core $PINK_SAFE_CORE_ZK $PINK_SAFE_CORE_PORT $BASTION
kill_zk_tunnel pink_store $PINK_STORE_ZK $PINK_STORE_PORT $BASTION
kill_zk_tunnel timeline_service $TIMELINE_SERVICE_ZK $TIMELINE_SERVICE_PORT $BASTION
