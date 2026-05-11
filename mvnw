#!/bin/sh
BASEDIR=$(dirname "$0")
java -Dmaven.multiModuleProjectDirectory="$BASEDIR" -classpath "$BASEDIR/.mvn/wrapper/maven-wrapper.jar" org.apache.maven.wrapper.MavenWrapperMain "$@"
