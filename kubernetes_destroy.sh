#!/bin/bash
# Set API KEY to create kubernetes entity in CloudGuard Native Portal
#if [[ -z $1 ]] ; then
#	echo "Need the Cluster ID"
#	exit 1
#fi

if [[ ! -v CHKP_CLOUDGUARD_ID || ! -v CHKP_CLOUDGUARD_SECRET ]]; then
	echo "CloudGuard API Key not set (CHKP_CLOUDGUARD_ID and CHKP_CLOUDGUARD_SECRET)"
	exit 1
fi

CLOUDGUARD_BASE_URL=https://api.dome9.com/v2
CONTENT_TYPE=Content-Type:application/json


# Delete cluster from Cloudguard Portal
input="./onboarded_clusters.txt"

if [[ ! -z $1 ]]; then
	CLUSTER_ID=$1
	echo "Removing Cluster ID $CLUSTER_ID"
	curl -s -X DELETE $CLOUDGUARD_BASE_URL/KubernetesAccount/$CLUSTER_ID --header $CONTENT_TYPE --user $CHKP_CLOUDGUARD_ID:$CHKP_CLOUDGUARD_SECRET
elif [[ -s $input ]]; then
	while IFS= read -r CLUSTER_ID
	do
		echo "Removing Cluster ID $CLUSTER_ID"
		curl -s -X DELETE $CLOUDGUARD_BASE_URL/KubernetesAccount/$CLUSTER_ID --header $CONTENT_TYPE --user $CHKP_CLOUDGUARD_ID:$CHKP_CLOUDGUARD_SECRET
		sed -i "/$CLUSTER_ID/d" $input
	done < "$input"
else
	echo "CLUSTER_ID not found in onboarded_kubernetes.txt or parameter"
	exit 1
fi

if [ ! -s $input ]; then
	rm $input
fi

# THE FOLLOWING COMMANDS REQUIRE ACCESSS TO KUBERNETES CLUSTER TO DEPLOY AGENTS
helm uninstall asset-mgmt --namespace checkpoint
helm repo remove checkpoint-ea
