## Synopsis

The code is for setting up   the latest sonarqube and jenkins on a small kubernetes cluster

## Steps

# Install Kubernetes
```
juju deploy kubernetes-core --constraints 'instance-type=t2.medium'
watch -c juju status --color - wait that everything is green
mkdir -p ~/.kube
juju scp kubernetes-master/0:config ~/.kube/config
```
Query the cluster.
```
kubectl cluster-info
```
Accessing the Kubernetes Dashboard

The Kubernetes dashboard addon is installed by default, along with Heapster,
Grafana and InfluxDB for cluster monitoring. The dashboard addons can be
enabled or disabled by setting the enable-dashboard-addons config on the
kubernetes-master application:

```
juju config kubernetes-master enable-dashboard-addons=true
```
To access the dashboard, you may establish a secure tunnel to your cluster with
the following command:

```
kubectl proxy
```
By default, this establishes a proxy running on your local machine and the
kubernetes-master unit. To reach the Kubernetes dashboard, visit
http://localhost:8001/ui

# Install Jenkins
```
kubectl create -f jenkins-deployment.yml
```
Verify that the pod is up
```
kubectl get pods
kubectl create -f jenkins-service.yml
kubectl get svc jenkins
kubectl describe  svc jenkins | grep NodePort
```
Open security group on the NodePort 
# Install SonarQube
```
kubectl create -f sonar-deployment.yml
```
Verify that the pod is up
```
kubectl get pods
kubectl create -f sonar-service.yml
kubectl get svc sonar
kubectl describe  svc sonar | grep NodePort
```
Open security group on the NodePort 
