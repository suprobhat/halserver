#!/bin/bash

gcloud auth activate-service-account --key-file /home/haluser/halserver.json
sudo apt-get install google-cloud-sdk-gke-gcloud-auth-plugin -y
gcloud container clusters get-credentials cluster-1 --region us-west1-a --project devopsteamrnd
kubectl get all
kubectl create ns spinnaker
kubectl get ns
gcloud container clusters list

CONTEXT=$(kubectl config current-context)
echo $CONTEXT
TOKEN=$(kubectl get secret --context $CONTEXT \
   $(kubectl get serviceaccount my-k8s-account \
       --context $CONTEXT \
       -n spinnaker \
       -o jsonpath='{.secrets[0].name}') \
   -n spinnaker \
   -o jsonpath='{.data.token}' | base64 --decode)
kubectl config set-credentials $CONTEXT-token-user --token $TOKEN   
kubectl config set-context $CONTEXT --user $CONTEXT-token-user
hal config provider kubernetes account add my-k8s-account --context $CONTEXT 
hal config features edit --artifacts true 
hal config deploy edit --type distributed --account-name my-k8s-account 
hal config provider kubernetes account add gke_devopsteamrnd_us-west1-a_cluster-1 --context $CONTEXT --kubeconfig-file ~/.kube/gke_devopsteamrnd_us-west1-a_cluster-1
hal deploy apply
kubectl get all -n spinnaker

