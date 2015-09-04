#!/bin/bash
# access translate.google.com from terminal

help='USAGE 1:
translate.sh <text> [[<source language>] <target language>]
if target missing, use DEFAULT_TARGET_LANG
if source missing, use auto

USAGE 2:
cat myfile | translate.sh [...]'

# adjust to taste
DEFAULT_TARGET_LANG=en
TMP=/tmp/google_translate.out

# Parse arguments
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

# Querying Google
translate_line() {
  text=${1:0:10000}  # Limit size to 10k
  curl -s -i --user-agent "" -d "ie=UTF-8" -d "hl=en" -d "sl=$source" -d "tl=$target" --data-urlencode "text=$text" https://translate.google.com/m > $TMP

  # after redirect (get both sets of headers) use last version of encoding:
  encoding=$(cat "$TMP" | grep -o -E 'charset=[^"]+' | tail -n1 | cut -d'=' -f2)

  # extract from HTML, decode HTML entities
  ans=$(cat "$TMP" | iconv -f $encoding | grep -o -E 'class="t0">.*?</div>' | cut -c12- );
  echo "${ans%</div>}" | perl -MHTML::Entities -ne 'print decode_entities($_)'
}

# Use stdin as input, if no cmd-line args are given. Limit to 10KB.
if [[ -z $1 ]]; then
  while read -r line; do translate_line "$line"; done
else
  translate_line "$*"
fi

exit
