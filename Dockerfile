# Original: https://gist.github.com/tasuten/0431d8af3e7b5ad5bc5347ce2d7045d7
# https://github.com/ejuarezg/containers/blob/master/iosevka_font/Dockerfile

# Run example
#
# docker run \
#     -v ./build:/build \
#     iosevka_build

FROM gitpod/workspace-base:latest

ARG OTFCC_VER=0.10.4
ARG PREMAKE_VER=5.0.0-alpha15
ARG NODE_VER=14

RUN sudo dpkg-reconfigure debconf --frontend=noninteractive \
    && sudo apt-get update \
    && sudo apt-get install --no-install-recommends -y \
        build-essential \
	jq \
        file \
        curl \
        ca-certificates \
        ttfautohint \
    && curl -sSL https://deb.nodesource.com/setup_${NODE_VER}.x | sudo bash - \
    && sudo apt-get install -y nodejs
WORKDIR /tmp
RUN curl -sSLo premake5.tar.gz https://github.com/premake/premake-core/releases/download/v${PREMAKE_VER}/premake-${PREMAKE_VER}-linux.tar.gz \
    && tar xvf premake5.tar.gz \
    && sudo mv premake5 /usr/local/bin/premake5 \
    && rm premake5.tar.gz \
    && curl -sSLo otfcc.tar.gz https://github.com/caryll/otfcc/archive/v${OTFCC_VER}.tar.gz \
    && tar xvf otfcc.tar.gz \
    && mv otfcc-${OTFCC_VER} otfcc
WORKDIR /tmp/otfcc
RUN premake5 gmake
WORKDIR /tmp/otfcc/build/gmake
RUN make config=release_x64
WORKDIR /tmp/otfcc/bin/release-x64
RUN sudo mv otfccbuild /usr/local/bin/otfccbuild \
    && sudo mv otfccdump /usr/local/bin/otfccdump
WORKDIR /tmp
RUN rm -rf otfcc/ otfcc.tar.gz \
    && sudo rm -rf /var/lib/apt/lists/*

COPY run.sh /run.sh

WORKDIR /build
ENTRYPOINT ["/bin/bash", "/run.sh"]

