# Script for adjust the brightness of the backlight on some laptops.
# Written for Lenovo X1 Extreme v2 with XFCE, bcause the brightness keyborad bindings
# were broken for a little while.

set -euo pipefail

cmd="${1:-}"
if [[ "$cmd" != "up" && "$cmd" != "down" ]]; then
  echo "Usage: $0 (up|down)"
  exit 1
fi

# Brightness limits
MAX="$(pkexec xfpm-power-backlight-helper --get-max-brightness)"
MIN=$(( $MAX / 200 ))
MIN_DELTA=$MIN

# Current brightness
curr="$(pkexec xfpm-power-backlight-helper --get-brightness)"

# Compute the delta. Use approx 20 steps ...
delta=$(( $MAX / 20 ))
# ... but go finer-grained once we reach low light levels ...
if (( $delta > $curr / 4 )); then delta=$(( $curr / 4 )); fi
# ... but don't go too fine-grained.
if (( $delta < $MIN_DELTA )); then delta=$MIN_DELTA; fi

if [[ "$cmd" == "down" ]]; then delta=$(( -$delta )); fi

# Clamp target value
target=$(( $curr + $delta ))
if (( $target < $MIN )); then target=$MIN; fi
if (( $target > $MAX )); then target=$MAX; fi

# Change brightness
echo "Changing display brightness from $curr ($(($curr*100/$MAX))%) to $target ($(($target*100/$MAX))%)"
pkexec xfpm-power-backlight-helper --set-brightness $target
