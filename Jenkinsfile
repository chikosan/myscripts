pipeline {
    agent { label 'ansible-docker-agent'} 
    options{
        ansiColor 'xterm'
        timestamps()
    }
    agent any

    stages {
        stage('Build') {
            steps {
                echo 'Building..'
            }
        }
        stage('Test') {
            steps {
                echo 'Testing..'
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying....'
            }
        }
    }
}
