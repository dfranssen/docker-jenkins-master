Builds a Jenkins master v1.574 based on the image dfranssen/docker-base.

This image includes the following Jenkins plugins:
 - build-pipeline-plugin/1.4.3
 - parameterized-trigger/2.17
 - jquery/1.7.2-1
 - dashboard-view/2.2
 - hipchat/0.1.6

Best to run first a data container (in order to update a future image without loosing data)

   docker run -d --name myjenkins-data -v /var/jenkins_home busybox:ubuntu-14.04

And bind it to the jenkins container

   docker run --name myjenkins -d -p 8080:8080 -p 50000:50000 --volumes-from myjenkins-data dfranssen/docker-jenkins-master
OR docker run --name myjenkins -d -p 8080:8080 -p 50000:50000 --volumes-from myjenkins-data -e 'JAVA_OPTS="-Xmx=512m,-Xms=256m"' dfranssen/docker-jenkins-master


