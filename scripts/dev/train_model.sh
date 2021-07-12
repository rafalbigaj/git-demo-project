export PATH=$PATH:$PWD

dev_space_id=$DEV_SPACE_ID
if [ -z "$dev_space_id" ]; then
  exit 0
fi

cpdctl config context use cpd

code_package_name="credit-risk-$(date +'%Y-%m-%d_%H-%M-%S')"

# Upload zip archive with python code
cpdctl asset file upload --space-id $dev_space_id --path code_package/credit-risk.zip --file code_package.zip

# Create the new code package
dev_code_package_id=$(cpdctl code-package create --space-id $dev_space_id --file-reference code_package/credit-risk.zip --name "$code_package_name" --output json | jq -r '.asset_id')

echo "Code package ID: $dev_code_package_id"

job_name="code-package-job-$(date +'%Y-%m-%d_%H-%M-%S')"

cat > job.json <<-EOJSON
{
    "name": "$job_name",
    "asset_ref": "$dev_code_package_id",
    "configuration": {
        "env_id": "jupconda37oce-0127c930-fbbb-45d2-8d3b-6e38ad66a41d",
        "env_type": "notebook",
        "entrypoint": "assets/jupyterlab/train_model.py"
    }
}
EOJSON

cat ./job.json

dev_job_id=$(cpdctl job create --space-id $dev_space_id --job '@./job.json' --output json -j  'metadata.asset_id' --raw-output)

echo "Job ID: $dev_job_id"

dev_run_id=$(cpdctl job run create --space-id $dev_space_id --job-id $dev_job_id --job-run '{}' --async --output json -j  'metadata.asset_id' --raw-output)

echo "Started job run ID: $dev_run_id..."

cpdctl job run wait --space-id $dev_space_id --job-id $dev_job_id --run-id $dev_run_id
cpdctl job run logs --space-id $dev_space_id --job-id $dev_job_id --run-id $dev_run_id > job_run.log

cat job_run.log

echo "Done!"

echo "Cleaning up..."

cpdctl job delete --space-id $dev_space_id --job-id $dev_job_id
cpdctl code-package delete --space-id $dev_space_id --code-package-id $dev_code_package_id
cpdctl asset file delete --space-id $dev_space_id --path code_package/credit-risk.zip

echo "Cleanup done"

