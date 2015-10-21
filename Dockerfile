FROM alpine:3.2

MAINTAINER Yves Blusseau <90z7oey02@sneakemail.com> (@blusseau)

#LFS_LISTEN      # The address:port the server listens on, default: "tcp://:8080"
#LFS_HOST        # The host used when the server generates URLs, default: "localhost:8080"
#LFS_METADB      # The database file the server uses to store meta information, default: "lfs.db"
#LFS_CONTENTPATH # The path where LFS files are store, default: "lfs-content"
#LFS_ADMINUSER   # An administrator username, default: unset
#LFS_ADMINPASS   # An administrator password, default: unset
#LFS_CERT        # Certificate file for tls
#LFS_KEY         # tls key
#LFS_SCHEME      # set to 'https' to override default http

ENV LFS_LISTEN="tcp://:9999"  \
    LFS_HOST="localhost:9999" \
    LFS_METADB=""             \
    LFS_CONTENTPATH="content" \
    LFS_ADMINUSER="admin"     \
    LFS_ADMINPASS="admin"     \
    LFS_CERT=""               \
    LFS_KEY=""                \
    LFS_SCHEME="http"

RUN export http_proxy=http://10.203.69.254:3128; \
    export https_proxy=$http_proxy; \
    apk update && apk add curl git go && \
    export GOPATH=/tmp/gopath; \
    go get -v github.com/github/lfs-test-server && \
    mv $GOPATH/bin/lfs-test-server /bin/ && \
    apk del curl git go && \
    rm -rf /var/cache/apk/* $GOPATH && \
    mkdir /data

WORKDIR /data

COPY /run.sh /run.sh

CMD "/run.sh"
