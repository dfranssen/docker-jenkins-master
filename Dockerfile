FROM dfranssen/docker-base
MAINTAINER Dirk Franssen "dirk.franssen@gmail.com"

RUN apt-get install -qy git zip && apt-get clean

ENV JENKINS_VERSION 1.574
ENV JENKINS_HOME /var/jenkins_home

ADD http://mirrors.jenkins-ci.org/war/$JENKINS_VERSION/jenkins.war /opt/jenkins.war

#create helper script
RUN echo "#!/bin/bash" > /opt/getJenkinsPlugin.sh && \
    echo "set -e" >> /opt/getJenkinsPlugin.sh && \
    echo "if [ ! -f $1.hpi ]" >> /opt/getJenkinsPlugin.sh && \ 
    echo "then" >> /opt/getJenkinsPlugin.sh && \ 
    echo "-----------------------" && \
    echo "Getting Jenkins Plugin: $1 version $2" && \
    echo "-----------------------" && \
    echo "wget --no-check-certificat http://updates.jenkins-ci.org/download/plugins/$1/$2/$1.hpi" >> /opt/getJenkinsPlugin.sh && \ 
    echo "fi" >> /opt/getJenkinsPlugin.sh

RUN chmod 644 /opt/jenkins.war && chmod +x /opt/getJenkinsPlugin.sh

#It is not possible to CD into that volume in the RUN instructions below
#VOLUME /var/jenkins_home

#Add plugins
RUN mkdir -p $JENKINS_HOME/plugins

RUN cd $JENKINS_HOME/plugins && \
    /opt/getJenkinsPlugin.sh build-pipeline-plugin 1.4.3 && \
    /opt/getJenkinsPlugin.sh parameterized-trigger 2.17 && \
    /opt/getJenkinsPlugin.sh jquery 1.7.2-1 && \
    /opt/getJenkinsPlugin.sh dashboard-view 2.2 && \
    /opt/getJenkinsPlugin.sh hipchat 0.1.6

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

# docker run --name myjenkins -d -p 8080:8080 -p 50000:50000 -v /var/jenkins_home dfranssen/docker-jenkins-master
# docker run --name myjenkins -d -p 8080:8080 -p 50000:50000 -v /var/jenkins_home -e 'JAVA_OPTS="-Xmx=512m,-Xms=256m"' dfranssen/docker-jenkins-master
