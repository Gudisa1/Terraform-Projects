---
# Deploying a Node.js Application on an EC2 Instance Using Terraform

This repository provides a step-by-step guide to deploying a Node.js application on an Amazon EC2 instance using Terraform. By automating the infrastructure provisioning with Terraform, you'll be able to quickly set up an environment to run your Node.js application on AWS. This setup includes creating a Virtual Private Cloud (VPC), public subnet, security groups, and launching an EC2 instance.

The guide is designed for users familiar with both Node.js and Terraform. By the end of this tutorial, you'll have a fully functional Node.js app running on an EC2 instance in a public subnet that is publicly accessible via the internet.

## Prerequisites

Before proceeding, ensure you have the following tools and resources in place:

1. **AWS Account**: You will need access to an AWS account to provision resources.
2. **Terraform**: Installed on your local machine. You can install it by following the [official Terraform installation guide](https://learn.hashicorp.com/tutorials/terraform/install-cli).
3. **AWS CLI**: Installed and configured with credentials that have sufficient permissions to create AWS resources.
   - Follow the [AWS CLI configuration guide](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html) if needed.
4. **Node.js**: The application you plan to deploy should be a Node.js app.
   - Ensure Node.js and NPM are installed locally for development.
5. **SSH Key Pair**: An SSH key pair to connect to your EC2 instance. You can generate one using the AWS Management Console or the `ssh-keygen` command.
6. **Text Editor**: Use any text editor such as Visual Studio Code or Sublime Text to modify Terraform files and your Node.js application.

---


---

### 1. Define the AWS Provider

Now that we've covered the prerequisites, it's time to dive into the real work of setting up your infrastructure. The first step in configuring Terraform is to define the **provider**, which specifies which cloud platform (in our case, AWS) you are working with. This is where the fun begins!

In Terraform, the **provider** block is crucial because it tells Terraform which set of APIs to interact with. We'll also define the AWS region where your infrastructure will be deployed.

Let's start by creating a file called `main.tf` in your project directory and adding the following code:

```hcl
# Define the provider
provider "aws" {
  region = "us-east-1"
}
```

Here's a breakdown of what's happening in this code:

- **provider "aws"**: This tells Terraform that we’re working with AWS as the cloud provider.
- **region**: This defines the AWS region where your resources (such as the EC2 instance, VPC, and subnets) will be created. In this example, we’re using the `us-east-1` region (Northern Virginia). You can choose a different region based on your geographic needs or AWS availability.

### Why is this important?

The provider and region are essential because they ensure Terraform knows where to create your resources and how to interact with AWS services. Without defining this, Terraform won’t be able to execute the subsequent steps to provision your infrastructure.

With the provider defined, we're now set to move on to creating the network components and launching the EC2 instance where your Node.js application will run. This is where the actual infrastructure deployment begins!

---


---

### 2. Create a Virtual Private Cloud (VPC)

Next, we'll create a Virtual Private Cloud (VPC). A VPC is a logically isolated network within AWS that provides you with complete control over your networking environment. Think of it as your own private data center in the cloud where you'll deploy your EC2 instance, subnets, and other resources. 

In this step, we're going to define a VPC with a specific IP range using a **CIDR block** and enable DNS support to make managing resources within the VPC easier.

Add the following code to your `main.tf` file:

```hcl
# Create a VPC
resource "aws_vpc" "Node" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "Node"
  }
}
```

#### Explanation:

- **resource "aws_vpc" "Node"**: This declares a new AWS VPC resource named `Node`.
- **cidr_block**: Specifies the IP range for the VPC. We're using `10.0.0.0/16`, which allows up to 65,536 IP addresses (a large range suitable for a wide array of resources within your VPC).
- **enable_dns_support**: Enables DNS resolution within the VPC, allowing instances to resolve domain names to IP addresses.
- **enable_dns_hostnames**: Enables DNS hostnames for instances launched within the VPC. This is important if you want to access your EC2 instances via a DNS name.
- **tags**: Adds a `Name` tag to the VPC for easier identification in the AWS console. We've named the VPC **Node**, but you can choose a name that suits your project.

### Why is this important?

A VPC is foundational to any AWS infrastructure. It provides the networking environment where all your resources will reside. By defining a custom VPC, you have control over networking aspects like routing, security, and subnets, ensuring your Node.js app runs in an isolated and secure environment.

Now that we've defined the VPC, we're ready to move forward and set up the public subnet where our EC2 instance will reside.

---



---

### 3. Create a Public Subnet

With the VPC in place, the next step is to create a **public subnet**. Subnets are segments of your VPC where resources like EC2 instances can be launched. In this case, we're setting up a public subnet, which means the instances within this subnet will be able to communicate with the internet.

To create a public subnet, add the following code to your `main.tf` file:

```hcl
# Create a public subnet
resource "aws_subnet" "Node_subnet" {
  vpc_id                  = aws_vpc.Node.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Node-subnet"
  }
}
```

#### Explanation:

- **vpc_id**: Specifies the ID of the VPC where the subnet will be created. We’re referencing the VPC we created earlier (`aws_vpc.Node.id`).
- **cidr_block**: Defines the IP range for the subnet. Here, we're using `10.0.1.0/24`, which allows 256 IP addresses (suitable for the resources we’ll deploy in this subnet).
- **availability_zone**: Specifies the availability zone where this subnet will be created. In this example, it’s set to `us-east-1a`, but you can choose another AZ if needed.
- **map_public_ip_on_launch**: When set to `true`, this automatically assigns a public IP to any instance launched in this subnet, making them accessible from the internet. This is essential for a public subnet.
- **tags**: Tags make it easier to manage and identify resources. Here, we’re tagging the subnet with the name `Node-subnet`.

### Why is this important?

The public subnet is a critical component because it's where your EC2 instance will be deployed. By setting `map_public_ip_on_launch` to true, any instance launched in this subnet will be assigned a public IP address, allowing it to communicate with the internet. This is necessary for hosting a publicly accessible Node.js application.

With the public subnet created, we are now ready to move on to setting up the Internet Gateway to route traffic to and from the internet.

---


---

### 4. Create an Internet Gateway

Now that we have a VPC and a public subnet, the next step is to set up an **Internet Gateway**. An Internet Gateway enables your VPC to communicate with the internet, making it possible for the resources inside your VPC (like the EC2 instance) to send and receive traffic over the web.

To create an Internet Gateway, add the following code to your `main.tf` file:

```hcl
# Create an internet gateway
resource "aws_internet_gateway" "Node_gateway" {
  vpc_id = aws_vpc.Node.id
  tags = {
    Name = "Node-gateway"
  }
}
```

#### Explanation:

- **vpc_id**: Specifies the VPC to which the Internet Gateway will be attached. In this case, it’s the VPC we created earlier (`aws_vpc.Node.id`).
- **tags**: Tags help with resource identification and management. We’re tagging the Internet Gateway with the name `Node-gateway` for easy identification.

### Why is this important?

The Internet Gateway is a crucial component for enabling communication between your VPC and the internet. Without it, any EC2 instances in your public subnet would be isolated and unable to access the web, which would prevent your Node.js application from being accessible to users or interacting with external services.

With the Internet Gateway in place, the next step is to create a route table that directs traffic between the public subnet and the internet via the gateway.

---



---

### 5. Create a Route Table for the Public Subnet

With the VPC, subnet, and Internet Gateway in place, the next step is to create a **Route Table**. A route table contains rules (routes) that determine where network traffic is directed. In this case, we’ll create a route that allows all outbound traffic (`0.0.0.0/0`) from the public subnet to flow through the Internet Gateway, providing internet access to any instances within the subnet.

Add the following code to your `main.tf` file:

```hcl
# Create a route table for the public subnet
resource "aws_route_table" "Node_route_table" {
  vpc_id = aws_vpc.Node.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Node_gateway.id
  }

  tags = {
    Name = "Node-route-table"
  }
}
```

#### Explanation:

- **vpc_id**: Associates the route table with the VPC. Here, we’re linking it to the `Node` VPC created earlier.
- **route**: Defines a route that directs traffic with the destination CIDR block `0.0.0.0/0` (representing all IPv4 traffic) to the Internet Gateway (`aws_internet_gateway.Node_gateway.id`), allowing public internet access.
- **cidr_block**: `0.0.0.0/0` specifies that the route applies to all outbound traffic, enabling the instances in the public subnet to send traffic to any external destination.
- **gateway_id**: Specifies the Internet Gateway that the traffic will use to reach the internet.
- **tags**: Tags are used to assign a name to the route table, in this case, `Node-route-table`, for easy identification.

### Why is this important?

The route table is critical for controlling network traffic within your VPC. By associating the route table with the Internet Gateway, you ensure that the instances in your public subnet can access and be accessed by the internet. This is vital for running a web-facing Node.js application on EC2.

With the route table created, the next step is to associate it with the public subnet, ensuring that all traffic from the subnet follows the routing rules defined here.

---


---

### 6. Associate the Route Table with the Public Subnet

The final step in setting up the networking components is to **associate the route table** with the public subnet. This ensures that the traffic routing rules defined in the route table are applied to the instances in the subnet.

Add the following code to your `main.tf` file:

```hcl
# Associate the route table with the public subnet
resource "aws_route_table_association" "Node_route_table_association" {
  subnet_id      = aws_subnet.Node_subnet.id
  route_table_id = aws_route_table.Node_route_table.id
}
```

#### Explanation:

- **subnet_id**: Specifies the ID of the subnet that will use this route table. Here, it’s the `Node_subnet` we created earlier (`aws_subnet.Node_subnet.id`).
- **route_table_id**: Specifies the ID of the route table to associate with the subnet. We’re linking it to the `Node_route_table` created previously (`aws_route_table.Node_route_table.id`).

### Why is this important?

Associating the route table with the public subnet applies the routing rules to all instances within that subnet. This step ensures that any instance launched in the public subnet will use the defined route table to direct traffic, allowing it to access the internet via the Internet Gateway. Without this association, the route table rules wouldn't apply, and your instances might be unable to communicate with the outside world.

With the route table association complete, we’re now ready to move on to creating the EC2 instance where your Node.js application will run.

---


---

### 7. Create a Security Group

To ensure that your EC2 instance is accessible and secure, you need to create a **Security Group**. A Security Group acts as a virtual firewall that controls the inbound and outbound traffic to your EC2 instances. 

In this step, we’ll define a security group that allows access to necessary ports for your Node.js application while ensuring overall security.

Add the following code to your `main.tf` file:

```hcl
# Create a security group
resource "aws_security_group" "Node_security_group" {
  vpc_id = aws_vpc.Node.id

  # Inbound rules
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Node-security-group"
  }
}
```

#### Explanation:

- **vpc_id**: Associates the security group with the VPC we created earlier (`aws_vpc.Node.id`).

#### Inbound Rules:
- **ingress**: Defines rules for inbound traffic to the EC2 instance.
  - **from_port** and **to_port**: Specifies the port range that this rule applies to.
  - **protocol**: Indicates the protocol (TCP in this case).
  - **cidr_blocks**: Defines the IP ranges allowed to access the specified ports. `0.0.0.0/0` means any IP address can access these ports, which is typical for web applications but should be used cautiously.

  - **Port 22**: Allows SSH access to the instance for remote management.
  - **Port 80**: Allows HTTP traffic to enable web access to your Node.js application.
  - **Port 3000**: Allows traffic to the port on which your Node.js application is running (customize this if your application runs on a different port).

#### Outbound Rules:
- **egress**: Defines rules for outbound traffic from the EC2 instance.
  - **from_port** and **to_port**: Specifies the port range for outbound traffic. Here, `0` to `0` means all ports.
  - **protocol**: `-1` indicates all protocols.
  - **cidr_blocks**: `0.0.0.0/0` allows outbound traffic to any IP address.

- **tags**: Adds a tag to the security group with the name `Node-security-group` for easier management and identification.

### Why is this important?

The security group is essential for controlling access to your EC2 instance. By configuring inbound rules, you ensure that only the necessary ports are open and accessible from the internet. The outbound rules ensure that your instance can communicate with the internet and other resources as needed.

With the security group set up, we're now ready to create the EC2 instance where your Node.js application will be deployed.

---



---

### 8. Create an EC2 Instance

Now that you have set up the networking and security configurations, it’s time to launch and configure your **EC2 instance** where your Node.js application will run. This step involves creating an EC2 instance, configuring it, and deploying your application files.

Add the following code to your `main.tf` file:

```hcl
# Create an EC2 instance
resource "aws_instance" "Node_instance" {
  ami           = "ami-0e86e20dae9224db8" # Ubuntu 22.04 LTS
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.Node_subnet.id
  vpc_security_group_ids = [aws_security_group.Node_security_group.id]
  key_name = "jenkins"  # Ensure that this key exists in AWS EC2

  tags = {
    Name = "Node-instance"
  }

  # Provision the instance
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/ubuntu/app",
      "sudo chown ubuntu:ubuntu /home/ubuntu/app"
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/jenkins.pem")
      host        = self.public_ip
    }
  }

  # Copy index.js
  provisioner "file" {
    source      = "index.js"
    destination = "/home/ubuntu/app/index.js"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/jenkins.pem")
      host        = self.public_ip
    }
  }

  # Copy package.json
  provisioner "file" {
    source      = "package.json"
    destination = "/home/ubuntu/app/package.json"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/jenkins.pem")
      host        = self.public_ip
    }
  }

  # Ensure directory exists, install packages, and start the app
  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install -y nodejs npm",
      "cd /home/ubuntu/app",
      "npm install",  # Install dependencies using package.json
      "nohup node index.js > app.log 2>&1 &"  # Run the application in the background
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/jenkins.pem")
      host        = self.public_ip
    }
  }
}
```

#### Explanation:

- **ami**: Specifies the Amazon Machine Image (AMI) to use for the instance. `ami-0e86e20dae9224db8` corresponds to Ubuntu 22.04 LTS. This image includes the Ubuntu operating system, which is necessary for running your Node.js application.

- **instance_type**: Defines the instance type. `t2.micro` is a cost-effective instance type suitable for small applications and development environments. It provides a baseline level of CPU performance with the ability to burst above the baseline when needed.

- **subnet_id**: Associates the EC2 instance with the previously created public subnet (`aws_subnet.Node_subnet.id`). This ensures that the instance is launched in the correct network and has internet access through the associated route table.

- **vpc_security_group_ids**: Links the security group to the instance. This security group (`aws_security_group.Node_security_group.id`) controls the allowed inbound and outbound traffic to your instance.

- **key_name**: Specifies the SSH key pair for connecting to the instance. Ensure that you have a key pair named `jenkins` in your AWS EC2 Key Pairs. This key is used to securely access your instance via SSH. Make sure you have the private key (`jenkins.pem`) available on your local machine.

- **tags**: Tags are used for organizing and managing AWS resources. Here, the instance is tagged with the name `Node-instance` for easier identification.

#### Provisioners:

Provisioners are used to execute commands on the instance after it has been created. They help automate the configuration and setup process.

1. **Remote-exec Provisioner (Initial Setup)**:
   - **inline**: Specifies the commands to run on the instance.
     - `mkdir -p /home/ubuntu/app`: Creates a directory named `/home/ubuntu/app` if it does not already exist. The `-p` option ensures that no error is thrown if the directory already exists.
     - `sudo chown ubuntu:ubuntu /home/ubuntu/app`: Changes the ownership of the directory to the `ubuntu` user. This allows the `ubuntu` user to have the necessary permissions to modify files within this directory.

   - **connection**: Defines how to connect to the instance.
     - **type**: Connection type is SSH.
     - **user**: The username for SSH access, `ubuntu` in this case.
     - **private_key**: Path to the private key file (`~/.ssh/jenkins.pem`) used for SSH access. Ensure this file is present and has the correct permissions (readable only by the user).
     - **host**: The public IP address of the instance (`self.public_ip`). Terraform automatically assigns this value once the instance is created.

2. **File Provisioner (Copy Files)**:
   - **source**: Specifies the path to the local file you want to copy to the instance. In this case, `index.js` and `package.json` are being copied.
   - **destination**: Path on the instance where the file will be placed (`/home/ubuntu/app/index.js` and `/home/ubuntu/app/package.json`).

   - **connection**: Same as above, specifying the method of connecting to the instance.

3. **Remote-exec Provisioner (Final Setup)**:
   - **inline**: A list of commands executed to configure the instance.
     - `sudo apt update -y`: Updates the list of available packages and their versions. The `-y` option automatically confirms the updates.
     - `sudo apt install -y nodejs npm`: Installs Node.js and npm (Node.js package manager) on the instance. The `-y` option automatically confirms the installation.
     - `cd /home/ubuntu/app`: Changes the current directory to where your application files are located.
     - `npm install`: Installs the Node.js application dependencies listed in `package.json`.
     - `nohup node index.js > app.log 2>&1 &`: Runs your Node.js application (`index.js`) in the background using `nohup` to ensure it continues running after logout. The `> app.log 2>&1` part redirects both standard output and error messages to `app.log`.

   - **connection**: Same as above, specifying how to connect to the instance.

### Why is this important?

Creating and configuring the EC2 instance is crucial for running your Node.js application in a cloud environment. By automating the setup process using provisioners, you ensure consistency and efficiency. 

- **Security**: Proper configuration of SSH access and security groups ensures that your instance is both secure and accessible as needed.
- **Automation**: Provisioners automate the deployment of application files and installation of necessary software, reducing manual intervention and the risk of errors.
- **Accessibility**: Once configured, your instance will be accessible via its public IP address, allowing you to interact with and manage your Node.js application.

With the EC2 instance fully set up and your application running, you’re now ready to access and manage your Node.js application deployed in the cloud.

---

### Conclusion

Congratulations! You’ve successfully deployed a Node.js application on an EC2 instance using Terraform. By following the steps outlined in this guide, you’ve accomplished the following:

1. **Set Up Infrastructure**: You defined the essential AWS infrastructure components, including a Virtual Private Cloud (VPC), public subnet, internet gateway, route table, and security group, ensuring a secure and accessible environment for your application.

2. **Provisioned an EC2 Instance**: You launched an EC2 instance configured with Ubuntu 22.04 LTS, suitable for running Node.js applications. You associated it with the correct subnet and security group to ensure it has the necessary network and security settings.

3. **Automated Application Deployment**: Using Terraform’s provisioners, you automated the process of deploying your Node.js application. This includes copying application files, installing required software, and running your application, ensuring that the setup is reproducible and consistent.

4. **Security and Access**: You configured security groups to manage access to your EC2 instance and set up SSH access using a key pair, ensuring secure connections and management of your instance.

By leveraging Terraform for Infrastructure as Code (IaC), you’ve streamlined the deployment process, allowing you to manage your infrastructure in a scalable, repeatable manner. This approach not only enhances efficiency but also minimizes the risk of manual errors.

Remember, while this guide provides a foundational setup, you can further enhance your deployment by integrating additional features such as automated backups, monitoring, and scaling. Exploring these options will help you create a more robust and reliable application environment.

Feel free to revisit any part of this guide to adjust configurations according to your needs or expand your setup with more advanced features. Happy coding and deploying!

---

