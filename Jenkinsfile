pipeline {
  agent any
  stages {
    stage('Sleep1s') {
      parallel {
        stage('Sleep1s') {
          steps {
            sleep 1
          }
        }

        stage('') {
          steps {
            echo 'Hello'
          }
        }

      }
    }

  }
}