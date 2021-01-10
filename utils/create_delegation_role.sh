
aws_profile=skillfox
region=us-east-1
env=no_clue

if ! aws --profile="$aws_profile" --region="$region" iam get-role \
        --role-name=assume_terraformer_role > /dev/null 2>&1; then
    echo "Creating terraformer delegated role in ${env}."

    # We create the Terraform delegation role
    aws iam --profile="$aws_profile" \
        --region="$region" create-role \
        --role-name assume_terraformer_role \
        --assume-role-policy-document file://"$(dirname "${0}")"/../policies/tf_role_delegation_techops.json \
        --description "Allows TechOps users to assume the Terraformer role with Administrative Access." \
        --max-session-duration "3600"
    aws iam --profile="$aws_profile" attach-role-policy \
        --policy-arn arn:aws:iam::aws:policy/AdministratorAccess \
        --role-name assume_terraformer_role
else
    echo "Terraformer delegated role in ${env} found, skipping..."
fi

