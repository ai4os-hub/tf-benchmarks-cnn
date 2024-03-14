# Dockerfile may have following Arguments: image, tag, branch, btype
# image - base docker image to use
# tag - tag for the Base image, (e.g. 1.10.0-py3 for tensorflow)
# branch - user repository branch to clone (default: master, other option: test)
# btype - becnhmark type ('benchmark', 'pro')
#
# To build the image:
# $ docker build -t <dockerhub_user>/<dockerhub_repo> --build-arg arg=value .
# or using default args:
# $ docker build -t <dockerhub_user>/<dockerhub_repo> .
#
# Be Aware! For the Jenkins CI/CD pipeline, 
# input args are defined inside the JenkinsConstants.groovy, not here!
#

#ARG image=tensorflow/tensorflow
#ARG tag=1.14.0-gpu-py3

# let's by default use NVIDIA Dockers. N.B.: they are large (ca.10GB)!
ARG image=nvcr.io/nvidia/tensorflow
ARG tag=20.06-tf2-py3

# Base image, e.g. tensorflow/tensorflow:1.14.0-py3
FROM ${image}:${tag}

LABEL maintainer='A.Grupp, V.Kozlov (KIT)'
LABEL version='0.5.0'
# tf_cnn_benchmarks packed with DEEPaaS API

# renew 'image' and 'tag' to access during the build
ARG image
ARG tag

# What user branch to clone [!]
ARG branch=main

# What benchmark type to use
ARG btype=benchmark

# Install ubuntu updates and python related stuff
# link python3 to python, pip3 to pip, if needed
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get install -y --no-install-recommends \
         git \
         curl \
         wget \
         python3-setuptools \
         python3-dev \
         python3-pip \
         python3-wheel && \ 
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /root/.cache/pip/* && \
    rm -rf /tmp/* && \
    python3 --version && \
    pip3 --version


# Set LANG environment
ENV LANG C.UTF-8

# Set the working directory
WORKDIR /srv

# Install rclone
RUN wget https://downloads.rclone.org/rclone-current-linux-amd64.deb && \
    dpkg -i rclone-current-linux-amd64.deb && \
    apt install -f && \
    mkdir /srv/.rclone/ && touch /srv/.rclone/rclone.conf && \
    rm rclone-current-linux-amd64.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /root/.cache/pip/* && \
    rm -rf /tmp/*

# Disable FLAAT authentication by default
ENV DISABLE_AUTHENTICATION_AND_ASSUME_AUTHENTICATED_USER yes

# Initialization scripts
# deep-start can install JupyterLab or VSCode if requested
RUN git clone https://github.com/ai4os/deep-start /srv/.deep-start && \
    ln -s /srv/.deep-start/deep-start.sh /usr/local/bin/deep-start

# Install user app AND 
# TF Benchmarks, offical/utils/logs scripts, apply patches (if necessary)
# pull-tf_cnn_benchmarks.sh:
# identifies TF version, installs tf_cnn_benchmarks and offical/utils/logs
ENV BENCHMARK_TYPE ${btype}
ENV DOCKER_BASE_IMAGE ${image}:${tag}
RUN git clone -b $branch https://github.com/ai4os-hub/tf-cnn-benchmarks-api && \
    cd  tf-cnn-benchmarks-api && \
# install official TF Benchmarks
    ./pull-tf_cnn_benchmarks.sh --tfbench_path=/srv/tf_cnn_benchmarks && \
    pip3 install --no-cache-dir -e . && \
    rm -rf /root/.cache/pip/* && \
    rm -rf /tmp/* && \
    cd /srv

# Add TF Benchmarks to PYTHONPATH
ENV PYTHONPATH=/srv/tf_cnn_benchmarks

# Open ports (deepaas, monitoring, ide)
EXPOSE 5000 6006 8888

# Launch deepaas
CMD ["deepaas-run", "--listen-ip", "0.0.0.0", "--listen-port", "5000"]
