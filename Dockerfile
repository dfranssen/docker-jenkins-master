FROM dfranssen/docker-base
MAINTAINER Dirk Franssen "dirk.franssen@gmail.com"

RUN apt-get install -qy git zip && apt-get clean

ENV JENKINS_VERSION 1.574
ENV JENKINS_HOME /var/jenkins_home
VOLUME /var/jenkins_home

ADD http://mirrors.jenkins-ci.org/war/$JENKINS_VERSION/jenkins.war /opt/jenkins.war

ADD jenkins-plugins.txt /opt/jenkins-plugins.txt
ADD start-jenkins.sh /opt/start-jenkins.sh
RUN chmod 644 /opt/jenkins.war && chmod +x /opt/start-jenkins.sh

EXPOSE 8080 50000

ENTRYPOINT ["/opt/start-jenkins.sh"]

#todo's:
#- install maven3, or only in the slave?
#- add more relevant plugins
#- add servlet container and security?
#- don't run as root?
#- expose port to attach build slaves (docker slaves)