#!/bin/bash

gcloud auth activate-service-account --key-file /home/haluser/halserver.json
sudo apt-get install google-cloud-sdk-gke-gcloud-auth-plugin -y
gcloud container clusters get-credentials cluster-1 --region us-west1-a --project devopsteamrnd
kubectl get all
kubectl get ns
gcloud container clusters list
kubectl config get-contexts
kubectl config use-context gke_devopsteamrnd_us-west1-a_cluster-1
kubectl config set-cluster gke_devopsteamrnd_us-west1-a_cluster-1
kubectl config get-contexts
kubectl get all
kubectl create ns spinnaker
kubectl create sa spinnaker-sa -n spinnaker
CONTEXT=$(kubectl config current-context)
echo $CONTEXT
TOKEN=$(kubectl get secret --context $CONTEXT $(kubectl get serviceaccount spinnaker-sa --context $CONTEXT -n spinnaker -o jsonpath='{.secrets[0].name}') -n spinnaker -o jsonpath='{.data.token}' | base64 --decode)
echo $TOKEN
kubectl config set-credentials $CONTEXT-token-user --token $TOKEN   
kubectl config set-context $CONTEXT --user $CONTEXT-token-user
hal config provider kubernetes enable 
CONTEXT=$(kubectl config current-context) 
hal config provider kubernetes account add spinnaker-sa --context $CONTEXT 
#sudo mkdir -p ~/.hal/default/profiles/
#chmod -R 777 ~/.hal/default/profiles/
#echo 'spinnaker.s3.versioning: false' > ~/.hal/default/profiles/front50-local.yml
kubectl get ns
hal config features edit --artifacts true
sudo snap install helm --classic -y
helm repo add stable https://charts.helm.sh/stable 
helm repo update 
helm upgrade minio --namespace spinnaker stable/minio --set accessKey="myaccesskey" --set secretKey="mysecretkey" -f /home/haluser/values.yaml
hal config storage s3 edit --endpoint http://minio:9000 --access-key-id "myaccesskey" --secret-access-key "mysecretkey"
hal config deploy edit --type distributed --account-name spinnaker-sa
hal config storage s3 edit --path-style-access true 
hal config storage edit --type s3 
hal config version edit --version 1.26.6 
hal deploy apply
kubectl get all -n spinnaker




