# fretes  - ForgeRock on Kubernetes

Run the ForgeRock Identity Platform (OpenAM, OpenDJ, OpenIDM, OpenIG) on Kubernetes.

# Contributing 

This repository is located at https://stash.forgerock.org/projects/DOCKER/repos/fretes

Pull requests should be made on the Stash repository. You will 
need a ForgeRock community account to create pull requests.

# Prerequisites

You need to have Kubernetes installed to run these examples.  See
http://kubernetes.io

This has been tested with Kubernetes 1.5.2 on Minikube and Google Container Engine (GKE)

You will need the ForgeRock Docker images. You can build these using the
Dockerfiles in https://stash.forgerock.org/projects/DOCKER/repos/docker

# Helm

See the [helm/README.md](helm/README.md) folder to run the ForgeRock Identity Platform using Kubernetes Helm. This is the most current work - start
here.

# Using a private registry with Kubernetes

Before proceeding further please review the Kubernetes documentation on [ImagePullSecrets](http://kubernetes.io/docs/user-guide/images/#specifying-imagepullsecrets-on-a-pod)  and 
[adding ImagePullSecrets to a service account](http://kubernetes.io/docs/user-guide/service-accounts/)

A brief summary of the options:

If you are running your own custom Kubernetes cluster, and have direct control over the Docker configuration
of each node, you can use standard Docker tools to manage authentication to a private registry. For example, using .docker/config.json, and/or performing docker login on each Kubernetes minion node.

For managed and auto-scaled cloud environments such as Google Compute Engine or Amazon AWS using "kops", the manual approach does not work, as you will not have direct access to minion nodes. 

You have a couple of options for managed environments (these also work for non-managed deployments):

* Create an ImagePull Secret, and add a reference to that secret in every pod definition.
* Create an ImagePull Secret, and modify the service account to use that secret. This will result in the Kubelet adding 
the ImagePull secret automatically to each node. 

The first approach requires editing of each pod spec, which can be somewhat laborious and may make your artifacts less portable.  If you choose to use this method, it is suggested you use helm to template out the ImagePullSecret. 

The second approach does not require any modification of your deployment artifacts, but it does require that you update
the service account on your cluster (see the docs on how to this). This is the approach that I have been using for deployment on GKE. 

Note that if you are using Google's gcr.io repository for your images, you do not need to concern yourself with Image Pull Secrets - GKE clusters are configured out of the box with appropriate credentials to pull from gcr.io.

Example

```
# Create the ImagePull secret with your docker private repo credentials
kubectl create secret docker-registry frregistrykey --docker-server=docker-public.forgerock.io \
        --docker-username="my_backstage_id" \
        --docker-password="my_password" \
        --docker-email="my_email"
 
# Get the service account
kubectl get serviceaccounts default -o yaml > ./sa.yaml

# Edit sa.yaml. Delete the resourceVersion: line, and add:
imagePullSecrets:
- name: frregistrykey 

# Reload the service account:
kubectl replace serviceaccount default -f ./sa.yaml

```

The `helm/bin/registry.sh` shell script automates the above process. Review that script and edit it for your requirements.


