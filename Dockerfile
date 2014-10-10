FROM dfranssen/docker-base

MAINTAINER Dirk Franssen "dirk.franssen@gmail.com"

ENV MAVEN_VERSION 3.2.2
ENV JENKINS_VER 1.583
ENV DOCKER_VERSION 1.2.0

ENV DOCKER_HOST UNKNOWN

# Maven related
# -------------
ENV MAVEN_ROOT /var/lib/maven
ENV MAVEN_HOME $MAVEN_ROOT/apache-maven-$MAVEN_VERSION
ENV MAVEN_OPTS -Xms256m -Xmx512m

RUN wget --no-verbose -O /tmp/apache-maven-$MAVEN_VERSION.tar.gz \
    http://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz && \
    echo "87e5cc81bc4ab9b83986b3e77e6b3095  /tmp/apache-maven-$MAVEN_VERSION.tar.gz" | md5sum -c && \
    mkdir -p $MAVEN_ROOT && \
    tar xzf /tmp/apache-maven-$MAVEN_VERSION.tar.gz -C $MAVEN_ROOT && \
    ln -s $MAVEN_ROOT/$MAVEN_VERSION/bin/mvn /usr/local/bin && \
    rm -f /tmp/apache-maven-$MAVEN_VERSION.tar.gz

VOLUME ["/var/lib/maven"]

# Jenkins related
# ---------------
ENV JENKINS_HOME /var/lib/jenkins
ENV JENKINS_JAVA_ARGS '-Djava.awt.headless=true'
ENV JENKINS_MAXOPENFILES 8192
ENV JENKINS_PREFIX /jenkins
ENV JENKINS_ARGS '--webroot=/var/cache/jenkins/war --httpPort=8080 --ajp13Port=-1 --prefix=$JENKINS_PREFIX'
ENV TZ Europe/Brussels
ENV DEBIAN_FRONTEND noninteractive

EXPOSE 8080 2812 22 36562 33848/udp

RUN echo deb http://archive.ubuntu.com/ubuntu precise universe > /etc/apt/sources.list.d/universe.list
RUN apt-get update -qq
RUN apt-get -y install \
            openssh-server \
            openjdk-7-jre-headless \
            monit \
            curl \
            git \
            iptables \
            ca-certificates

ADD ./monit.d/ /etc/monit/conf.d/
ADD ./jenkins.sudoers /etc/sudoers.d/jenkins
ADD ./jenkins_init_wrapper.sh /jenkins_init_wrapper.sh
ADD ./plugins_script /plugins_script
ADD ./start.sh /start.sh
# Not possible to write to volume as the file is not there while running the container?
#ADD ./config.xml $JENKINS_HOME/config.xml
# So workaround. config.xml will be copied during startup script of jenkins if the xml is not existing
ADD ./config.xml /plugins_script/config.xml

VOLUME ["/var/lib/jenkins"]

#workaround: https://groups.google.com/forum/#!topic/docker-user/asLMWJQ7-0s
RUN ln -s -f /bin/true /usr/bin/chfn

RUN curl -s -L -o /tmp/jenkins_${JENKINS_VER}_all.deb http://pkg.jenkins-ci.org/debian/binary/jenkins_${JENKINS_VER}_all.deb && \
        dpkg -i /tmp/jenkins_${JENKINS_VER}_all.deb ; \
        apt-get -fy install

RUN /plugins_script/download_plugins.sh
RUN ssh-keygen -f /plugins_script/jenkins_id_rsa -t rsa -N ''

#set locale to UTF-8
RUN sudo echo 'LC_ALL=en_US.UTF-8' > /etc/default/locale

# Docker related
# ---------------
# now we install docker in docker - thanks to https://github.com/jpetazzo/dind
RUN curl -s -L -o /usr/local/bin/docker https://get.docker.com/builds/Linux/x86_64/docker-${DOCKER_VERSION}
ADD ./wrapdocker /usr/local/bin/wrapdocker
RUN chmod +x /usr/local/bin/docker /usr/local/bin/wrapdocker
# volume required to make docker in docker to work
VOLUME ["/var/lib/docker"]

ENTRYPOINT ["/bin/bash", "/start.sh"]
