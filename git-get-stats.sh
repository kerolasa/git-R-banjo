#!/bin/bash
#
# Get data from git repository to be plotted with R.
# Sami Kerola <kerolasa@iki.fi>

trap 'echo "exit on error"; exit 1' ERR
set -e	# exit on errors
set -u	# disallow usage of unset variables
set -C	# disallow existing regular files to be overwritten

echo "commits|name" > committers.dat
git shortlog --no-merges -sne $@ |
	sed 's/^ *\([0-9]*\)\t*\(.*\) <.*/\1|\2/' >> committers.dat

echo "date,files,insertions,deletions" > dates-lines.dat
git log master --no-merges --shortstat --pretty="format: %ai" $@ |
	awk '{
		if ($1 ~ /20[0-9][0-9]-[0-9][0-9]/) {
			A=$1; B=$2
		}
		if ($0 ~ /files changed/) {
			print A, B ",", $1 ",", $4 ",", $6
		}
	}' >> dates-lines.dat

echo "insertions deletions file" > file-changes.dat
git log master --no-merges --pretty="format:" --numstat $@ >> file-changes.dat

echo "tag,date" > tags.dat
git for-each-ref --sort='*authordate' \
	--format='%(refname:short),%(*authordate)' refs/tags $@ >> tags.dat

echo "All done; run next doR.ksh"
echo "...unless you want to manually tamper the input data, see ls *.dat"

exit 0
