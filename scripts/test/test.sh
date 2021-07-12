export PATH=$PATH:$PWD
export CPDCTL_ENABLE_CODE_PACKAGE=1

cpdctl config context use cpd_prod

qa_space_id=$QA_SPACE_ID
qa_code_package_id=$(<./code_package_id)
job_name="clustering-code-package-job-$(date +'%Y-%m-%d_%H-%M-%S')"

cat > job.json <<-EOJSON
{
    "name": "$job_name",
    "asset_ref": "$qa_code_package_id",
    "configuration": {
        "env_id": "jupconda37oce-0127c930-fbbb-45d2-8d3b-6e38ad66a41d",
        "env_type": "notebook",
        "entrypoint": "assets/jupyterlab/select.py"
    }
}
EOJSON

cat ./job.json

qa_job_id=$(cpdctl job create --space-id $qa_space_id --job '@./job.json' --output json -j  'metadata.asset_id' --raw-output)

echo "Job ID: $qa_job_id"

qa_run_id=$(cpdctl job run create --space-id $qa_space_id --job-id $qa_job_id --job-run '{}' --async --output json -j  'metadata.asset_id' --raw-output)

echo "Started job run ID: $qa_run_id..."

cpdctl job run wait --space-id $qa_space_id --job-id $qa_job_id --run-id $qa_run_id
cpdctl job run logs --space-id $qa_space_id --job-id $qa_job_id --run-id $qa_run_id > job_run.log

cat job_run.log
cat job_run.log | grep "The winner is" |  sed "s/.*'\([^']*\)'.*/\1/" > ./selected_algorithm

echo "Storing winning algorithm information in the code package..."
zip -u code_package.zip ./selected_algorithm

echo "Done!"

echo "Cleaning up..."

cpdctl job delete --space-id $qa_space_id --job-id $qa_job_id
cpdctl code-package delete --space-id $qa_space_id --code-package-id $qa_code_package_id

echo "Cleanup done"

