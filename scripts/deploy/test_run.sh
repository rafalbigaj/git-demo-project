export PATH=$PATH:$PWD
export CPDCTL_ENABLE_CODE_PACKAGE=1

cpdctl config context use cpd_prod

prod_space_id=$PROD_SPACE_ID
prod_job_id=$PROD_JOB_ID

# Trigger job run
cpdctl job run create --space-id $prod_space_id --job-id $prod_job_id --job-run '{}'