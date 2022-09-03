FROM debian:latest

WORKDIR /opt/work

ARG TARGET

# Setup ENV
ENV WORKSPACE="/opt/work"
ENV PREFIX="/opt/cross"
ENV PATH="${PREFIX}/bin:$PATH"

# Do update
RUN apt-get update

# Install Dependencies
    # Linux Tools
        RUN apt-get install -y -qq wget
        RUN apt-get install -y -qq curl
        RUN apt-get install -y -qq git
    # Required
        RUN apt-get install -y -qq build-essential
        RUN apt-get install -y -qq bison
        RUN apt-get install -y -qq flex
        RUN apt-get install -y -qq libgmp3-dev
        RUN apt-get install -y -qq libmpc-dev
        RUN apt-get install -y -qq libmpfr-dev
        RUN apt-get install -y -qq texinfo
		RUN apt-get install -y -qq grub-pc-bin
		RUN apt-get install -y -qq xorriso

# Copy needed files
    COPY ./resources "${WORKSPACE}"

# Build BinUtils
    RUN mkdir ${WORKSPACE}/build-binutils
    WORKDIR "${WORKSPACE}/build-binutils"
    RUN ../binutils/configure --target=$TARGET --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror
    RUN make
    RUN make install

# Build GCC
    RUN mkdir ${WORKSPACE}/build-gcc
    WORKDIR "${WORKSPACE}/build-gcc"  
    RUN ../gcc/configure --target=$TARGET --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ --without-headers --disable-multilib
    RUN make all-gcc
    RUN make all-target-libgcc
    RUN install-gcc
    RUN install-target-libgcc