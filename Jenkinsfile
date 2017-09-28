
de {
withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'test', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
    echo "$AWS_ACCESS_KEY_ID"
    echo "$AWS_SECRET_ACCESS_KEY"
    withCredentials([file(credentialsId: 'PUBLIC_KEY', variable: 'PUBLIC_KEY')]) {
    sh 'cat $PUBLIC_KEY';
    
    git url: 'https://github.com/alvarosIGZ/test-jenkins.git'
    sh "ls"
    def tfHome = tool name: 'Terraform', type: 'com.cloudbees.jenkins.plugins.customtools.CustomTool'
    env.PATH = "${tfHome}:${env.PATH}"

           // Mark the code build 'plan'....
            stage name: 'Plan', concurrency: 1
            // Output Terraform version
            sh "terraform --version"
            //Remove the terraform state
  //Remove the terraform state file so we always start from a clean state
            if (fileExists(".terraform/terraform.tfstate")) {
                sh "rm -rf .terraform/terraform.tfstate"
            }
            if (fileExists("status")) {
                sh "rm status"
            }
            sh "terraform get"
            sh "echo '-----------------ls1-----------'"
            sh "ls"
            sh "terraform init -input=false"
            sh "echo '-----------------ls2-----------'"
            sh "ls"
            sh "rm terraform.tfstate"
            sh "set +e; terraform plan -out=plan.out -var 'public_key_path=$PUBLIC_KEY' -var 'aws_access_key=$AWS_ACCESS_KEY_ID' -var 'aws_secret_key=$AWS_SECRET_ACCESS_KEY' -detailed-exitcode; echo \$? > status"
            def exitCode = readFile('status').trim()
            def apply = false
            echo "Terraform Plan Exit Code: ${exitCode}"
             if (exitCode == "0") {
                currentBuild.result = 'SUCCESS'
            }
            if (exitCode == "1") {
                currentBuild.result = 'FAILURE'
            }
            if (exitCode == "2") {
                stash name: "plan", includes: "plan.out"
                try {
                    input message: 'Apply Plan?', ok: 'Apply'
                    apply = true
                } catch (err) {
                    apply = false
                    currentBuild.result = 'UNSTABLE'
                }
            }
  if (apply) {
                stage name: 'Apply', concurrency: 1
                unstash 'plan'
                if (fileExists("status.apply")) {
                    sh "rm status.apply"
                }
                sh 'set +e; terraform apply plan.out; echo \$? > status.apply'
                sh 'ls'
                sh 'cat status.apply'
                def applyExitCode = readFile('status.apply').trim()
                if (applyExitCode == "0") {
                echo "EXITOOOOO"
                } else {
                    currentBuild.result = 'FAILURE'
                }
            }
}

    
}


 
}
