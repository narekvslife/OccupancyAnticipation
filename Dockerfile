FROM nvidia/cudagl:10.1-devel-ubuntu18.04
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
 && apt-get install --no-install-recommends -y \
                    build-essential \
                    ca-certificates \
                    wget \
                    curl \
                    unzip \
                    git \
                    ssh \
                    sudo \
                    vim

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

ENV PATH="/root/miniconda3/bin:${PATH}"
ARG PATH="/root/miniconda3/bin:${PATH}"
RUN rm -rf /var/lib/apt/lists/*

RUN wget \
    https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && mkdir /root/.conda \
    && bash Miniconda3-latest-Linux-x86_64.sh -b \
    && rm -f Miniconda3-latest-Linux-x86_64.sh
RUN conda create --name env python=3.7
RUN conda config --add channels conda-forge

RUN git clone https://github.com/narekvslife/OccupancyAnticipation.git
WORKDIR /OccupancyAnticipation
ENV OCCANT_ROOT_DIR=/OccupancyAnticipation
RUN git submodule init
RUN git submodule update
# SETTING UP HABITAT_LAB
WORKDIR $OCCANT_ROOT_DIR/environments/habitat/habitat-api
RUN git checkout 27483d017210cf710a50ba8061948eab58777202
RUN /root/miniconda3/envs/env/bin/pip install numpy==1.20.0 gym==0.10.9 

RUN /root/miniconda3/envs/env/bin/python setup.py develop --all
RUN pip install cmake  # 
RUN sudo apt-get update || true #
RUN sudo apt-get install -yq \
          ca-certificates \
          build-essential \
          pkg-config \
          zip \
          unzip || true

WORKDIR $OCCANT_ROOT_DIR/environments/habitat/habitat-sim
RUN git checkout 2689aee121ae8123c3072af820f4c5333df487c2
RUN /root/miniconda3/envs/env/bin/python setup.py install --headless --with-cuda
WORKDIR $OCCANT_ROOT_DIR/occant_utils/astar_pycpp
RUN git checkout 3a44fcc48fd7f559bae6422c0bf77883b672247b
RUN make
WORKDIR $OCCANT_ROOT_DIR
RUN /root/miniconda3/envs/env/bin/pip install torch==1.2.0  # later will rebuild to 1.4.0
RUN /root/miniconda3/envs/env/bin/pip install -r requirements.txt
WORKDIR $OCCANT_ROOT_DIR
RUN ln -s environments/habitat/habitat-api/data data
WORKDIR $OCCANT_ROOT_DIR/data/scene_datasets
RUN wget -O gibson.zip https://dl.fbaipublicfiles.com/habitat/data/scene_datasets/gibson_habitat.zip
RUN unzip gibson.zip && rm gibson.zip
#WORKDIR $OCCANT_ROOT_DIR/data/datasets
#RUN mkdir -p pointnav/gibson
WORKDIR $OCCANT_ROOT_DIR/data/datasets/pointnav
RUN wget https://github.com/facebookresearch/habitat-lab/blob/main/configs/datasets/pointnav/gibson.yaml
WORKDIR gibson/v1
RUN wget -O v1.zip https://dl.fbaipublicfiles.com/habitat/data/datasets/pointnav/gibson/v1/pointnav_gibson_v1.zip
RUN unzip v1.zip && rm v1.zip
WORKDIR $OCCANT_ROOT_DIR
RUN find data/
RUN git checkout eccv_2020_eval
RUN mkdir -p $OCCANT_ROOT_DIR/trained_models/occant_rgb/run_00/checkpoints/
RUN wget -O $OCCANT_ROOT_DIR/trained_models/occant_rgb/run_00/checkpoints/ckpt.8.pth  https://dl.fbaipublicfiles.com/OccupancyAnticipation/pretrained_models_eccv_2020/pretrained_models/occant_rgb/ckpt.8.pth
RUN mkdir -p $OCCANT_ROOT_DIR/configs/model_configs/occant_rgb/
RUN wget -O $OCCANT_ROOT_DIR/configs/model_configs/occant_rgb/ppo_navigation_evaluate.yaml https://dl.fbaipublicfiles.com/OccupancyAnticipation/pretrained_models_eccv_2020/pretrained_models/occant_rgb/ppo_navigation_evaluate.yaml
WORKDIR $OCCANT_ROOT_DIR
RUN /root/miniconda3/envs/env/bin/pip install future  # fixing no module found: past
RUN /root/miniconda3/envs/env/bin/pip install environments/habitat/habitat-sim/build/deps/magnum-bindings/src/python # Force magnum reinstall
RUN mkdir -p trained_models/occant_rgb/run_00/navigation_eval_noise_free_tb

# this is just dancing aroung to make torch and cuda dependencies work
RUN /root/miniconda3/envs/env/bin/pip uninstall torch torch-scatter 
RUN /root/miniconda3/envs/env/bin/pip install --pre --force-reinstall --no-cache torch torchvision -f https://download.pytorch.org/whl/nightly/cu102/torch_nightly.html
RUN /root/miniconda3/envs/env/bin/pip install numpy==1.20.0
RUN /root/miniconda3/envs/env/bin/pip install --force-reinstall --no-cache torch-scatter==1.3.1
