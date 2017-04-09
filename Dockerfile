# mount the GHC source code into /home/ghc
#
#    sudo docker run --rm -i -t -v `pwd`:/home/ghc gregweber/ghc-haskell-dev /bin/bash
#
# There is one final setup step to run once you have the image up:
#
#    arc install-certificate
#
# This places a .arcrc file (which is ignored) in your repo
# arc is a tool to interface with phabricator, the main ghc development tool.
# When you have a patch ready, run:
#
#    arc diff
#
# Look here on how to kick off your first build:
# https://ghc.haskell.org/trac/ghc/wiki/Building/Hacking

FROM debian:testing
MAINTAINER Greg Weber

RUN apt-get update && apt-get install -y \
  # Needed for adding the PPA key
  gnupg \
  gpgv 

## add ppa for ubuntu trusty haskell packages
# from darinmorrison/haskell
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F6F88286 \
  && echo 'deb     http://ppa.launchpad.net/hvr/ghc/ubuntu yakkety main' >> /etc/apt/sources.list.d/haskell.list \
  && echo 'deb-src http://ppa.launchpad.net/hvr/ghc/ubuntu yakkety main' >> /etc/apt/sources.list.d/haskell.list

RUN apt-get update && apt-get install -y \

  # from darinmorrison/haskell, related to ncurses, not sure if it is needed
  libtinfo5 \

  # mentioned on the GHC wiki
  autoconf automake libtool make libgmp-dev ncurses-dev g++ python bzip2 ca-certificates \
  llvm \
  llvm-3.7 llvm-3.8 llvm-3.9 \
  xz-utils \

  ## install minimal set of haskell packages
  # from darinmorrison/haskell
  ghc-8.0.1 \
  alex \
  cabal-install-1.24 \
  happy \

  # development conveniences
  sudo xutils-dev \

  # For document generation
  xsltproc docbook-xsl \
  python-sphinx \
  
  # Needed for testing current HEAD
  python3 \
  
  # Needed for running nofib
  time \

  # arc tool
  # It makes a lot more sense to run this from your host
  git php-cli php-curl libssl-dev vim-tiny \
  && apt-get clean

RUN mkdir /php && cd /php \
  && git clone https://github.com/phacility/libphutil.git \
  && git clone https://github.com/phacility/arcanist.git

# for building the ghc manual
#RUN apt-get update \
# && apt-get install -y dblatex docbook-xsl docbook-utils \
# && apt-get clean

ENV LANG     C.UTF-8
ENV LC_ALL   C.UTF-8
ENV LANGUAGE C.UTF-8

RUN useradd -m -d /home/ghc -s /bin/bash ghc
RUN echo "ghc ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ghc && chmod 0440 /etc/sudoers.d/ghc
ENV HOME /home/ghc
WORKDIR /home/ghc
USER ghc

ENV PATH /opt/ghc/8.0.1/bin:/opt/cabal/1.24/bin:/php/arcanist/bin:$PATH 

# Build dependencies for nofib-analyse
RUN cabal update && cabal install html regex-compat 

