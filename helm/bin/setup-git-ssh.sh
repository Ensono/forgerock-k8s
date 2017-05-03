#!/usr/bin/env bash
# To run git clone from Amido's private GitHub repo, you need to create a ssh key for GitHub.
key=~/.ssh/id_rsa

kubectl create secret generic git-creds --from-file=ssh="${key}"

