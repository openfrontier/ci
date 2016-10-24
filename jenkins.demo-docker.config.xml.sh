#!/bin/bash

BUILD_NUMBER='$BUILD_NUMBER'
SNAPSHOT_BUILD_NUMBER='$SNAPSHOT_BUILD_NUMBER'
GERRIT_NAME=${GERRIT_NAME:-gerrit}
JENKINS_WEBURL=${JENKINS_WEBURL:-http://jenkins:8080/jenkins}

cat <<EOF
<?xml version='1.0' encoding='UTF-8'?>
<project>
  <actions/>
  <description></description>
  <keepDependencies>false</keepDependencies>
  <properties>
    <hudson.model.ParametersDefinitionProperty>
      <parameterDefinitions>
        <hudson.model.StringParameterDefinition>
          <name>SNAPSHOT_BUILD_NUMBER</name>
          <description></description>
          <defaultValue></defaultValue>
        </hudson.model.StringParameterDefinition>
      </parameterDefinitions>
    </hudson.model.ParametersDefinitionProperty>
  </properties>
  <scm class="hudson.plugins.git.GitSCM" plugin="git@2.4.4">
    <configVersion>2</configVersion>
    <userRemoteConfigs>
      <hudson.plugins.git.UserRemoteConfig>
        <name>origin</name>
        <url>ssh://jenkins@${GERRIT_NAME}:29418/demo-docker</url>
        <credentialsId>jenkins-master</credentialsId>
      </hudson.plugins.git.UserRemoteConfig>
    </userRemoteConfigs>
    <branches>
      <hudson.plugins.git.BranchSpec>
        <name>refs/heads/master</name>
      </hudson.plugins.git.BranchSpec>
    </branches>
    <doGenerateSubmoduleConfigurations>false</doGenerateSubmoduleConfigurations>
    <submoduleCfg class="list"/>
    <extensions/>
  </scm>
  <assignedNode>master</assignedNode>
  <canRoam>false</canRoam>
  <disabled>false</disabled>
  <blockBuildWhenDownstreamBuilding>false</blockBuildWhenDownstreamBuilding>
  <blockBuildWhenUpstreamBuilding>false</blockBuildWhenUpstreamBuilding>
  <triggers/>
  <concurrentBuild>false</concurrentBuild>
  <builders>
    <com.cloudbees.dockerpublish.DockerBuilder plugin="docker-build-publish@1.2.1">
      <server plugin="docker-commons@1.3.1">
        <uri>tcp://172.17.0.1:2375</uri>
      </server>
      <registry plugin="docker-commons@1.3.1"/>
      <repoName>openfrontier/demo</repoName>
      <noCache>true</noCache>
      <forcePull>false</forcePull>
      <buildContext>dockerProject</buildContext>
      <skipBuild>false</skipBuild>
      <skipDecorate>true</skipDecorate>
      <repoTag>${BUILD_NUMBER}</repoTag>
      <skipPush>true</skipPush>
      <createFingerprint>true</createFingerprint>
      <skipTagLatest>true</skipTagLatest>
      <buildAdditionalArgs>--build-arg jenkins_url=${JENKINS_WEBURL} --build-arg build_number=${SNAPSHOT_BUILD_NUMBER}</buildAdditionalArgs>
      <forceTag>true</forceTag>
    </com.cloudbees.dockerpublish.DockerBuilder>
  </builders>
  <publishers/>
  <buildWrappers/>
</project>
EOF
