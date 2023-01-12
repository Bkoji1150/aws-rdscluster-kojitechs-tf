
pipeline {
        agent any
    parameters { 
        choice(name: 'ENVIRONMENT', choices: ['prod', 'prod', 'sbx', 'shared'], description: "SELECT THE ACCOUNT YOU'D LIKE TO DEPLOY TO.")
        choice(name: 'ACTION', choices: ['apply', 'apply', 'destroy'], description: 'Select action, BECAREFUL IF YOU SELECT DESTROY TO PROD')
    }
    stages{    
        stage('Git checkout') {
            steps{
                checkout scm
                    sh """
                        pwd
                        ls -l
                    """
                }
        }

        stage('TerraformInit'){
            steps {
                    withAWS(roleAccount:'735972722491', role:'Role_For-S3_Creation') {           
                        sh """
                        rm -rf .terraform 
                        terraform -chdir='examples/postgresql'  init -upgrade=true
                        echo \$PWD
                        whoami
                    """
                }
            }
        }
    stage('Create Terraform workspace'){
            steps {
                withAWS(roleAccount:'735972722491', role:'Role_For-S3_Creation') {  
                script {
                    try {
                        sh "terraform -chdir='examples/postgresql' workspace select ${params.ENVIRONMENT}"
                    } catch (Exception e) {
                        echo "Error occurred: ${e.getMessage()}"
                        sh """
                            terraform -chdir='examples/postgresql' workspace new ${params.ENVIRONMENT}
                            terraform -chdir='examples/postgresql' workspace select ${params.ENVIRONMENT}
                        """
                    }
    
                }
        }
            }          
    }
        stage('Terraform plan'){
            steps {
                    script {
                        withAWS(roleAccount:'735972722491', role:'Role_For-S3_Creation') {     
                        try{
                            sh "terraform -chdir='examples/postgresql' plan -var-file='${params.ENVIRONMENT}.tfvars' -refresh=true -lock=false -no-color -out='${params.ENVIRONMENT}.plan'"
                        } catch (Exception e){
                            echo "Error occurred while running"
                            echo e.getMessage()
                            sh "terraform -chdir='examples/postgresql' plan -refresh=true -lock=false -no-color -out='${params.ENVIRONMENT}.plan'"
                        }
                    }
                    }
            }
        }
        stage('Confirm your action') {
            steps {
                script {
                    timeout(time: 5, unit: 'MINUTES') {
                    def userInput = input(id: 'confirm', message: params.ACTION + '?', parameters: [ [$class: 'BooleanParameterDefinition', defaultValue: false, description: 'Apply terraform', name: 'confirm'] ])
                }
                }  
            }
        }
    stage('Terraform apply or destroy ----------------') {
            steps {
            sh 'echo "continue"'
            script{  
                withAWS(roleAccount:'735972722491', role:'Role_For-S3_Creation') {       
                if (params.ACTION == "destroy"){
                    script {
                        try {
                            sh """
                                echo "llego" + params.ACTION
                                terraform -chdir='examples/postgresql' destroy -var-file=${params.ENVIRONMENT}.tfvars -no-color -auto-approve
                            """
                        } catch (Exception e){
                            echo "Error occurred: ${e}"
                            sh "terraform -chdir='examples/postgresql' destroy -no-color -auto-approve"
                        }
                    }
                    
            }else {
                        sh"""
                            echo  "llego" + params.ACTION
                            terraform -chdir='examples/postgresql' apply ${params.ENVIRONMENT}.plan
                        """ 
                }  // if
                }
            }
            } //steps
        }  //stage
}
}
 
