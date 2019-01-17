#!/bin/bash

# /usr/sbin/sshd
naoqi-bin -p 9000 &
choregraphe-bin --no-naoqi --no-discovery -p 9000
