pipeline {
    agent any

    stages {
        stage('Verificar Python') {
            steps {
                sh '''
                    python3 --version
                    python3 -m venv .venv-ci
                    .venv-ci/bin/pip install -r app/requirements.txt
                '''
            }
        }

        stage('Pruebas Unitarias') {
            steps {
                sh '''
                    .venv-ci/bin/python -m unittest discover \
                      -s app/tests -p "test_*.py" -v
                '''
            }
        }

        stage('Terraform Validate') {
            steps {
                dir('terraform') {
                    sh '''
                        terraform init -backend=false
                        terraform fmt -check
                        terraform validate
                    '''
                }
            }
        }

        stage('Ansible Syntax Check') {
            steps {
                dir('ansible') {
                    sh '''
                        ansible-playbook --syntax-check \
                          -i inventory playbook.yml
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'Examen DevOps: validaciones exitosas'
        }
        failure {
            echo 'Examen DevOps: revisar errores del pipeline'
        }
    }
}
