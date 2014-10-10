docker-jenkins-master
=====================
    Image Base : dfranssen/docker-base

    Exposed Ports : 8080 2812 22 36562 33848/udp
    Timezone : Europe/Brussels

    Jenkins version : 1.583
    Jenkins Home : /var/lib/jenkins

    Maven version : 3.2.2
    Maven Home : /var/lib/maven/maven-3.2.2

Environment Variables
---------------------
    MAVEN_OPTS
        Arguments to pass to maven. Default : '-Xms256m -Xmx512m'

    JENKINS_JAVA_ARGS
        Arguments to pass to Java when Jenkins starts. Default : '-Djava.awt.headless=true'
    JENKINS_MAXOPENFILES
        Ulimit maxopenfiles for Jenkins. Default '8192'
    JENKINS_PREFIX
        URL prefix. Default '/jenkins'
    JENKINS_ARGS
        Start up arguments for Jenkins. Default '--webroot=/var/cache/jenkins/war --httpPort=8080 --ajp13Port=-1 --prefix=$JENKINS_PREFIX'
    JENKINS_SLAVE_JNLP
        JNLP port for Jenkins Slave communication. Default : 36562
    TZ
        Container Timezone. Default 'Europe/Brussels'

Services
--------
    Jenkins
    Monit
    SSHD


When running the image, you can pass in environment variables that will affect the behaviour of Jenkins.
An example, you change the Timezone by runnning:

    docker run --env TZ=<TIMEZONE> -d dfranssen/docker-jenkins-master

Or change Java heap size:

    docker run --env JENKINS_JAVA_ARGS=-Xmx4g -d dfranssen/docker-jenkins-master

If you want to preserve the volume after the container has been removed (e.g update of the image) or want to
facilitate the backup/restore of the jenkins home folder, it is best to add the option `--volumes-from myjenkins-data`
in the run instruction of above.
The data container could be started by running:

    docker run -d --name myjenkins-data -v /var/lib/jenkins busybox:ubuntu-14.04 true

Monit is used to control the start up and management of Jenkins (and SSHD). You can access the monit webserver
by exposing port 2812 on the Docker host. The user name is `monit` and password can be found by running:

    docker logs <CONTAINER_ID> 2>/dev/null | grep MONIT_PASSWORD

OpenSSH is also running, you can ssh to the container by exposing port 22 on your Docker host and using the username
`jenkins`. Password can be found by running:

    docker logs <CONTAINER_ID> 2>/dev/null | grep JENKINS_PASSWORD

An id_rsa key pair is also generated and the contents of the public key can be found by:

    docker logs <CONTAINER_ID> 2>/dev/null | grep ID_RSA_PUB

bitbucket.org has been added to the ssh known_hosts.

Furthermore, this Jenkins container is also capable of managing Docker containers on the host when the socket is bind-mount-in.
Currently no need to run with the --privileged flag as no seperate Docker daemon is needed inside this jenkins container, but this is possible though :-)
In order to know the host ip address make an alias as indicated in the following statements and pass it as an environment variable:

    alias hostip="ip route show 0.0.0.0/0 | grep -Eo 'via \S+' | awk '{ print \$2 }'"
    docker run -v /var/run/docker.sock:/var/run/docker.sock -e DOCKER_HOST==$(hostip) <CONTAINER_ID>

This DOCKER_HOST would allow Jenkins to execute system tests against the new container he created with the application code. This container is bound to the DOCKER_HOST as the socket was bind in.

If no DOCKER_HOST environment variable is set, the --privileged flag should be used and a Docker daemon will be enabled in this container.

Plugins
-------

The following list of plugins come included in the container (some dependencies are listed explicitly in order to have the latest version):

    git
    greenballs
    parameterized-trigger
    promoted-builds
    hipchat
    build-pipeline-plugin
    bitbucket-oauth

It is possible to customise the plugins that get added to the image by updating:

    ./plugins_script/plugins.txt

You don't need to worry about plugin dependencies, they are resolved when you build the image.

Kudos to [yasn77] (https://github.com/yasn77/docker-jenkins.git) for the inspiration.
