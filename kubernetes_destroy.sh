#!/bin/bash
# Set API KEY to create kubernetes entity in CloudGuard Native Portal
if [[ -z $1 ]] ; then
	echo "Need the Cluster ID"
	exit 1
fi

if [[ ! -v CHKP_CLOUDGUARD_ID || ! -v CHKP_CLOUDGUARD_SECRET ]]; then
	echo "CloudGuard API Key not set (CHKP_CLOUDGUARD_ID and CHKP_CLOUDGUARD_SECRET)"
	exit 1
fi

# Check for jq

if ! command -v jq > /dev/null ; then
	echo "jq is not installed"
	exit 1
fi

# Set API KEY for service account to run helm command for onboarding kubernetes cluster

CLOUDGUARD_BASE_URL=https://api.dome9.com/v2
CONTENT_TYPE=Content-Type:application/json

CLUSTER_ID=$1
CLUSTER_NAME=rolo_demo_cluster

# Delete cluster from Cloudguard Portal
    
echo "Removing Cluster ID $CLUSTER_ID"
curl -s -X DELETE $CLOUDGUARD_BASE_URL/KubernetesAccount/$CLUSTER_ID --header $CONTENT_TYPE --user $CHKP_CLOUDGUARD_ID:$CHKP_CLOUDGUARD_SECRET

# THE FOLLOWING COMMANDS REQUIRE ACCESSS TO KUBERNETES CLUSTER TO DEPLOY AGENTS
helm uninstall asset-mgmt --namespace checkpoint
helm repo remove checkpoint-ea

