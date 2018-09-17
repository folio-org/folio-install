# FOLIO in Minikube


## Local Mac install prerequisites:
	-Docker Engine for MacOS
	-Virtualbox for MacOS
	-Homebrew package manager

### Install kubectl via Homebrew:

```brew install kubernetes-cli```

### Install and update minikube via Homebrew:

```brew cask install minikube```

### Start minikube with 8GB of mem and 2 CPU cores, allow insecure registry:

minikube --cpus 2 --memory 8192 start --insecure-registry "10.0.0.0/24"
kubectl config use-context minikube

### Install Helm package manager for Kubernetes:

```brew install kubernetes-helm```

### Launch Kubernetes dashboard:

```minikube dashboard```

### Work with the docker daemon in minikube:

```eval $(minikube docker-env)```

### Add insecure registries for 192.168.99.100:5000 in OSX Docker client

### Pull and start Rancher container:

```docker run -d --restart=unless-stopped -p 80:80 -p 443:443 --name rancher-server rancher/rancher```

### Open up Rancher front-end in a web browser

https://192.168.99.100

### Set password, create new or click import existing kubernetes cluster, name it

### Build, tag and push docker images from within their respective folders:

```docker build -t 192.168.99.100:5000/project/container:v1 .```
```docker push 192.168.99.100:5000/project/container:v1```

### When spinning up containers from Dockerhub, be sure the Workload `Advanced Option - Command` "Auto Restart" setting is set to "Always"

