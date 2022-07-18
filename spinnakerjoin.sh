#!/bin/bash

gcloud auth activate-service-account --key-file /home/haluser/halserver.json
sudo apt-get install google-cloud-sdk-gke-gcloud-auth-plugin -y
gcloud container clusters get-credentials cluster-1 --region us-west1-a --project devopsteamrnd
kubectl get all
kubectl create ns spinnaker
kubectl get ns
kubectl create sa spinnaker-sa -n spinnaker
gcloud container clusters list
kubectl get sa -A
CONTEXT=$(kubectl config current-context)
echo $CONTEXT
TOKEN=$(kubectl get secret --context $CONTEXT $(kubectl get serviceaccount spinnaker-sa --context $CONTEXT -n spinnaker -o jsonpath='{.secrets[0].name}') -n spinnaker -o jsonpath='{.data.token}' | base64 --decode)
echo $TOKEN
kubectl config set-credentials $CONTEXT-token-user --token $TOKEN   
kubectl config set-context $CONTEXT --user $CONTEXT-token-user
hal config provider kubernetes account add spinnaker-sa --context $CONTEXT 
sudo snap install helm --classic -y
helm repo add stable https://charts.helm.sh/stable 
helm repo update 
helm install minio --namespace spinnaker stable/minio --set accessKey="myaccesskey" --set secretKey="mysecretkey" --values ./values.yaml
hal config storage s3 edit --endpoint http://minio:9000 --access-key-id "myaccesskey" --secret-access-key "mysecretkey"
mkdir ~/.hal/default/profiles/ 
echo 'spinnaker.s3.versioning: false' > ~/.hal/default/profiles/front50-local.yml
hal config features edit --artifacts true 
hal config deploy edit --type distributed --account-name spinnaker-sa
hal config storage s3 edit --path-style-access true 
hal config storage edit --type s3 
hal deploy apply




