pipeline {
  agent {
    label 'docker'
  }

  options {
    parallelsAlwaysFailFast()
  }

  stages {
    stage('Build') {
      steps {
        sh 'docker compose build --pull'
      }
    }

    stage('Spec') {
      steps {
        sh 'docker compose run api_client_builder bundle exec rspec --format doc'
        sh '''
        image=$(docker ps --all --no-trunc | grep spec | cut -f 1 -d " " | head -n 1)
        docker cp "$image:/usr/src/app/coverage" .
        '''
        sh 'ls -als coverage'
      }

      post {
        always {
          publishHTML target: [
              allowMissing: false,
              alwaysLinkToLastBuild: false,
              keepAll: true,
              reportDir: 'coverage',
              reportFiles: 'index.html',
              reportName: 'Coverage Report'
            ]
        }
      }
    }
  }

  post {
    cleanup {
      sh 'docker compose down --rmi=all --volumes --remove-orphans'
    }
  }
}
