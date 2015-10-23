#!/bin/sh

set -eu
set -o pipefail

CERTS_DIR=/data/certs
[ ! -d "$CERTS_DIR" ] && mkdir -p $CERTS_DIR
[ ! "${LFS_CERT:0:1}" == / ] && export LFS_CERT="$CERTS_DIR/$LFS_CERT"
[ ! "${LFS_KEY:0:1}"  == / ] && export LFS_KEY="$CERTS_DIR/$LFS_KEY"

exec /bin/lfs-test-server
