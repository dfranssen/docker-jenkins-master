FROM dfranssen/docker-base
MAINTAINER Dirk Franssen "dirk.franssen@gmail.com"

RUN apt-get install -qy git zip && apt-get clean

ENV JENKINS_VERSION 1.574
ENV JENKINS_HOME /var/jenkins_home

ADD http://mirrors.jenkins-ci.org/war/$JENKINS_VERSION/jenkins.war /opt/jenkins.war

RUN mkdir -p $JENKINS_HOME/plugins

#create helper script
RUN echo "#!/bin/bash" > $JENKINS_HOME/getJenkinsPlugin.sh && \
    echo "set -e" >> $JENKINS_HOME/getJenkinsPlugin.sh && \
    echo "if [ ! -f $1.hpi ]" >> $JENKINS_HOME/getJenkinsPlugin.sh && \ 
    echo "then" >> $JENKINS_HOME/getJenkinsPlugin.sh && \ 
    echo "-----------------------" >> $JENKINS_HOME/getJenkinsPlugin.sh && \
    echo "Getting Jenkins Plugin: $1 version $2" >> $JENKINS_HOME/getJenkinsPlugin.sh && \
    echo "-----------------------" >> $JENKINS_HOME/getJenkinsPlugin.sh && \
    echo "wget --no-check-certificat http://updates.jenkins-ci.org/download/plugins/$1/$2/$1.hpi" >> $JENKINS_HOME/getJenkinsPlugin.sh && \
    echo "fi" >> $JENKINS_HOME/getJenkinsPlugin.sh && \

RUN chmod 644 /opt/jenkins.war && chmod +x $JENKINS_HOME/getJenkinsPlugin.sh

#It is not possible to CD into that volume in the RUN instructions below
#VOLUME /var/jenkins_home

#Add plugins
WORKDIR $JENKINS_HOME/plugins
#RUN ["../getJenkinsPlugin.sh", "build-pipeline-plugin", "1.4.3"]
#RUN ["../getJenkinsPlugin.sh", "parameterized-trigger", "2.17"]
#RUN ["../getJenkinsPlugin.sh", "jquery", "1.7.2-1"]
#RUN ["../getJenkinsPlugin.sh", "dashboard-view", "2.2"]
#RUN ["../getJenkinsPlugin.sh", "hipchat", "0.1.6"]

EXPOSE 8080 50000

CMD ["$JAVA_OPTS"]
ENTRYPOINT ["java", "-jar", "/opt/jenkins.war"]

#todo's:
#- install maven3, or only in the slave
#- add relevant plugins
#- add servlet container and security
#- don't run as root
#- expose port to attach build slaves (docker slaves)
#- volume container, otherwise persistent volume will be gone if jenkins container is removed (e.g. image update)

# docker run -d --name myjenkins-data -v /var/jenkins_home busybox:ubuntu-14.04
# docker run --name myjenkins -d -p 8080:8080 -p 50000:50000 --volumes-from myjenkins-data dfranssen/docker-jenkins-master
# OR docker run --name myjenkins -d -p 8080:8080 -p 50000:50000 --volumes-from myjenkins-data -e 'JAVA_OPTS="-Xmx=512m,-Xms=256m"' dfranssen/docker-jenkins-master

