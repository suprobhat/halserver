#!/bin/bash

gcloud auth activate-service-account --key-file /home/haluser/halserver.json
sudo apt-get install google-cloud-sdk-gke-gcloud-auth-plugin -y
gcloud container clusters get-credentials cluster-1 --zone us-west1-a --project devopsteamrnd
kubectl get all
kubectl get ns
gcloud container clusters list
kubectl config get-contexts
kubectl get all
kubectl create ns spinnaker
kubectl create sa spinnaker-sa2 -n spinnaker
CONTEXT=$(kubectl config current-context)
echo $CONTEXT
TOKEN=$(kubectl get secret --context $CONTEXT $(kubectl get serviceaccount spinnaker-sa2 --context $CONTEXT -n spinnaker -o jsonpath='{.secrets[0].name}') -n spinnaker -o jsonpath='{.data.token}' | base64 --decode)
echo $TOKEN
kubectl config set-credentials $CONTEXT-token-user --token $TOKEN   
kubectl config set-context $CONTEXT --user $CONTEXT-token-user
hal config provider kubernetes account add spinnaker-sa2 --context $CONTEXT 
hal deploy apply





