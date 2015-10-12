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

## add ppa for ubuntu trusty haskell packages
# from darinmorrison/haskell
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F6F88286 \
  && echo 'deb     http://ppa.launchpad.net/hvr/ghc/ubuntu trusty main' >> /etc/apt/sources.list.d/haskell.list \
  && echo 'deb-src http://ppa.launchpad.net/hvr/ghc/ubuntu trusty main' >> /etc/apt/sources.list.d/haskell.list

RUN apt-get update && apt-get install -y \

  # from darinmorrison/haskell, related to ncurses, not sure if it is needed
  libtinfo5 \

  # mentioned on the GHC wiki
  autoconf automake libtool make libgmp-dev ncurses-dev g++ llvm llvm-3.6 python bzip2 ca-certificates \

  ## install minimal set of haskell packages
  # from darinmorrison/haskell
  ghc-7.8.3 \
  alex \
  cabal-install-1.20 \
  happy \

  # development conveniences
  sudo xutils-dev \

  # For document generation
  xsltproc docbook-xsl \
  python-sphinx \

  # arc tool
  # It makes a lot more sense to run this from your host
  git php5-cli php5-curl libssl-dev vim-tiny \
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

ENV PATH /opt/ghc/7.8.3/bin:/php/arcanist/bin:$PATH 
