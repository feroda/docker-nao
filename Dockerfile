FROM ubuntu:12.04

COPY SDK/*linux64* /opt/

RUN apt-get update && apt-get install -y \
    python-pip libpython2.7 libboost-all-dev sudo unzip \
    software-properties-common python-software-properties \
    libfreetype6 libsm6 libxrender1 fontconfig libxext6 libxt6 libxaw7 libglu1-mesa libxrandr2 && \
    tar -C /opt -xvzf /opt/choregraphe-suite-*-linux64.tar.gz && \
    tar -C /opt -xvzf /opt/pynaoqi-python2.7-*-linux64.tar.gz && \
    tar -C /opt -xvzf /opt/naoqi-sdk-*-linux64.tar.gz && \
    unzip -d /opt /opt/ctc-linux64-atom-*.zip && \
    ln -sf /opt/choregraphe-suite-*-linux64 /opt/choregraphe && \
    ln -sf /opt/pynaoqi-python2.7-*-linux64 /opt/pynaoqi && \
    ln -sf /opt/naoqi-sdk-*-linux64 /opt/naoqi-sdk

# User for Choregraphe (NAO)
# Replace 1000 with your user / group id
RUN export uid=1000 gid=1000 && \
    mkdir -p /home/naouser && \
    echo "naouser:x:${uid}:${gid}:NAO User,,,:/home/naouser:/bin/bash" >> /etc/passwd && \
    echo "naouser:x:${uid}:" >> /etc/group && \
    echo "naouser   ALL = (ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    chown ${uid}:${gid} -R /home/naouser

# Step to install the C++ SDK
RUN add-apt-repository -y ppa:george-edison55/precise-backports && \
    apt-get update && apt-get install -y \
    net-tools libgtk2.0-dev pkg-config gcc cmake qtcreator 

RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    python get-pip.py && cp /usr/local/bin/pip /usr/bin/pip && \
    pip install qibuild

# Step 2: create C++ toolchain
WORKDIR /opt/naoqi-sdk
# WARNING: at 
# http://doc.aldebaran.com/2-1/dev/cpp/install_guide.html#d-sdk-installation
# they say that there should be an SDK EMPTY folder... I don't believe it
RUN qibuild init 
WORKDIR /opt/naoqi-sdk/doc/dev/cpp/examples
RUN qitoolchain create mytoolchain /opt/naoqi-sdk/toolchain.xml && \
    qibuild add-config mytoolchain -t mytoolchain --default 

# Step 3: compile sayhelloworld example and alvisualcompass example
# TODO: do it as unprivileged user
WORKDIR /opt/naoqi-sdk/doc/dev/cpp/examples/core/sayhelloworld
RUN qibuild configure && qibuild make
WORKDIR /opt/naoqi-sdk/doc/dev/cpp/examples/vision/alvisualcompass
RUN qibuild configure && qibuild make

# Become unprivileged naouser to launch choregraphe
USER naouser
ENV HOME /home/naouser
ENV PATH $PATH:/opt/choregraphe/bin/
ENV LD_LIBRARY_PATH SDK/naoqi-sdk/lib/
ENV PYTHONPATH /opt/pynaoqi/

# environment QT_X11_NO_MITSHM needed to avoid Bad Access Permission
# ref: https://github.com/osrf/docker_images/issues/21
ENV QT_X11_NO_MITSHM 1

COPY . /home/naouser
WORKDIR /home/naouser
CMD ["./run.sh"]

