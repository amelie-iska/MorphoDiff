#!/bin/bash
#SBATCH --gpus-per-node=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=64G
#SBATCH --time=4:00:00
#SBATCH --job-name=gen_img
#SBATCH --error=out_dir/%x-%j.err
#SBATCH --output=out_dir/%x-%j.out
#SBATCH --open-mode=append
#SBATCH --signal=B:USR1@60

handler()
{
echo "function handler called at $(date)"
scontrol requeue $SLURM_JOB_ID
}
trap 'handler' SIGUSR1


## Load the environment
# source /home/env/morphodiff/bin/activate

## Define/adjust the parameters
EXPERIMENT="BBBC021-experiment-01-resized"
# you can download pretrained checkpoints from https://huggingface.co/navidi/MorphoDiff_checkpoints/tree/main
CKPT_PATH="/model/BBBC021-MorphoDiff/checkpoint-0"
# For VAE, you can set path to the downloaded stable-diffusion-v1-4, or one of the pretrained chekcpoints
VAE_PATH="/stable-diffusion-v1-4/"
# Set path to the directory where you want to save the generated images
GEN_IMG_PATH="/datasets/${EXPERIMENT}/generated_imgs/"
# Set the number of images you want to generate
NUM_GEN_IMG=500
# Set the out-of-distribution (OOD) status of the generated images
OOD=False
MODEL_NAME="SD" # this is fixed
MODEL_TYPE="conditional" # set "conditional" for MorphoDiff, and "naive" for unconditional SD

# this PERTURBATION_LIST_PATH should be address of a .csv file with the following columns: perturbation, ood (including header)
# sample file can be found in morphodiff/required_file/BBBC021_experiment_pert_ood_info.csv
PERTURBATION_LIST_PATH="${EXPERIMENT}_pert_ood_info.csv" 


## Generate images
python evaluation/generate_img.py \
--experiment $EXPERIMENT \
--model_checkpoint $CKPT_PATH \
--model_name $MODEL_NAME \
--model_type $MODEL_TYPE \
--vae_path $VAE_PATH \
--perturbation_list_address $PERTURBATION_LIST_PATH \
--gen_img_path $GEN_IMG_PATH \
--num_imgs $NUM_GEN_IMG \
--ood $OOD # & 


## uncomment the blow lines (and the "&"" in the last line of calling the python script above) 
## if you want your script reallocates resources and resume generating images 
## for all perturbations even after the allocated time is over

# wait
# echo 'waking up'
# echo `date`: Job $SLURM_JOB_ID is allocated resource
