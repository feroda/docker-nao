FROM --platform=amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND noninteractive
RUN apt update && apt install -y vim wget curl \
    python2-minimal iproute2 telnet iputils-ping libogre-1.9.0v5 \
    libpython2.7 libboost-all-dev sudo unzip net-tools libgl1 \
    software-properties-common libgtk2.0-dev pkg-config gcc cmake qtcreator \
    libflac8 libfreetype6 libsm6 libxrender1 fontconfig libxext6 libxt6 libxaw7 libglu1-mesa libxrandr2 && \
    ln -sf /usr/bin/python2 /usr/bin/python && \
    ln -sf /usr/lib/x86_64-linux-gnu/OGRE-1.9.0/ /usr/lib/OGRE-1.9.0 && \
    ln -sf /usr/lib/x86_64-linux-gnu/OGRE-1.9.0/ /usr/lib/OGRE 

# Setup Aldebaran tools
COPY SDK/*.tar.gz /opt/
RUN tar -C /opt -xvzf /opt/robot-settings*.tar.gz && \
    tar -C /opt -xvzf /opt/choregraphe-*.tar.gz && \
    tar -C /opt -xvzf /opt/pynaoqi-python2.7-*.tar.gz && \
    ln -sf /opt/choregraphe-*/ /opt/choregraphe && \
    ln -sf /opt/pynaoqi-python2.7-*/ /opt/pynaoqi && \
    ln -sf /opt/robot-settings-*/ /opt/robot-settings && \
    ln -sf /usr/lib/x86_64-linux-gnu/OGRE-1.9.0/ /opt/pynaoqi/lib/OGRE-1.9.0 && \
    ln -sf /usr/lib/x86_64-linux-gnu/OGRE-1.9.0/ /opt/pynaoqi/lib/OGRE
    # && \
    # tar -C /opt -xvzf /opt/naoqi-sdk-*-linux64.tar.gz && \
    # unzip -d /opt /opt/ctc-linux64-atom-*.zip && \
    # # ln -sf /opt/naoqi-sdk-*-linux64 /opt/naoqi-sdk && \

RUN rm /opt/*.tar.gz

# PIP per python2 non è incluso in Ubuntu 22.04
# https://stackoverflow.com/a/64297311
RUN curl https://bootstrap.pypa.io/pip/2.7/get-pip.py -o get-pip.py && \
    python get-pip.py && cp /usr/local/bin/pip /usr/bin/pip && \
    pip install qibuild

# Create user for Choregraphe (NAO)
# Replace 1000 with your user / group id (check with `id` command)
RUN export uid=1000 gid=1000 && \
    mkdir -p /home/naouser && \
    echo "naouser:x:${uid}:${gid}:NAO User,,,:/home/naouser:/bin/bash" >> /etc/passwd && \
    echo "naouser:x:${uid}:" >> /etc/group && \
    echo "naouser   ALL = (ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    chown ${uid}:${gid} -R /home/naouser && \
    adduser naouser video

# # Step 2: create C++ toolchain
# WORKDIR /opt/naoqi-sdk
# # WARNING: at 
# # http://doc.aldebaran.com/2-1/dev/cpp/install_guide.html#d-sdk-installation
# # they say that there should be an SDK EMPTY folder... I don't believe it
# RUN qibuild init 
# # The add-config step is documented at
# # http://doc.aldebaran.com/qibuild/beginner/qibuild/aldebaran.html#for-the-desktop
# # for newer versions of qibuild
# WORKDIR /opt/naoqi-sdk/doc/dev/cpp/examples
# RUN qitoolchain create mytoolchain /opt/naoqi-sdk/toolchain.xml && \
#     qibuild add-config mytoolchain -t mytoolchain --default 
# 
# # Step 3: compile sayhelloworld example and alvisualcompass example
# # TODO: do it as unprivileged user
# WORKDIR /opt/naoqi-sdk/doc/dev/cpp/examples/core/sayhelloworld
# RUN qibuild configure && qibuild make
# 
# # Step 4: install Ubuntu OpenCV libraries and remove from NAOqi-SDK
# # as doc http://doc.aldebaran.com/2-5/dev/cpp/examples/vision/opencv.html?highlight=opencv#removing-opencv-from-the-naoqi-sdk
# # Even if we have NAOqi<2.5
# WORKDIR /opt/naoqi-sdk/
# RUN rm -rf lib/libopencv_* include/opencv2 include/opencv
# WORKDIR /opt/
# RUN wget https://sourceforge.net/projects/opencvlibrary/files/opencv-unix/2.4.9/opencv-2.4.9.zip/download -O OpenCV-2.4.9.zip
# RUN unzip OpenCV-2.4.9.zip && mkdir -p opencv-2.4.9/build
# WORKDIR /opt/opencv-2.4.9/build
# RUN cmake .. && make && make install && \
#     ls /opt/opencv-2.4.9/build/lib/libopencv_* | while read a; do ln -s $a /opt/naoqi-sdk/lib/; done
# 
# WORKDIR /opt/naoqi-sdk/doc/dev/cpp/examples/vision/alvisualcompass
# RUN qibuild configure && qibuild make

# # Become unprivileged naouser to launch choregraphe
USER naouser
ENV HOME /home/naouser
ENV PATH $PATH:/opt/choregraphe/bin/
ENV PYTHONPATH /opt/pynaoqi/lib/python2.7/site-packages
# KO: ENV LD_LIBRARY_PATH /opt/pynaoqi/lib/
# KO: Not good for Choregraph 3D (OGRE) -- ENV QI_SDK_PREFIX /opt/pynaoqi/

# environment QT_X11_NO_MITSHM needed to avoid Bad Access Permission
# ref: https://github.com/osrf/docker_images/issues/21
ENV QT_X11_NO_MITSHM 1

WORKDIR /home/naouser
CMD ["./run.sh"]

