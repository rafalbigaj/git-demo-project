export PATH=$PATH:$PWD
export CPDCTL_ENABLE_CODE_PACKAGE=1

cpdctl config context use cpd_prod

prod_space_id=$PROD_SPACE_ID

# Upload zip archive with python code
cpdctl asset file upload --space-id $prod_space_id --path code_package/clustering-credit-risk.zip --file code_package.zip