@echo off
setlocal
set "BASEDIR=%~dp0"
set "BASEDIR=%BASEDIR:~0,-1%"
java "-Dmaven.multiModuleProjectDirectory=%BASEDIR%" -classpath "%BASEDIR%\.mvn\wrapper\maven-wrapper.jar" org.apache.maven.wrapper.MavenWrapperMain %*
