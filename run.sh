#!/bin/bash

# /usr/sbin/sshd
naoqi-bin & # --qi-listen-url tcp://:9000 
sleep 15
choregraphe-bin --no-naoqi --no-discovery --ip=127.0.0.1 --port=9559
