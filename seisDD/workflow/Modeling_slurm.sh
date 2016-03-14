#!/bin/bash
#SBATCH --error=job_info/error
#SBATCH --output=job_info/output


ulimit -s unlimited

cd $SLURM_SUBMIT_DIR

echo "$SLURM_JOB_NODELIST"  >  ./job_info/NodeList
echo "$SLURM_JOB_ID"  >  ./job_info/JobID
export user=$(whoami)

#################### input parameters ###################################################
source parameter

# directories
export SUBMIT_DIR=$SLURM_SUBMIT_DIR
export SCRIPTS_DIR="$package_path/scripts"
export WORKING_DIR="$SLURM_SUBMIT_DIR/$Job_title/specfem/"  # directory on local nodes, where specfem runs
export DISK_DIR="$SLURM_SUBMIT_DIR/$Job_title/output/"      # temporary directory for data/model/gradient ...
export SUBMIT_RESULT="$SLURM_SUBMIT_DIR/RESULTS/Modeling/Scale${Wscale}_${measurement_list}_${misfit_type_list}"     # final results

echo 
echo "Submit job << $Job_title >> in : $SUBMIT_DIR  "
echo "Working directory: $WORKING_DIR"
echo "FINAL results in :  $SUBMIT_RESULT"
echo 

#########################################################################################


echo
STARTTIME=$(date +%s)
echo "start time is :  $(date +"%T")"

rm -rf $WORKING_DIR
mkdir -p $WORKING_DIR

if $ReStart; then
echo
echo "Re-Starting job ..." 
echo "Clean up result/DISK directories ..."
rm -rf $SUBMIT_RESULT $DISK_DIR
mkdir -p $SUBMIT_RESULT $DISK_DIR
else
echo
echo "Continue with current job ..."
fi 

echo 
echo "prepare data ..."
velocity_dir=$target_velocity_dir
srun -n $ntasks -c $NPROC_SPECFEM -l -W 0 $SCRIPTS_DIR/prepare_data.sh $velocity_dir 2> ./job_info/error_target

## SAVE
cp -r $SUBMIT_DIR/job_info/output $SUBMIT_RESULT/
cp -r $SUBMIT_DIR/parameter $SUBMIT_RESULT/

echo
echo " clean up local nodes (wait) ...... "
#rm -rf $WORKING_DIR


ENDTIME=$(date +%s)
Ttaken=$(($ENDTIME - $STARTTIME))
echo
echo "finish time is : $(date +"%T")" 
echo "RUNTIME is :  $(($Ttaken / 3600)) hours ::  $(($(($Ttaken%3600))/60)) minutes  :: $(($Ttaken % 60)) seconds."

echo
echo "******************well done*******************************"

