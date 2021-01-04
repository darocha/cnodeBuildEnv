### CARDANO NODE BUILDER CONTAINER ###
FROM ubuntu:20.04 AS cardano-builder

# Change the Cardano Node version and git tag, and Cabal and GHC versions, here
ENV CABAL_VERSION="3.4" \
    GHC_VERSION="8.10.2" \
    CARDANO_NODE_VERSION="1.24.2" \
    CARDANO_NODE_GIT_TAG="1.24.2" \
    PATH="/opt/ghc/bin:/opt/cabal/bin:${PATH}" \
    LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH" \
    PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH"

# Install the packages needed to compile cardano node software
# GHC and Cabal from the official PPA - https://launchpad.net/~hvr/+archive/ubuntu/ghc
RUN apt-get update -y && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:hvr/ghc && \
    apt-get update -y && \
    apt-get install -y \
    automake build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev \
    libsystemd-dev zlib1g-dev make g++ tmux git jq wget libncursesw5 libtool autoconf \
    apt-utils cabal-install-${CABAL_VERSION} ghc-${GHC_VERSION} && \
    cabal update

# Clone + build libsodium
WORKDIR /usr/local/src/
RUN git clone https://github.com/input-output-hk/libsodium
WORKDIR /usr/local/src/libsodium
RUN git checkout 66f017f1 && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install

# Clone + build cardano-node
WORKDIR /usr/local/src/
RUN git clone https://github.com/input-output-hk/cardano-node
WORKDIR /usr/local/src/cardano-node/
RUN git fetch --all --recurse-submodules --tags && \
    git checkout tags/${CARDANO_NODE_GIT_TAG} && \
    echo "package cardano-crypto-praos" >> cabal.project.local && \
    echo "flags: -external-libsodium-vrf" >> cabal.project.local && \
    cabal build all --minimize-conflict-set

WORKDIR /usr/local/src/cardano-node/dist-newstyle/build/x86_64-linux/ghc-${GHC_VERSION}/
RUN cp -f \
    ./cardano-node-${CARDANO_NODE_VERSION}/x/cardano-node/build/cardano-node/cardano-node \
    ./cardano-cli-${CARDANO_NODE_VERSION}/x/cardano-cli/build/cardano-cli/cardano-cli \
    /usr/local/bin/
