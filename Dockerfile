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

RUN sudo apt-get update
RUN sudo DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
        build-essential \
	jq \
        file \
        curl \
        ca-certificates \
        ttfautohint
RUN curl -sSL https://deb.nodesource.com/setup_${NODE_VER}.x | bash -
RUN sudo apt-get install -y nodejs
RUN cd /tmp
RUN curl -sSLo premake5.tar.gz https://github.com/premake/premake-core/releases/download/v${PREMAKE_VER}/premake-${PREMAKE_VER}-linux.tar.gz
RUN tar xvf premake5.tar.gz
RUN mv premake5 /usr/local/bin/premake5
RUN rm premake5.tar.gz
RUN curl -sSLo otfcc.tar.gz https://github.com/caryll/otfcc/archive/v${OTFCC_VER}.tar.gz
RUN tar xvf otfcc.tar.gz
RUN mv otfcc-${OTFCC_VER} otfcc
RUN cd /tmp/otfcc
RUN premake5 gmake
RUN cd build/gmake
RUN make config=release_x64
RUN cd /tmp/otfcc/bin/release-x64
RUN mv otfccbuild /usr/local/bin/otfccbuild
RUN mv otfccdump /usr/local/bin/otfccdump
RUN cd /tmp
RUN rm -rf otfcc/ otfcc.tar.gz
RUN rm -rf /var/lib/apt/lists/*

COPY run.sh /run.sh

WORKDIR /build
ENTRYPOINT ["/bin/bash", "/run.sh"]

