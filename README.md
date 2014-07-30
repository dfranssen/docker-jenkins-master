Builds a Jenkins master v1.574 based on the docker image `dfranssen/docker-base`.

This image includes the following Jenkins plugins:
 - build-pipeline-plugin/1.4.3
 - parameterized-trigger/2.17
 - jquery/1.7.2-1
 - dashboard-view/2.2
 - hipchat/0.1.6

'ATTENTION!` The plugins will not be available if volume is bound from another container (with --volumes-from). This means if the jenkins container will be removed (e.g. to update to a newer image), the data will also be detached as the new container will get a new reference in the host (/var/lib/docker/vfs/dir)


```Shell
docker run --name myjenkins -d -p 8080:8080 -p 50000:50000 -v /var/jenkins_home dfranssen/docker-jenkins-master
```

OR with additional JAVA_OPTS:

```Shell
docker run --name myjenkins -d -p 8080:8080 -p 50000:50000 -v /var/jenkins_home -e 'JAVA_OPTS="-Xmx=512m,-Xms=256m"' dfranssen/docker-jenkins-master
```