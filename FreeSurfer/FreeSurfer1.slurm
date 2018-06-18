#!/bin/bash
#SBATCH -p cloud
#SBATCH --ntasks=1
#SBATCH -t 00:15:00

module load FreeSurfer/5.3.0-GCC-4.9.2-centos6_x86_64

# Tutorial derived from `https://surfer.nmr.mgh.harvard.edu/fswiki/FsTutorial/GroupAnalysis`

# Export directories
export TUTORIAL_DATA=/usr/local/common/FreeSurfer
export SUBJECTS_DIR=$TUTORIAL_DATA/buckner_data/tutorial_subjs/group_analysis_tutorial

# Create contrast; test the change in thickness with age, after removing the effects of gender.
echo "0 0 0.5 0.5" > lh-Avg-thickness-age-Cor.mtx

# Assemble the precached Data (mris_preproc)

mris_preproc --fsgd $SUBJECTS_DIR/glm/gender_age.fsgd --cache-in thickness.fwhm10.fsaverage --target fsaverage  --hemi lh --out lh.gender_age.thickness.10.mgh

# Assemble the data (non-cached)
# mris_preproc --fsgd $SUBJECTS_DIR/glm/gender_age.fsgd --target fsaverage --hemi lh --meas thickness --out $SUBJECTS_DIR/glm/lh.gender_age.thickness.00.mg

# mri_surf2surf --hemi lh --s fsaverage --sval lh.gender_age.thickness.00.mgh --fwhm 10 --cortex --tval lh.gender_age.thickness.10B.mgh

mri_glmfit --y lh.gender_age.thickness.10.mgh --fsgd $SUBJECTS_DIR/glm/gender_age.fsgd dods --C $SUBJECTS_DIR/glm/lh-Avg-thickness-age-Cor.mtx --surf fsaverage lh --cortex --glmdir lh.gender_age.glmdir



