# cloudguard-k8s-automation

These scripts will onboard and remove a kubernetes cluster from CloudGuard Native Portal.  If kube config for cluster is set up on host then it will also run helm chart to deploy agents.  The clusterId will be stored into a file for use with *kubernetes_destroy.sh*.

## Requirements

The following Environment variables should be set:

``` bash
# CloudGuard API Keys with permissions to create k8sAccount entity
export CHKP_CLOUDGUARD_ID=
export CHKP_CLOUDGUARD_SECRET=

# CloudGuard API Keys with authentication permissions for helm chart
export service_account_id=
export service_account_secret=

#This value can also be introduced as an argument on the CLI
export KUBERNETES_CLUSTER_NAME=
```
