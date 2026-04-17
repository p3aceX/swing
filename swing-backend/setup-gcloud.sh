#!/bin/bash
set -e

gcloud projects add-iam-policy-binding project-0e62f040-2f77-4498-abd --member="serviceAccount:1007730655118@cloudbuild.gserviceaccount.com" --role="roles/run.admin"

gcloud iam service-accounts add-iam-policy-binding 1007730655118-compute@developer.gserviceaccount.com --member="serviceAccount:1007730655118@cloudbuild.gserviceaccount.com" --role="roles/iam.serviceAccountUser"

echo "Done! Permissions granted."
