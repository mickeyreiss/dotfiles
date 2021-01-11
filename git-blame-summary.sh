#!/bin/bash

set -e
set -o pipefail

debug() {
  if [[ "$DEBUG" ]]; then
    echo "$*" >&2
  fi
}

git_blame_summary_file() {
  debug "git_blame_summary_file: $*"

  AUTHOR=${1?'usage: git-blame-summary-file AUTHOR GIT_SHA FILENAME'}
  GIT_SHA=${2?'usage: git-blame-summary-file AUTHOR GIT_SHA FILENAME'}
  FILENAMES=( "${@:3}" )

  for FILENAME in ${FILENAMES[*]}; do
    EDITED="$( git blame "${GIT_SHA?}" -- "${FILENAME?}" | ( grep -i --count "${AUTHOR?}" || true ) )"
    TOTAL="$( ( wc -l "${FILENAME?}" | sed 's/^ *//' | cut -f1 -d' ' ) || echo '0' )"
    if [[ "${TOTAL?}" -gt "0" && "${EDITED?}" -gt "0" ]]; then
      PCT=$(echo "100 * (${EDITED?}) / (${TOTAL?})" | bc)
      printf "%s,%d,%d,%d%%\n" "${FILENAME?}" "${EDITED?}" "${TOTAL?}" "${PCT?}"
    fi
  done
}

git_blame_summary() {
  AUTHOR=${1?'usage: git-blame-summary AUTHOR [GIT_SHA]'}
  GIT_SHA=${2:-'HEAD'}

  echo "filename,lines_edited,lines_total,lines_edit_pct"
  fd -t f .go | xargs -n100 -P16 "$0" "${AUTHOR?}" "${GIT_SHA?}" | sort --field-separator=',' --key=4nr --key=3nr
}

case "$#" in
  1)
    git_blame_summary "$@"
    ;;
  *)
    git_blame_summary_file "$@"
    ;;
esac
