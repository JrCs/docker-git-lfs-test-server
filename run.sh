#!/bin/sh

set -eu
set -o pipefail

CERTS_DIR=/data/certs
[ -f /data/certs/server.crt ] && export LFS_CERT=/data/certs/server.crt
[ -f /data/certs/server.key ] && export LFS_KEY=/data/certs/server.key

[ -n "$LFS_CERT" -a -n "$LFS_KEY" ] && export LFS_SCHEME="https"

exec /bin/lfs-test-server
