export PATH=$PATH:$PWD
export CPDCTL_ENABLE_CODE_PACKAGE=1

cpdctl config context use cpd_prod

qa_space_id=$QA_SPACE_ID
code_package_name="clustering-credit-risk-$(date +'%Y-%m-%d_%H-%M-%S')"

# Upload zip archive with python code
cpdctl asset file upload --space-id $qa_space_id --path code_package/credit-risk.zip --file code_package.zip

# Create the new code package
code_package_id=$(cpdctl code-package create --space-id $qa_space_id --file-reference code_package/credit-risk.zip --name "$code_package_name" --output json | jq -r '.asset_id')

echo "Code package ID: $code_package_id"

echo "$code_package_id" > ./code_package_id