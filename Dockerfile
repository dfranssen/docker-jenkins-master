FROM dfranssen/docker-base

MAINTAINER Dirk Franssen "dirk.franssen@gmail.com"

VOLUME ["/var/lib/jenkins"]

ENV JENKINS_HOME /var/lib/jenkins
ENV JENKINS_VER 1.574
ENV JENKINS_JAVA_ARGS '-Djava.awt.headless=true'
ENV JENKINS_MAXOPENFILES 8192
ENV JENKINS_PREFIX /jenkins
ENV JENKINS_ARGS '--webroot=/var/cache/jenkins/war --httpPort=8080 --ajp13Port=-1 --prefix=$JENKINS_PREFIX'
ENV TZ Europe/Brussels
ENV DEBIAN_FRONTEND noninteractive

EXPOSE 8080 2812 22 36562 33848/udp

RUN apt-get -y install \
            openssh-server \
            openjdk-7-jre-headless \
            monit \
            curl \
            git \
            subversion

ADD ./monit.d/ /etc/monit/conf.d/
ADD ./jenkins.sudoers /etc/sudoers.d/jenkins
ADD ./jenkins_init_wrapper.sh /jenkins_init_wrapper.sh
ADD ./plugins_script /plugins_script
ADD ./start.sh /start.sh
ADD ./config.xml $JENKINS_HOME/config.xml

RUN curl -s -L -o /tmp/jenkins_${JENKINS_VER}_all.deb http://pkg.jenkins-ci.org/debian/binary/jenkins_${JENKINS_VER}_all.deb && \
        dpkg -i /tmp/jenkins_${JENKINS_VER}_all.deb ; \
        apt-get -fy install

RUN /plugins_script/download_plugins.sh

ENTRYPOINT ["/bin/bash", "/start.sh"]
