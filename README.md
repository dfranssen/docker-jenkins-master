docker-jenkins
==============
    OS Base : Ubuntu 14.04
    Jenkins version : 1.574
    Exposed Ports : 8080 2812 22 36562 33848/udp
    Jenkins Home : /var/lib/jenkins
    Timezone : Europe/Brussels

Environment Variables
---------------------
    JENKINS_JAVA_ARGS
        Arguments to pass to Java when Jenkins starts. Default : '-Djava.awt.headless=true'
    JENKINS_MAXOPENFILES
        Ulimit maxopenfiles for Jenkins. Default '8192'
    JENKINS_PREFIX
        URL prefix. Default '/jenkins'
    JENKINS_ARGS
        Start up arguements for Jenkins. Default '--webroot=/var/cache/jenkins/war --httpPort=8080 --ajp13Port=-1 --prefix=$JENKINS_PREFIX'
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

    docker run --env TZ=<TIMEZONE> -d <CONTAINER_ID>
Or change Java heap size:

    docker run --env JENKINS_JAVA_ARGS=-Xmx4g -d <CONTAINER_ID>

If you want to preserve the volume after the container has been removed (e.g update of the image) or want to
facilitate the backup/restore of the jenkins home folder, it is best to add the option `--volumes-from myjenkins-data`
in the run instruction of above.
The data container could be started by running:

    docker run -d --name myjenkins-data busybox:ubuntu-14.04 true

Monit is used to control the start up and management of Jenkins (and SSHD). You can access the monit webserver
by exposing port 2812 on the Docker host. The user name is `monit` and password can be found by running:

    docker logs <CONTAINER_ID> 2>/dev/null | grep MONIT_PASSWORD

OpenSSH is also running, you can ssh to the container by exposing port 22 on your Docker host and using the username
`jenkins`. Password can be found by running:

    docker logs <CONTAINER_ID> 2>/dev/null | grep JENKINS_PASSWORD

Plugins
-------

The following list of plugins come included in the container:

    config-file-provider
    envinject
    git
    git-client
    git-server
    github
    greenballs
    multiple-scms
    parameterized-trigger
    promoted-builds
    scm-sync-configuration
    scriptler
    swarm
    xunit
    hipchat
    build-pipeline-plugin
    clone-workspace-scm
    matrix-combinations-parameter
    job-exporter
    It is possible to customise the plugins that get added to the image by updating:

    ./plugins_script/plugins.txt

You don't need to worry about plugin dependencies, they are resolved when you build the image.

Kudos to [yasn77] {https://github.com/yasn77/docker-jenkins.git} for the inspiration.
