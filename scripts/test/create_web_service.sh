export PATH=$PATH:$PWD

if [ -z "$dev_space_id" ]; then
  sleep 8
  exit 0
fi

cpdctl config context use cpd

model_name="credit-risk-model"

# Upload zip archive with python code
dev_model_id=$(cpdctl asset search --space-id $dev_space_id --query "asset.name:'$model_name'" --type-name wml_model --output json | jq -r '.results[0].metadata.asset_id')

asset=\"{"asset_id": "$dev_model_id"}\"

# Create the new web service
dev_deployment_id=$(cpdctl ml deployment create --space-id $dev_space_id --asset '$asset' --online '{}' --output json | jq -r '.metadata.deployment_id')

echo "Deployment ID: $dev_deployment_id"

echo "Done!"
