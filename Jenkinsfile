pipeline {
    agent any

    stages {
        stage('Build2') {
            steps {
                echo 'Building..'
                echo 'Pulling...' + env.BRANCH_NAME
            }
        }
        stage('Test2') {
            steps {
                echo 'Testing..'
            }
        }
        stage('Deploy2') {
            steps {
                echo 'Deploying....'
            }
        }
    }
}
