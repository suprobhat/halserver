#!/bin/bash

gcloud auth activate-service-account --key-file /home/haluser/halserver.json
sudo apt-get install google-cloud-sdk-gke-gcloud-auth-plugin -y
gcloud container clusters get-credentials cluster-1 --region us-west1-a --project devopsteamrnd
kubectl get all
gcloud container clusters list

CONTEXT=$(kubectl config current-context --kubeconfig ~/.kube/cluster-1)
TOKEN=$(kubectl get secret --kubeconfig ~/.kube/cluster-1 --context $CONTEXT $(kubectl get serviceaccount spinnaker-sa --kubeconfig ~/.kube/cluster-1 --context $CONTEXT -n spinnaker -o jsonpath='{.secrets[0].name}') -n spinnaker -o jsonpath='{.data.token}' | base64 --decode)
kubectl config set-credentials $CONTEXT-token-user --kubeconfig ~/.kube/cluster-1 --token $TOKEN
kubectl config set-context $CONTEXT --kubeconfig ~/.kube/cluster-1 --user ${CONTEXT}-token-user
hal config provider kubernetes account add cluster-1 --context $CONTEXT --kubeconfig-file ~/.kube/cluster-1
hal deploy apply

