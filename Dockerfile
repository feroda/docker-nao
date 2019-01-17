FROM ubuntu:12.04

COPY choregraphe-suite-2.1.4.13-linux64.tar.gz /opt/

RUN apt-get update && apt-get install -y \
    python-pip libpython2.7 libboost-all-dev sudo \
    libfreetype6 libsm6 libxrender1 fontconfig libxext6 libxt6 libxaw7 libglu1-mesa libxrandr2 && \
    tar -C /opt -xvzf /opt/choregraphe-suite-2.1.4.13-linux64.tar.gz

# User for Choregraphe (NAO)
# Replace 1000 with your user / group id
RUN export uid=1000 gid=1000 && \
    mkdir -p /home/naouser && \
    echo "naouser:x:${uid}:${gid}:NAO User,,,:/home/naouser:/bin/bash" >> /etc/passwd && \
    echo "naouser:x:${uid}:" >> /etc/group && \
    echo "naouser   ALL = (ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    chown ${uid}:${gid} -R /home/naouser

USER naouser
ENV HOME /home/naouser
ENV PATH $PATH:/opt/choregraphe-suite-2.1.4.13-linux64/bin/
# environment QT_X11_NO_MITSHM needed to avoid Bad Access Permission
# ref: https://github.com/osrf/docker_images/issues/21
ENV QT_X11_NO_MITSHM 1

COPY . /home/naouser
WORKDIR /home/naouser
CMD ["./run.sh"]

