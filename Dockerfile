FROM alpine:3.2

MAINTAINER Yves Blusseau <90z7oey02@sneakemail.com> (@blusseau)

RUN apk update && apk add git go && \
    export GOPATH=/tmp/gopath; \
    go get -v github.com/github/lfs-test-server && \
    mv $GOPATH/bin/lfs-test-server /bin/ && \
    apk del git go && \
    rm -rf /var/cache/apk/* $GOPATH && \
    mkdir /data

#LFS_LISTEN      # The address:port the server listens on, default: "tcp://:8080"
#LFS_HOST        # The host used when the server generates URLs, default: "localhost:8080"
#LFS_METADB      # The database file the server uses to store meta information, default: "lfs.db"
#LFS_CONTENTPATH # The path where LFS files are store, default: "lfs-content"
#LFS_ADMINUSER   # An administrator username, default: unset (Require to have the web UI interface)
#LFS_ADMINPASS   # An administrator password, default: unset (Require to have the web UI interface)
#LFS_CERT        # Certificate file for tls
#LFS_KEY         # tls key
#LFS_SCHEME      # set to 'https' to override default http

ENV LFS_CERT="git-lfs-test-server.crt" \
    LFS_KEY="git-lfs-test-server.key"

WORKDIR /data

COPY /run.sh /run.sh

CMD "/run.sh"
