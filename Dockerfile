FROM dfranssen/docker-base
MAINTAINER Dirk Franssen "dirk.franssen@gmail.com"

RUN apt-get install -qy git zip && apt-get clean

ENV JENKINS_VERSION 1.574
ENV JENKINS_HOME /var/jenkins_home


ADD http://mirrors.jenkins-ci.org/war/$JENKINS_VERSION/jenkins.war /opt/jenkins.war
RUN mkdir -p $JENKINS_HOME/plugins
RUN chmod 644 /opt/jenkins.war

#Add plugins
RUN (cd $JENKINS_HOME/plugins && wget --no-check-certificat http://updates.jenkins-ci.org/download/plugins/build-pipeline-plugin/1.4.3/build-pipeline-plugin.hpi)
#RUN (cd $JENKINS_HOME/plugins && wget --no-check-certificat http://updates.jenkins-ci.org/download/plugins/parameterized-trigger/2.17/parameterized-trigger.hpi)
#RUN (cd $JENKINS_HOME/plugins && wget --no-check-certificat http://updates.jenkins-ci.org/download/plugins/jquery/1.7.2-1/jquery.hpi)
#RUN (cd $JENKINS_HOME/plugins && wget --no-check-certificat http://updates.jenkins-ci.org/download/plugins/dashboard-view/2.2/dashboard-view.hpi)

#bootstrap slave agents on jnlp port 50000
#ADD init.groovy /tmp/WEB-INF/init.groovy
#RUN cd /tmp && zip -g /opt/jenkins.war WEB-INF/init.groovy

EXPOSE 8080 50000

CMD ["$JAVA_OPTS"]
ENTRYPOINT ["java", "-jar", "/opt/jenkins.war"]

#todo's:
#- install maven3, or only in the slave
#- add relevant plugins
#- add servlet container and security
#- don't run as root
#- expose port to attach build slaves (docker slaves)
#- volume container instead

# docker run --name myjenkins -p 8080:8080 -p 50000:50000 -v /var/jenkins_home dfranssen/docker-jenkins-master
# docker run --name myjenkins -p 8080:8080 -p 50000:50000 -v /var/jenkins_home -e 'JAVA_OPTS="-Xmx=512m,-Xms=256m"' dfranssen/docker-jenkins-master
