All our experiments were held using docker containers. Built image of the container we used can be downloaded using

$ sudo docker pull narekvslife/occupancyanticipation_cu101:02122021

The Dockerfile (as well as all the other code) out of which this image was build is available on the Github page of our project: https://github.com/narekvslife/OccupancyAnticipation/tree/eccv_2020_eval.

This image contains the dataset, the built and compiled habitat environment, and eveything necessary for reproducing the experiments


To run and enter the container make sure you have a machine with CUDA gpu avalible (and ~20GB hard disk space), and execute the following command

$ docker run -it --gpus=all narekvslife/occupancyanticipation_cu101:23122021

Then after being inside of the container run the following command 

$ /root/miniconda3/envs/env/bin/pip install torch-scatter==1.3.2

so that torch-scatter installs specifially for your GPU

then run: 

$ git pull

and then

$ /root/miniconda3/envs/env/bin/python -u run.py --exp-config $OCCANT_ROOT_DIR/configs/model_configs/occant_rgb/ppo_navigation_evaluate.yaml --run-type eval

to run the experiment with no noise and defalut settings on 994 scenes.

1. To change the model type: choose between ['resnet18', 'resnet152', 'fpn'] and change the value of 'resnet_type' setting in the /configs/model_configs/occant_rgb/ppo_navigation_evaluate.yaml file

2. To change the test episode count: set TEST_EPISODE_COUNT in the same file to the desired value

3. To change the noise type, in the OccupancyAnticipation/configs/navigation/gibson_evaluate_noise_free_1000.yaml file:

If you want gaussian noise, then under the RGB_SENSOR setting add:
 NOISE_MODEL: "GaussianNoiseModel"
 NOISE_MODEL_KWARGS:
     intensity_constant: 0.2

If you want to reduce FOV, then under the RGB_SENSOR setting add:
 NOISE_MODEL: "NarrowFOVNoiseModel"
 NOISE_MODEL_KWARGS:
     percentage_crop: 0.2

If you want to imitate the crack of the camera, then under the RGB_SENSOR setting add:
 NOISE_MODEL: "CrackNoiseModel"

And use the same command to launch the experiment.

If something doesn't work - then please contact narek.alvandian@epfl.ch
