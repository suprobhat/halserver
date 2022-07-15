#!/bin/bash

gcloud auth activate-service-account --key-file /home/haluser/halserver.json
gcloud components install gke-gcloud-auth-plugin
gcloud container clusters get-credentials cluster-1 --region us-west1-a --project devopsteamrnd
kubectl get all

