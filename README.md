# docker-lfs-test-server
Github's git large file support (LFS) test server Dockerized  

Upstream: https://github.com/github/lfs-test-server

# Quick Start

Launch the gitlab container:

```bash
docker run --name git-lfs-server -d \
    --env 'LFS_HOST=localhost:8080' \
    --publish 8080:8080 \
    --env 'LFS_ADMINUSER=admin' --env 'LFS_ADMINPASS=admin' \
    --volume /srv/git-lfs-server/data:/data \
    jrcs/git-lfs-test-server
```
*Please refer to [Available Configuration Parameters](#available-configuration-parameters) to understand `LFS_HOST` and other configuration options*

## Web Interface
If you have defined a login and password for the admin user (with LFS_ADMINUSER and LFS_ADMINPASS environment variables) point your browser to `http://localhost:8080/mgmt`

# Configuration

## Data Store

To avoid losing any data, you should mount a volume at,

* `/data`

SELinux users are also required to change the security context of the mount point so that it plays nicely with selinux.

```bash
mkdir -p /srv/git-lfs-server/data
sudo chcon -Rt svirt_sandbox_file_t /srv/git-lfs-server/data
```

Volumes can be mounted in docker by specifying the `--volume` option in the docker run command.

```bash
docker run --name git-lfs-server -d \
    --volume /srv/git-lfs-server/data:/data \
    jrcs/git-lfs-test-server
```

### SSL

Access to git-lfs-test-server can be secured using SSL. While a CA certified SSL certificate allows for verification of trust via the CA, a self signed certificates can also provide an equal level of trust verification as long as each client takes some additional steps to verify the identity of your website. I will provide instructions on achieving this towards the end of this section.

To secure your application via SSL you basically need two things:
- **Private key (.key)**
- **SSL certificate (.crt)**

When using CA certified certificates, these files are provided to you by the CA. When using self-signed certificates you need to generate these files yourself.

#### Generation of Self Signed Certificates

Generation of self-signed SSL certificates involves a simple 3 step procedure.

**STEP 1**: Create the server private key

```bash
openssl genrsa -out git-lfs-test-server.key 2048
```

**STEP 2**: Create the certificate signing request (CSR)

```bash
openssl req -new -key git-lfs-test-server.key -out git-lfs-test-server.csr
```

**STEP 3**: Sign the certificate using the private key and CSR

```bash
openssl x509 -req -days 3650 -in git-lfs-test-server.csr -signkey git-lfs-test-server.key -out git-lfs-test-server.crt
```

Congratulations! you have now generated an SSL certificate that will be valid for 10 years.

#### Installation of the SSL Certificates

Out of the three files generated above, we need to install the `git-lfs-test-server.key` and `git-lfs-test-server.crt` files at the git-lfs server. The CSR file is not needed, but do make sure you safely backup the file (in case you ever need it again).

The default path that the git-lfs application is configured to look for the SSL certificates is at `/data/certs`.

If you remember from above, the `/srv/git-lfs-server/data` path is the path of the [data store](#data-store), which means that we have to create a folder named certs inside `/srv/git-lfs-server/data/` and copy the files into it and as a measure of security we will update the permission on the `git-lfs-test-server.key` file to only be readable by the owner.

```bash
mkdir -p /srv/git-lfs-server/data/certs
cp git-lfs-test-server.key /srv/git-lfs-server/data/certs/
cp git-lfs-test-server.crt /srv/git-lfs-server/data/certs/
chmod 400 /srv/git-lfs-server/data/certs/gitlab.key
```

### Available Configuration Parameters

*Please refer the docker run command options for the `--env-file` flag where you can specify all required environment variables in a single file. This will save you from writing a potentially long docker run command. Alternatively you can use docker-compose.*

Below is the complete list of available options that can be used to customize your gitlab installation.

- **LFS_LISTEN**: The address:port the server listens on, default: `tcp://:8080`
- **LFS_HOST**: The host used when the server generates URLs, default: `localhost:8080`
- **LFS_METADB**: The database file the server uses to store meta information, default: `lfs.db`
- **LFS_CONTENTPATH**: The path where LFS files are store, default: `lfs-content`
- **LFS_ADMINUSER**: An administrator username, default: unset (Require to have the web UI interface)
- **LFS_ADMINPASS**: An administrator password, default: unset (Require to have the web UI interface)
- **LFS_CERT**: Certificate file for tls, default: `git-lfs-test-server.crt`
- **LFS_KEY**: Private key file for tls, default: `git-lfs-test-server.key` 
- **LFS_SCHEME**: Set to 'https' to override default `http`

If the **LFS_ADMINUSER** and **LFS_ADMINPASS** variables are set, a
rudimentary admin interface can be accessed via
`http://$LFS_HOST/mgmt`. Here you can add and remove users.

### Using the git-lfs-server from a Git LFS client

To use the LFS test server with the [Git LFS client](https://git-lfs.github.com/), configure it in the repository's `.gitconfig` file:

```
  [lfs]
    url = "http://localhost:8080/"
```

HTTPS:

NOTE: If using https with a self signed cert also disable cert checking in the client repo.

```
	[lfs]
		url = "https://localhost:8080/"

	[http]
		sslverify = false

```