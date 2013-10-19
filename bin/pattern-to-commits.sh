#!/usr/bin/env bash
# Turn a life cell pattern into a list of commits suitable for decorating
# a GitHub contribution timeline.
#
# The cell pattern file is expected to be in the format described at
# http://www.conwaylife.com/wiki/Plaintext. The pattern described should be
# 7 rows or less in height in order to fit on the GitHub timeline.
#
#/ Usage: pattern-to-commits.sh something.cell [YYYY-MM-DD]
#/   If no start date is given, pattern will start today.
#
# Author: Bryan Davis <bd808@bd808.com>
# Copyright: 2013, Bryan Davis and contribtors. All Rights Reserved.
# License: MIT (see http://opensource.org/licenses/MIT)

set -e

INPUT_FILE=${1:?Cell file required}
START_DATE=${2:-$(date +%F)}

# Set "DATE_PGRM" in env to a GNU date binary
: ${DATE_PRGM=date}

[[ -r $INPUT_FILE ]] || {
  echo "File ${INPUT_FILE} not readable" >&2
  exit 64
}

# make a place to keep some scratch files
WORK_DIR=$(mktemp -d ${TMPDIR:-/tmp}/tmp.XXXXXXXXXX)
# clean up our junk on exit
#trap 'rm -rf ${WORK_DIR}' EXIT

# make a copy of the pattern file with comments stripped
CLEANED="${WORK_DIR}/clean"
grep -v '^!' -- "${INPUT_FILE}" >"${CLEANED}"

# count the number of rows in the pattern
LINES=$(wc -l <"${CLEANED}")
[[ ${LINES} -gt 7 ]] && {
  echo "More than 7 rows in ${INPUT_FILE}" >&2
  echo "Cowardly refusing to continue." >&2
  exit 65
}

# fill for patterns less than 7 rows tall
VFILL=$((7 - ${LINES}))

# length of longest line in pattern
MAX_COL=$(awk '{if (length > max) {max = length}} END {print max}' "${CLEANED}")

# TODO: shift the START_DATE to the prior Sunday iff not Sunday

# read the pattern by columns
# when we find a `O` then emit a commit for every hour in that day
DAY=-1
for (( col = 1; col <= ${MAX_COL}; col++ )); do
  WEEK="$(cut -c ${col} "${CLEANED}")"
  for cell in $WEEK; do
    DAY=$(( ${DAY} + 1 ))
    if [[ 'O' == ${cell} ]]; then
      # this will only work if $DATE_PRGM is GNU date.
      # BSD date is not the same at all.
      DATE=$(${DATE_PRGM} -d "${START_DATE} ${DAY} days" +%F)
      for h in $(seq -w 1 23); do
        for m in $(seq -w 0 10 50); do
          CDATE="${DATE}T${h}:${m}"
          echo "GIT_AUTHOR_DATE='${CDATE}' GIT_COMMITTER_DATE='${CDATE}' git commit --allow-empty -m '${CDATE}'"
        done
      done
    fi
  done
  # fast-forward to the end of the week
  DAY=$(( ${DAY} + ${VFILL} ))
done
