#Create the deployments
kubectl create -f jenkins-deployment.yml
kubectl create -f sonar-deployment.yml
kubectl create -f nexus3-deployment.yml
# Create the services
kubectl create -f jenkins-service.yml
kubectl create -f sonar-service.yml
kubectl create -f nexus3-service.yml
# Get the ports
echo 'Jenkins port:'
kubectl describe  svc jenkins | grep NodePort:
echo 'Sonarqube port:'
kubectl describe  svc sonar | grep NodePort:
echo 'Nexus OSS port:'
kubectl describe  svc nexus3 | grep NodePort:
echo 'PLEASE DONT FORGET TO OPEN YOUR SECURITY GROUPS'
# Check pods status
kubectl get pods | grep sonar
kubectl get pods | grep nexus3
kubectl get pods | grep jenkins
echo 'If the pods are not yet running, you can check status with kubectl get pods'