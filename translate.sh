#!/bin/bash
# access translate.google.com from terminal

help='translate <text> [[<source language>] <target language>]
if target missing, use DEFAULT_TARGET_LANG
if source missing, use auto'

# adjust to taste
DEFAULT_TARGET_LANG=en
TMP=/tmp/google_translate.out

# Use stdin as input, if no cmd-line args are given. Limit to 10KB.
text="${1:-$(cat | head -c10000)}"
# Encode newlines
text="$(echo "$text" | awk 1 ORS=' %%% ')"
echo "TEXT: $text"
echo "TRANS"

if [[ $1 = -h || $1 = --help ]]
then
    echo "$help"
    exit
fi

if [[ $3 ]]; then
    source="$2"
    target="$3"
elif [[ $2 ]]; then
    source=auto
    target="$2"
else
    source=auto
    target="$DEFAULT_TARGET_LANG"
fi

curl -s -i --user-agent "" -d "ie=UTF-8" -d "hl=en" -d "sl=$source" -d "tl=$target" --data-urlencode "text=$text" https://translate.google.com/m > $TMP

# after redirect (get both sets of headers) use last version of encoding:
encoding=$(cat "$TMP" | grep -o -E 'charset=[^"]+' | tail -n1 | cut -d'=' -f2)

ans=$(cat "$TMP" | iconv -f $encoding | grep -o -E 'class="t0">.*?</div>' | cut -c12- ); 
# Decode newlines
echo "${ans%</div>}" #| sed -E 's/%%%/\'$'\n''/g'
exit
