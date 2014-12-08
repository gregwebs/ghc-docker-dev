# A docker container for hacking on GHC

This is on the docker registry as `ghc-haskell-dev`.
To use, mount your GHC source code into /home/ghc

    sudo docker run --rm -i -t -v `pwd`:/home/ghc gregweber/ghc-haskell-dev /bin/bash

You are now ready to compile GHC!
There is one final setup step to run once you have the image up:

    arc install-certificate

This places a .arcrc file (which is git ignored) in your repo
arc is a tool to interface with phabricator, the main ghc development tool.
When you have a patch ready, run:
 
    arc diff

Look here on how to kick off your first build:
https://ghc.haskell.org/trac/ghc/wiki/Building/Hacking
