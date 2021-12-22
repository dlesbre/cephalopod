# Using a small image of debian
FROM bitnami/minideb:latest

ARG DEBIAN_FRONTEND=noninteractive

# Create a user named "user" and give him sudo privileges
# His password is "password"
RUN useradd -m -s /bin/bash -p "$1$c8u/HkYq$4P1SY4xvYAto8yWonByEJ0" user; \
    usermod -a -G sudo user

# Using a single run command for a smaller image,
# as we can delete a bunch of things when done
# 1) Install all dependencies
# 2) Install and build Voss II
# 3) Remove no-longer needed build tools
RUN apt-get update \
&&  apt-get -y install git gcc g++ doxygen flex bison gawk \
                       libz-dev tcl-dev tk-dev libc6-dev imagemagick \
                       clang libreadline-dev python3 pandoc \
                       make ghc bnfc sudo procps \
&&  cd /home/user \
&&  git clone https://github.com/TeamVoss/VossII.git \
&&  make -C VossII/src install \
&&  rm -rf VossII/.git VossII/ckt_examples VossII/src/external VossII/tutorials \
&&  apt-get -y remove git g++ doxygen flex bison gawk \
                      clang python python3 pandoc \
                      llvm-7-dev libgl1-mesa-dri libllvm7 clang-7 \
&&  apt-get -y autoremove

# Build bifrost and copy cephalopode files
COPY . /home/user/src/
RUN mv /home/user/src/.bashrc /home/user/.bashrc

# Build bifrost and ROM images
RUN make -C /home/user/src bifrost

# Switch to user before running
RUN chown -R user /home/user/
USER user
WORKDIR /home/user/src/
CMD bash
