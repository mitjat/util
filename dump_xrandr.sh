#!/bin/bash

# Creates an executable bash script that will reproduce the current monitor configuration
# (= which monitors are enabled/disabled, their resolution, and maybe rotation).
#
# Adapted from https://askubuntu.com/questions/756708/xubuntu-save-multi-monitor-config
# The script parses `xrandr` output in a very hacky way and is far from robust or feature-complete

fileName="$1"

[[ "$fileName" != "" ]] || {
    echo "Usage:
  $0 <OUTPUT_PATH>

... then run the generated script at <OUTPUT_PATH> at any time to
reproduce the current monitor configuration."
    exit 1;
}

while read -r line; do
    IFS=" "
    entry=( $line )
    display=${entry[0]}
    IFS="x+"
    if [[ "${entry[2]}" == primary ]]; then
        primary=1
        measurement=( ${entry[3]} )
    elif [[ "${entry[2]}" == "("* ]]; then
	xrandrOpt+=$' \\\n'" --output $display --off"
	continue
    else
        primary=0
        measurement=( ${entry[2]} )
    fi
    unset IFS
    width=${measurement[0]}
    height=${measurement[1]}
    left=${measurement[2]}
    top=${measurement[3]}

    xrandrOpt+=$' \\\n'" --output $display --mode ${width}x${height} --pos ${left}x${top}"
    ((primary)) && xrandrOpt="$xrandrOpt --primary"
done < <(xrandr | grep " connected")
unset IFS

echo "#!/bin/bash
# Generated with $(basename $0)
xrandr $xrandrOpt
" > "$fileName"
chmod +x "$fileName"
