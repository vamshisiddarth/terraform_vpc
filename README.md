# Terraform_VPC

What Do We Achieve with This?
1. Create vpc with CIDR block ex: 10.0.0.0/16
2. Create public subnet in above vpc with CIDR block ex: 10.0.1.0/24
3. Create private subnet in above vpc with CIDR block ex: 10.0.2.0/24
4. Create and Assign Internet Gateway and Public Route Table to the Public Subnet
5. Create and Assign Private Route Table to the Private Subnet
6. Create the Security Group for the Public and Private Subnet
7. Create SSH Key pair for the EC2 instances
8. Create EC2 instances and install Apache on webserver

Implementation:
1. Download the cloud.tf and vars.tf file.
2. Replace the access_key, secret_key and key file values in the files.
3. Generate the .PEM, .ppk files and place in the same location as cloud.tf and vars.tf.
4. On a linux machine, execute the following<br>
							ssh-keygen -y -f <KEYPAIR>.pem
5. Copy the output and paste it in a empty file and this will be <Your_Key>. Maintain this in the same directory as other .tf files.
6. Execute below commands.<br>
							terraform plan<br>
							terraform apply -auto-approve<br>
