#!/bin/bash
# Set API KEY to create kubernetes entity in CloudGuard Native Portal
if [[ ! -v CHKP_CLOUDGUARD_ID || ! -v CHKP_CLOUDGUARD_SECRET ]]; then
	echo "CloudGuard API Key not set (CHKP_CLOUDGUARD_ID and CHKP_CLOUDGUARD_SECRET)"
	exit 1
fi

if [[ ! -v service_account_id || ! -v service_account_secret ]]; then
	echo "CloudGuard Service Account API Key not set (service_account_id and service_account_secret)"
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

if [[ ! -z $1 ]] ; then
	CLUSTER_NAME=$1
elif [[ -v KUBERNETES_CLUSTER_NAME ]] ; then
	CLUSTER_NAME=$KUBERNETES_CLUSTER_NAME
else
	echo "No cluster name defined, set KUBERNETES_CLUSTER_NAME or parameter"
	exit 1
fi

    # Create Kubernetes Cluster entity in Portal
CREATION_RESPONSE=$(curl -s -X POST $CLOUDGUARD_BASE_URL/KubernetesAccount --header $CONTENT_TYPE --header 'Accept: application/json' -d "{\"name\" : \"$CLUSTER_NAME\"}" --user $CHKP_CLOUDGUARD_ID:$CHKP_CLOUDGUARD_SECRET)
    
    # Pull cluster ID information
if CLUSTER_ID=$(echo $CREATION_RESPONSE | jq -r '.id' 2>/dev/null) ; then
	echo "ClusterID  = $CLUSTER_ID"	    
	echo $CLUSTER_ID >> onboarded_clusters.txt
    # Enable Runtime Protection
	curl -X POST $CLOUDGUARD_BASE_URL/KubernetesAccount/runtime-protection/enable --header $CONTENT_TYPE --user $CHKP_CLOUDGUARD_ID:$CHKP_CLOUDGUARD_SECRET --data "{\"k8sAccountId\" : \"$CLUSTER_ID\", \"enabled\" : true}"
    # Enable Admission Controller

	curl -X POST $CLOUDGUARD_BASE_URL/KubernetesAccount/admission-control/enable --header $CONTENT_TYPE --user $CHKP_CLOUDGUARD_ID:$CHKP_CLOUDGUARD_SECRET --data "{\"k8sAccountId\" : \"$CLUSTER_ID\", \"enabled\" : true}"
    # Enable Log.ic

	curl -X POST $CLOUDGUARD_BASE_URL/KubernetesAccount/magellan-kubernetes-flowlogs/enable --header $CONTENT_TYPE --user $CHKP_CLOUDGUARD_ID:$CHKP_CLOUDGUARD_SECRET --data "{\"k8sAccountId\" : \"$CLUSTER_ID\", \"enabled\" : true}" >/dev/null

    # Enable Image Assurance
	curl -X POST $CLOUDGUARD_BASE_URL/KubernetesAccount/vulnerabilityAssessment/enable --header $CONTENT_TYPE --user $CHKP_CLOUDGUARD_ID:$CHKP_CLOUDGUARD_SECRET --data "{\"cloudAccountId\" : \"$CLUSTER_ID\", \"enabled\" : true}"
else
	echo "Cluster already exists"
	exit 1
fi

# THE FOLLOWING COMMANDS REQUIRE ACCESSS TO KUBERNETES CLUSTER TO DEPLOY AGENTS

helm install asset-mgmt cloudguard --repo https://raw.githubusercontent.com/CheckPointSW/charts/master/repository/ --set credentials.user=$service_account_id --set credentials.secret=$service_account_secret --set clusterID=$CLUSTER_ID --set addons.flowLogs.enabled=true --set addons.imageScan.enabled=true --set addons.admissionControl.enabled=true --set addons.runtimeProtection.enabled=true --namespace checkpoint --create-namespace
