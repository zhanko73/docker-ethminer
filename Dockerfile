FROM nvidia/cuda:11.2.0-runtime-ubuntu20.04

MAINTAINER Zoltan Hanko

WORKDIR /

# Package and dependency setup
RUN apt-get update \
    && apt-get -y install software-properties-common \
    && apt-get update \
    && apt-get install -y git cmake build-essential

# Git repo set up
RUN git clone https://github.com/ethereum-mining/ethminer.git; \
    cd ethminer; \
    git submodule update --init --recursive; \
    git checkout tags/v0.19.0

# Build. Use all cores.
#RUN cd ethminer; \
#    mkdir build; \
#    cd build; \
#    cmake .. -DETHASHCUDA=ON -DAPICORE=ON -DETHASHCL=OFF -DBINKERN=OFF; \
#    cmake --build . -- -j; \
#    make install;

# Miner API port inside container
ENV ETHMINER_API_PORT=3000
EXPOSE ${ETHMINER_API_PORT}

# Prevent GPU overheading by stopping in 80C and starting again in 50C
ENV GPU_TEMP_STOP=85
ENV GPU_TEMP_START=50

# Start miner. Note that wallet address and worker name need to be set
# in the container launch.
#CMD ["bash", "-c", "/usr/local/bin/ethminer -U --api-port ${ETHMINER_API_PORT} \
#--HWMON 2 --tstart ${GPU_TEMP_START} --tstop ${GPU_TEMP_STOP} --exit \
#--report-hashrate --failover-timeout 5 -P \
#-P stratums1+tls12://$ETH_WALLET.$WORKER_NAME@eu1.whalesburg.com:6666 \
#-P stratums1+tls12://$ETH_WALLET.$WORKER_NAME@eu2.whalesburg.com:6666"]

# Env setup
ENV GPU_FORCE_64BIT_PTR=0
ENV GPU_MAX_HEAP_SIZE=100
ENV GPU_USE_SYNC_OBJECTS=1
ENV GPU_MAX_ALLOC_PERCENT=100
ENV GPU_SINGLE_ALLOC_PERCENT=100

# ENTRYPOINT ["/usr/local/bin/ethminer", "-U"]
ENTRYPOINT ["/usr/bin/bash"]
