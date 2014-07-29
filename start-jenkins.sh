#!/bin/bash
set -e

mkdir -p $JENKINS_HOME/plugins
cd $JENKINS_HOME/plugins

for line in $(cat /opt/jenkins-plugins.txt)
do
  plugin=$(echo $line | cut -f1 -d;)
  version=$(echo $STR | cut -f2 -d;)
  if find ./${plugin} -maxdepth 0 -empty | read v; then
    (echo "Adding Jenkins Plugin: ${plugin} version ${version}..." && \
    wget --no-check-certificat http://updates.jenkins-ci.org/download/plugins/$plugin/$version/$plugin.hpi)
  fi
done

exec su jenkins -c "java -jar /opt/jenkins.war $JAVA_OPTS"
