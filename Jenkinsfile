pipeline {
  agent {
    label 'docker'
  }

  stages {
    stage('Lint & Test') {
      steps {
        sh './build.sh'
      }
    }
  }
}
