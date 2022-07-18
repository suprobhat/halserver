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
hal config features edit --artifacts true 
hal config deploy edit --type distributed --account-name spinnaker-sa
hal config storage s3 edit --path-style-access true 
hal config storage edit --type s3 
hal deploy apply




