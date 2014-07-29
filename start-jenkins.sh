#!/bin/bash
set -e

mkdir -p $JENKINS_HOME/plugins
cd $JENKINS_HOME/plugins

for line in $(cat /opt/jenkins-plugins.txt)
do
  IFS='/' read -a array <<< "$line"
  if [ ! -f ${array[0]}.hpi ]
  then
    echo "Adding Jenkins Plugin: ${array[0]} version ${array[1]}..." && \
    wget --no-check-certificat http://updates.jenkins-ci.org/download/plugins/${array[0]}/${array[1]}/${array[0]}.hpi
  fi
done

exec su root -c "$JAVA_HOME/bin/java -jar /opt/jenkins.war $JAVA_OPTS"
