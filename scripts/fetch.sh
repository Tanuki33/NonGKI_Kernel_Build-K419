#!/bin/sh
# Download a URL to a file, retrying transient failures.
#
# The prebuilt toolchain hosts (android.googlesource.com in particular) answer
# 503 when they are under load, and a single failed toolchain download fails
# the whole build matrix. Retry with backoff instead of dying on the first
# response code.
#
#   scripts/fetch.sh <url> <output> [attempts]
set -eu

url="$1"
out="$2"
attempts="${3:-6}"

try=1
while [ "$try" -le "$attempts" ]; do
	if curl -fsSL --retry 3 --retry-delay 5 --retry-all-errors \
			--connect-timeout 30 --max-time 1800 -o "$out" "$url"; then
		exit 0
	fi
	echo "download failed (attempt $try/$attempts): $url" >&2
	try=$((try + 1))
	if [ "$try" -le "$attempts" ]; then
		sleep $((try * 5))
	fi
done

echo "giving up on $url after $attempts attempts" >&2
exit 1
