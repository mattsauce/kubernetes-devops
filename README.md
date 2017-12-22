# Synopsis

The code is for setting up a devops enviroment using latest Sonarqube, Nexus (or artifactory) and Jenkins on a small kubernetes cluster

YOu can either run the script to install Sonarqube, Nexus and Jenkins or pick and choose which one you want

# Steps

## Install Juju

https://jujucharms.com/docs/2.3/reference-install

## Setup Juju (only if you never used it before)
```bash
$ juju clouds
# Pick your cloud providers and add credentials
$ juju add-credential aws
$ juju bootstrap aws YOUR_CREDENTIAL_NAME
```

## Install Kubernetes with Juju
```bash
$ juju add-model mydevops YOUR_AWS_REGION
$ juju deploy kubernetes-core --constraints 'instance-type=t2.medium'
```
You can adapt to the instances of your choice
```bash
$ watch -c juju status --color - wait that everything is green
$ mkdir -p ~/.kube
$ juju scp kubernetes-master/0:config ~/.kube/config

# Query the cluster.
$ kubectl cluster-info
```
## Accessing the Kubernetes Dashboard

The Kubernetes dashboard addon is installed by default, along with Heapster,
Grafana and InfluxDB for cluster monitoring. The dashboard addons can be
enabled or disabled by setting the enable-dashboard-addons config on the
kubernetes-master application:

```bash
$ juju config kubernetes-master enable-dashboard-addons=true
```
To access the dashboard, you may establish a secure tunnel to your cluster with
the following command:

```bash
$ kubectl proxy
```
By default, this establishes a proxy running on your local machine and the
kubernetes-master unit. To reach the Kubernetes dashboard, visit
http://localhost:8001/ui

## Option 1 - Install SonarQube+Jenkins+Nexus
```bash
$ ./kubernetes-devops.sh
# Verify that the pods is up
$ kubectl get pods
# To get your Jenkins admin password
$ kubectl logs JENKINS_POD
```
## Option 2 - Install each component one by one
### Install Jenkins
```bash
# Create Jenkins deployment
$ kubectl create -f jenkins-deployment.yml
# Verify that the pod is up
$ kubectl get pods | grep jenkins
# Create Jenkins service
$ kubectl create -f jenkins-service.yml
# Check service is up
$ kubectl get svc jenkins
$ kubectl describe  svc jenkins | grep NodePort
# To get your Jenkins admin password
$ kubectl logs JENKINS_POD_NAME  | grep -B2 AdminPassword
```
Open the NodePort in the security group 
### Install SonarQube
```bash
# Create SonarQube deployment
$ kubectl create -f sonar-deployment.yml
# Verify that the pod is up
$ kubectl get pods | grep sonar
# Create SonarQube service
$ kubectl create -f sonar-service.yml
$ kubectl get svc sonar
$ kubectl describe  svc sonar | grep NodePort
```
Open the NodePort in the security group

### Install Nexus Repository Manager 3
```bash
# Create Nexus 3 deployment
$ kubectl create -f nexus3-deployment.yml
# Verify that the pod is up
$ kubectl get pods | grep nexus3
# Create Nexus 3 service
$ kubectl create -f nexus3-service.yml
$ kubectl get svc sonar
$ kubectl describe  svc nexus3 | grep NodePort
```
Open the NodePort in the security group

### Install Artifactory
The following describes the steps to do the actual deployment of the Artifactory and its services to Kubernetes.

#### Preparing Resources
Need to create some resources that will be used by Nginx as SSL and Artifactory reverse proxy configuration

#### Docker registry secret (optional)
In case you built your own Artifactory image and pushed it to your private registry, you might need to define a docker-registry secret to be used by Kubernetes to pull images
```bash
$ kubectl create secret docker-registry docker-reg-secret --docker-server=${YOUR_DOCKER_REGISTRY} --docker-username=${USER} --docker-password=${PASSWORD} --docker-email=you@domain.com
```
#### SSL secret
Create the SSL secret that will be used by the Nginx pod  
```bash
$ kubectl create secret tls art-tls --cert=${PATH_TO_CERT}/myssl.pem --key=${PATH_TO_CERT}/myssl.key
```
#### Database (using PostgreSQL)
```bash
# Create an EBS in the availability zone of your choice (note the volumeid)
$ aws ec2 create-volume --availability-zone ap-northeast-1a --size 6 --volume-type gp2
# Update postgresql-pv.yml with  your volumeid
$ kubectl apply -f postgresql-pv.yml
$ kubectl apply -f postgresql-storage.yml
$ kubectl apply -f postgresql-service.yml
```
#### Artifactory
```bash
# Create an EBS in the availability zone of your choice (note the volumeid)
$ aws ec2 create-volume --availability-zone ap-northeast-1a --size 6 --volume-type gp2
# Update artifactory-pv.yml with  your volumeid
$ kubectl apply -f artifactory-pv.yml
$ kubectl apply -f artifactory-storage.yml
$ kubectl apply -f artifactory-service.yml
```
#### Nginx
```bash
# Configuration
$ kubectl create configmap nginx-artifactory-conf --from-file=artifactory.conf
# Create an EBS in the availability zone of your choice (note the volumeid)
$ aws ec2 create-volume --availability-zone ap-northeast-1a --size 2 --volume-type gp2
# Update nginx-pv.yml with  your volumeid
$ kubectl apply -f nginx-pv.yml
$ kubectl apply -f nginx-storage.yml
$ kubectl apply -f nginx-deployment.yml
# Nginx service
$ kubectl apply -f nginx-service.yml
```

#### Final Check
```bash
# Get pods and their status
$ kubectl get pods
# Get services
$ kubectl get services
```

