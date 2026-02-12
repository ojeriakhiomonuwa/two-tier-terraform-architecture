# Week3_Terraform_Three_Tier_Architecture
The repository explains a step by step process to build a resilient and secure three tier Architecture on AWS using terraform and also implement Continuous Integration with GitHub Actions. It also goes futher to install and launch a web application in the web web servers

## Prerequisites
1. An AWS Account
2. AWS IAM user with Access Key ID and Secret
3. Access Key created. 
4. AWS CLI and Terraform Installed in your system.
5. Knowledge of subnetting and Classless InterDomain Routing (CIDR)
6. An IDE e.g VS code.

In this article, I will use terraform modules to implement the architecture. According to Hashicorp (the creators of terraform), Modules are self-contained packages of Terraform configurations that are managed as a group.

![](screenshots/modules-image.png)

## Architecture Overview
![](screenshots/Week3%20Terraform%20two%20tier%20Architecture%20diagram.jpg)

##  Step 1: Configure AWS CLI on your local system.
* After installing terraform, Open your terminal or CLI, type
`aws configure`
* Enter the access key and secret access key, type us-east-1 as region because we will be deploying our resources to us-east-1, leave the default out format as json.
  
## Step 2: Writing the terraform code whilst leveraging the use of modules
It’s finally time to start building your infrastructure. However, before you dive in, let me provide some clarification. We will be adhering to best practices when writing our code.

### Best Practices
* Store state files in remote location (AWS)
To begin, let’s create an S3 bucket for storing the state file in a remote location. Simply navigate to S3 and click the “Create bucket” button. Choose a name for your bucket, and then scroll down.

![](images/1.%20create%20bucket.png)
![](images/2.%20bucket%20creation.png)

*  Enable bucket versioning for backup purposes.
  ![](images/3.%20enable%20bucket%20versioning.png)
Under “Bucket Versioning”, click on “enable” , scroll all the way down and click on create bucket. if you forget to enable bucket versioning, then select the bucket that you have just created and click on the Properties tab and on the top you will find the option “Bucket versioning”, click on edit and enable it.

*  State Locking: To implement state-locking and maintain consistency in the tfstate file while collaborating on a project, follow these steps:
*  Navigate to the DynamoDB service dashboard.
* Click on the “Create Table” button.
* Assign a name of your choice to the table. In the “Partition Key” field, specify the name “LockID” (Note: It is case sensitive), as this is crucial for DynamoDB to effectively lock and release the file.
* Click the “Create Table” button to create the table.
 ![](images/4.%20dynamo%20db%20.png)

## Step 3: Writing the terraform files
To follow along with this article, kindly clone or fork this repository,
* After cloning, open the directory in your terminal or Git Bash (for windows users). Type the command below.  
`code .`
![](images/5.%20code%20..png)
* This opens the project folder in VS code. The image below shows a tree-like structure of how the directories and files are arranged in the project folder.
![](screenshots/tree.png)

* In VScode, open the “providers.tf” file located in the “App” directory, this file is used to tell terraform the provider we intend to use for the project, there are so many 

* providers available on the terrafrom registry

* Now lets, create the file to store the state file inside the S3 bucket created initially. Open the bucket you created for storing state files, just click on the bucket name to open it. Click “create folder”.
![](images/7.%20create%20folder.png)
* Type the folder name “backend”.

* Next, on your vscode, create a backend.tf file inside App directory. paste the code below.  
```terraform {
  backend "s3" {
    bucket = "state-file-bucket-3965"
    key    = "backend/test.tfstate"
    region = "us-east-1"
    dynamodb_table = "DynamoDB-state-lock"
  }
}
```
* Make sure you replace the bucket name and the dynamodb_table name with the correct names you used.
![](images/8.%20backend.tf.png)

* Next, create a terraforrm.tfvars file. This file is a sensitive file and can be used to store important variables for our project. It is not compulsory that this file should be named terraform.tfvars, you can name is dev.tfvars, stage.tfvars or prod.tfvars but for now, we will use the default name “terraform.tfvars”
  
**Note: If you decide to give the file a different name, then you mush pass the -var-file flag to the terraform apply command as in the code below**  
`terraform apply -var-file=dev.tfvars`

Now, Paste the code below in your terraform.tfvars file

        region                  = ""
        project_name            = ""
        vpc_cidr                = ""
        pub_sub_1a_cidr         = ""
        pub_sub_2b_cidr         = ""
        pri_sub_3a_cidr         = ""
        pri_sub_4b_cidr         = ""
        pri_sub_5a_cidr         = ""
        pri_sub_6b_cidr         = ""
        db_username             = ""
        db_password             = ""
        certificate_domain_name = ""
        additional_domain_name  = ""

Make sure you replace the necessary values you intend to use in the string. The region will be the same region where we created our S3 bucket, that is us-east-1. Replace all other values with your preferred values. You will have to do subnetting for you to be able to input values for the public and private subnets. Take for example if you pick `10.0.0.0/16` as your VPC CIDR Block, you have to do subnetting to get at least six subnet addresses to use for the public and private subnets.

***Note: Inserting sensitive information in the terraform.tfvars file is not the best way to store secrets such as username and password. In a production environment, you will use environment variables to store secrets or better still, use Hashicorp vault. Also, ensure you include the terraform.tfvars file and other sensitive files in .gitignore file before pushing changes to your remote repository on GitHub.***







## Navigate to the following directory

    cd modules/key
* Generate a public and private ssh key, by running the command below

    `ssh-keygen`  
Type the name of the key, in my case, "server_key". Leave the remaining options blank and hit enter key on your keyboard until you see the key fingerprint. Type `ls` to confirm that the public and private keys are generated.
![](images/9.%20ssh%20keygen.png)

## Deployment
* Navigate to the App directory
    
        cd ../..
        cd App

* Create an alias for `terraform` command
    
        alias tf=terraform

Initialize environment
    tf init

* Run plan to see the resources to be deployed
        
        tf plan

* Apply plan

        tf apply -auto-approve

***Note an ACM Certificate and Records should be created before running terrafom plan and apply***

## Check created resources
### VPC
![](screenshots/VPC.png)
### Subnets
![](screenshots/subnets.png)
### NAT Gateways
![](screenshots/nat-gateways.png)
### EC2 Instanc
![](screenshots/EC2-instances.png)
### Elastic Load Balnacer
![](screenshots/elb.png)
### Auto Scaling Group
![](screenshots/asg.png)
### Cloudfront 
![](screenshots/cloudfront%20distribution.png)
### Endpoints
![](screenshots/load-balancer-endpoint-test.png)
![](screenshots/load-balancer-endpoint-test2.png)
* Open the Cloud front Dashboard, Copy the distribution name and paste it on your web browser, you will see your web application.
![](screenshots/cloudfront-endpoint.png

)
## Cleanup
* Run this command to destroy/delete the resources in order to avoid unwanted charges.

        tf destroy -auto-approve

# Thank you for reading to the end. 
