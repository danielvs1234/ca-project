pipeline {
  agent any
  environment{
      DOCKER_USER='d0wnt0wn3d'
  }
  stages {
    stage('clone') {
      steps {
        stash excludes: ".git/", name: "code"
      }
    }
    stage('parallel execution'){
      parallel{
        stage('build artifacts'){
            agent{
                docker{
                    image 'ubuntu:latest'
                }
            }
        options{
            skipDefaultCheckout()
        }
          steps{
            unstash 'code'
            sh 'apt-get update'
            sh 'apt-get install zip -y'
            sh 'zip -r artefacts.zip ./'
            archiveArtifacts 'artefacts.zip'
          }
        }
        stage('build docker image'){
            agent{
                docker{
                    image 'docker:latest'
                }
            }
            options{
                skipDefaultCheckout()
            }
          steps{
            unstash 'code'
            sh 'docker build -t ${DOCKER_USER}/codechan:latest -t ${DOCKER_USER}/codechan:dev .'
            sh 'docker image ls'            
          }
        }
      }
    }
    stage('test'){
        agent{
            docker{
                    image 'python:latest'
                }
        }
        options{
            skipDefaultCheckout()
        }
      steps{
        unstash 'code'
        sh 'pip install -r requirements.txt'
        sh 'python tests.py'
      }
    }

stage ("deploy"){
parallel{
    stage('push to docker if master'){
      when {branch "master"}
        environment {
          DOCKERCREDS = credentials('docker-login')
        }
        steps {
            sh 'echo "$DOCKERCREDS_PSW" | docker login -u "$DOCKERCREDS_USR" --password-stdin' //login to docker hub with the credentials above
            sh 'docker push "$DOCKER_USER/codechan:latest"'
        }
        
    }
    
    stage('push to docker if develop'){
        when{not{branch "master"}}
        environment {
          DOCKERCREDS = credentials('docker-login')
        }
        steps {
            sh 'echo "$DOCKERCREDS_PSW" | docker login -u "$DOCKERCREDS_USR" --password-stdin' //login to docker hub with the credentials above
            sh 'docker push "$DOCKER_USER/codechan:dev"'
        }
    }
    }}
    
    stage('deploy on server'){
      steps{
            script{
                withCredentials([sshUserPrivateKey(credentialsId: 'testkey', keyFileVariable: 'identity', passphraseVariable: '', usernameVariable: 'username')]) {
                def remote =[:]
                if(env.BRANCH_NAME == 'master'){
                    remote.name = 'sharankaMachine'
                    remote.host = '35.195.199.29'
                    remote.allowAnyHosts = true
                    remote.user = username
                    remote.identityFile = identity
                    sshCommand remote: remote, command: 'docker stop $(docker ps -a -q)'
                    sshCommand remote: remote, command: 'docker container run -p 80:5000 -d d0wnt0wn3d/codechan:latest'
                    
                }else{
                    remote.name = 'danielMachine'
                    remote.host = '34.76.179.88'
                    remote.allowAnyHosts = true
                    remote.user = username
                    remote.identityFile = identity
                    sshCommand remote: remote, command: 'docker stop $(docker ps -a -q)'
                    sshCommand remote: remote, command: 'docker container run -p 80:5000 -d d0wnt0wn3d/codechan:dev'
                }
                
                }
         }
        
        }
     }
    }
}