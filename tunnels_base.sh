#!/bin/sh
###########################
# Kill based on a pattern #
###########################
gkill() {
  pattern=$1
  ps auxwww | grep $pattern | grep -v grep
  echo
  read -p "Do you want to kill all those processes? Ctrl-C to abort. " yn

  echo
  echo Killing:
  ps auxwww | grep $pattern | grep -v grep | sed "s/^[^ ]* *//" | cut -f1 -d" "
  ps auxwww | grep $pattern | grep -v grep | sed "s/^[^ ]* *//" | cut -f1 -d" " | xargs -n1 kill
}

######################################
# Tunnel to a specific host and port #
######################################
function tunnel {
  label=$1
  target=$2
  port=$3
  localPort=$4
  bastion=$5

  if [ -z "`nc -z localhost $localPort`" ]; then
    echo "Connecting to remote $label via $bastion" 1>&2
    ssh -N -f -L$localPort:$target:$port -l $USER $bastion
  else
    echo "Detected $label tunnel on port $port"
  fi
}

function kill_tunnel {
  label=$1
  target=$2
  port=$3
  localPort=$4
  bastion=$5

  if [ -z "`nc -z localhost $localPort`" ]; then
    echo "Haven't detected active tunnel for $label"
  else
    echo "Detected $label tunnel on port $port"
    gkill $localPort:$target:$port
  fi
}

#####################################
# Tunnel to a host from a serverset #
#####################################
function zk_tunnel {
  label=$1
  zkPath=$2
  localPort=$3
  bastion=$4

  if [ -z "`nc -z localhost $localPort`" ]; then
    echo "Looking up host and port for $zkPath via $bastion" 1>&2
    hostAndPort=`ssh $bastion "colony --zone smf1 mo t.sd.$zkPath.alive.main | head -6 | tail -1" 2>/dev/null`
    echo "Tunnel to $hostAndPort on local port $localPort" 1>&2
    ssh -N -f -L$localPort:$hostAndPort -l $USER $bastion
    echo "Done" 1>&2
  else
    echo "Detected $label tunnel on local port $localPort" 1>&2
  fi
}

function kill_zk_tunnel {
  label=$1
  zkPath=$2
  localPort=$3
  bastion=$4

  if [ -z "`nc -z localhost $localPort`" ]; then
    echo "Haven't detected $label tunnel on local port $localPort" 1>&2
  else
    echo "Detected $label tunnel on local port $localPort" 1>&2
    hostAndPort=`ssh $bastion "colony --zone smf1 mo t.sd.$zkPath.alive.main | head -3 | tail -1" 2>/dev/null`
    gkill $localPort:$hostAndPort
  fi
}

###############
# Known hosts #
###############
BASTION=nest1.twitter.biz

FETCHER_HOST='smf1-cfz-37-sr4.prod.twitter.com'
FETCHER_PORT=10001

FETCHER_MEMCACHE_HOST='smf1-cfz-37-sr4.prod.twitter.com'
FETCHER_MEMCACHE_PORT=11212

UNSAFE_CORE_HOST='smf1-cfz-37-sr4.prod.twitter.com'
UNSAFE_CORE_PORT=10010

#####################################
# Serverset Path for known services #
#####################################
MANHATTAN_ADAMA_ZK='manhattan.prod.adama.native-thrift'
MANHATTAN_ADAMA_PORT=9990

MANHATTAN_OMEGA_ZK='manhattan.prod.omega.native-thrift'
MANHATTAN_OMEGA_PORT=9991

MANHATTAN_REDWING_ZK='manhattan.prod.redwing.native-thrift'
MANHATTAN_REDWING_PORT=9992

MANHATTAN_STARBUCK_ZK='manhattan.prod.starbuck.native-thrift'
MANHATTAN_STARBUCK_PORT=9993

MEMCACHE_PINKFLOYD_ZK='cache.prod.pinkfloyd'
MEMCACHE_PINKFLOYD_PORT=23430

MEMCACHE_SPIDERDUCK_XX_TEST_ZK='spiderduck.test.twemcache_pinkfloyd'
MEMCACHE_SPIDERDUCK_XX_TEST_PORT=23360

GIZMODUCK_ZK='gizmoduck.prod.gizmoduck'
GIZMODUCK_PORT=9999

DEFERREDRPC_ZK='deferredrpc.prod.deferredrpc'
DEFERREDRPC_PORT=9910

PINK_SAFE_CORE_ZK='spiderduck.prod.pink-constructor-safecore'
PINK_SAFE_CORE_PORT=10011

PINK_STORE_ZK='spiderduck.prod.pink-store'
PINK_STORE_PORT=10012

TFLOCK_ZK='tflock.prod.tflock'
TFLOCK_PORT=6915

FLOCK_ZK='flock.prod.flock'
FLOCK_PORT=6916

TWEETYPIE_ZK='tweetypie.prod.tweetypie'
TWEETYPIE_PORT=7979

GIZMODUCK_ZK='gizmoduck.staging.gizmoduck'
GIZMODUCK_PORT=9999

JUBJUB_ZK='jubjub.staging.jubjub_service_v2'
JUBJUB_PORT=1234

BLENDER_ZK='search.prod.blender'
BLENDER_PORT=8686

ROASTDUCK_ZK='xx.devel.roastduck-clusterer'
ROASTDUCK_PORT=8702

TIMELINE_SERVICE_ZK='timelineservice.prod.timelineservice'
TIMELINE_SERVICE_PORT=8287
