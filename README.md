# README #

This Docker build environment will compile ```cardano-node```, ```cardano-cli```, and ```libsodium``` binaries for Ubuntu 20.04 LTS, with reliable and predictable results. This setup will always build against the specified version of the binaries, you just need to change the desired version in ```Dockerfile``` and ```docker-compose.yml``` when needed.

**You must run these steps to compile ```cardano-node```, ```cardano-cli```, and ```libsodium``` on your local computer. Then ```scp``` them over to your servers after successful compilation. It is still necessary and up to you to run ```ldconfig``` against ```libsodium.so``` on the servers (see files/libsodium.conf).**

## Steps to Compile ##

### Install Docker Desktop ###

**macOS/Windows**: Install and run Docker Desktop, for your OS from [the official site](https://www.docker.com/products/docker-desktop), on your local computer.

**Linux**: use Docker directly. Linux doesn't require Docker Desktop.

### Clone the build repo ###

```bash
git clone https://github.com/gacallea/cnodeBuildEnv.git
```

### Compile the software ###

```bash
cd cnodeBuildEnv
```

```bash
docker-compose up --build -d
```

### Copy the binaries to your host ###

Once the previous compilation step has completed successfully, issue these commands to copy the compiled binaries to the local ```cardano-bins``` directory.

```bash
docker container cp build_builder_1:/usr/local/bin cardano-bins/
```

```bash
docker container cp build_builder_1:/usr/local/lib cardano-bins/
```

### Copy the binaries to your nodes ###

**Make sure you point to your actual servers. These are just examples:**

```bash
scp cardano-bins/bin/cardano-node node-server:/usr/local/bin/
scp cardano-bins/bin/cardano-cli node-server:/usr/local/bin/
scp cardano-bins/lib/libsodium.so node-server:/usr/local/lib/
```

```bash
scp cardano-bins/bin/cardano-node relay-server:/usr/local/bin/
scp cardano-bins/bin/cardano-cli relay-server:/usr/local/bin/
scp cardano-bins/lib/libsodium.so relay-server:/usr/local/lib/
```
