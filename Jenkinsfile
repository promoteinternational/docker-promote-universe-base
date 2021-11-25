#!groovy
// https://docs.promoteapp.net/tools/jenkins-ci.html

pipeline {
  options {
    disableConcurrentBuilds()
    buildDiscarder(logRotator(daysToKeepStr: '90', numToKeepStr: '20'))
    quietPeriod(10)
    timeout(time: 180, unit: 'MINUTES')
  }

  agent { label 'promote_docker' }

  environment {
    DOCKER_HUB_AUTH = credentials('docker_hub_promoteinternational')
  }

  stages {
    stage('make sure buildx container exists') {
      steps {
        sh '''#!/bin/bash -le
          docker buildx create --use
          '''
      }
    }

    stage('Login to docker hub') {
      steps {
        sh '''#!/bin/bash -le
          echo "$DOCKER_HUB_AUTH_PSW" | docker login -u "$DOCKER_HUB_AUTH_USR" --password-stdin
          '''
      }
    }

    // Fix from https://gitlab.alpinelinux.org/alpine/aports/-/issues/12406#note_177630
    // Workaround for this error:
    //   #9 12.24 Executing busybox-1.32.1-r5.trigger
    //   #9 12.25 ERROR: busybox-1.32.1-r5.trigger: script exited with error 1
    //   #9 12.25 Executing ca-certificates-20191127-r5.trigger
    //   #9 12.25 ERROR: ca-certificates-20191127-r5.trigger: script exited with error 1
    //   #9 12.25 Executing shared-mime-info-2.0-r0.trigger
    //   #9 14.15 1 error; 422 MiB in 78 packages
    //   #9 ERROR: process "/dev/.buildkit_qemu_emulator /bin/sh -c apk add --no-cache --update build-base nmap-ncat bash postgresql-dev tzdata shared-mime-info" did not complete successfully: exit code: 1
    stage('Fix for alpine') {
      steps {
        sh '''#!/bin/bash -le
          docker run --rm --privileged linuxkit/binfmt:v0.8
          '''
      }
    }

    stage('Build and push docker images') {
      steps {
        sh '''#!/bin/bash -le
          if [ "$BRANCH_NAME" == main ]; then
            tag=latest
          else
            tag="$BRANCH_NAME"
          fi

          docker buildx build \
            --platform linux/arm64/v8,linux/amd64 \
            --tag "promoteinternational/promote-universe-base:$tag" \
            --push .
          '''
      }
    }
  }
}
