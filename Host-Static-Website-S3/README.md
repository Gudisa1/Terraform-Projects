
## Deploying a Static Website on AWS S3 Using Terraform

### Introduction

In this guide, we will explore how to deploy a static website using Amazon S3 and Terraform. Amazon S3 (Simple Storage Service) provides a scalable and cost-effective way to host static websites. Terraform is an open-source infrastructure-as-code (IaC) tool that allows you to define and provision infrastructure using a declarative configuration language.

By the end of this guide, you'll have a complete understanding of how to set up an S3 bucket for static website hosting and manage it using Terraform.

---


---

### Prerequisites

Before we begin, ensure you have the following:

- **AWS Account**: An active AWS account is required to create and manage AWS resources. If you don't already have one, you can sign up at the [AWS Management Console](https://aws.amazon.com/).

- **Terraform Installed**: Terraform needs to be installed on your local machine to define and provision your infrastructure. You can download Terraform from its [official website](https://www.terraform.io/downloads.html). Follow the installation instructions for your operating system to set it up correctly.

- **Basic Understanding of Terraform**: Familiarity with Terraform's syntax and concepts will be helpful. This includes understanding how to write Terraform configurations, use variables, and manage state files. If you're new to Terraform, consider reviewing the [Terraform documentation](https://www.terraform.io/docs) or a beginner's guide to get up to speed.

- **Basic Knowledge of AWS S3**: A foundational understanding of Amazon S3 is necessary. This includes knowing how S3 buckets work, how to create and configure them, and how to use them for hosting static websites. AWS's [S3 documentation](https://docs.aws.amazon.com/s3/index.html) provides comprehensive information on S3 and its features.

---


---

### Setting Up Your Terraform Configuration

To deploy a static website on AWS S3 using Terraform, you'll need to create a Terraform configuration that includes defining variables and creating the S3 bucket. Follow the steps below to set up your Terraform configuration.

#### Step 1: Define Variables

Variables are essential in Terraform as they allow you to customize and reuse your configuration easily. By defining variables, you make your Terraform scripts more flexible and adaptable to different environments.

Create a file named `variables.tf` and define the following variables:

```hcl
variable "region" {
  description = "The AWS region where resources will be created."
  type        = string
  default     = "us-east-1"
}
```

- **`variable "region"`**: This variable specifies the AWS region where your S3 bucket and other resources will be created. The `default` value is set to `us-east-1`, which is a commonly used region. You can change this value if you want to deploy your resources in a different AWS region.

Next, define the bucket name variable:

```hcl
variable "bucket_name" {
  description = "The name of the S3 bucket to create."
  type        = string
}
```

- **`variable "bucket_name"`**: This variable represents the name of the S3 bucket that will be created. You’ll need to provide a value for this variable in a separate `terraform.tfvars` file or via the command line when applying your Terraform configuration.

To provide values for these variables, you can create a `terraform.tfvars` file:

```hcl
region       = "us-east-1"
bucket_name  = "my-static-website-bucket"
```

#### Step 2: Create the S3 Bucket

Once the variables are defined, you can proceed to create the S3 bucket. This is done in the `main.tf` file, where you will define the S3 bucket resource.

Create or open the `main.tf` file and add the following configuration:

```hcl
resource "aws_s3_bucket" "websitegudisa" {
  bucket = var.bucket_name
  acl    = "public-read" # Ensures that the bucket is publicly accessible

  tags = {
    Name        = var.bucket_name
    Environment = "Dev"
  }
}
```

- **`resource "aws_s3_bucket" "websitegudisa"`**: This block defines an S3 bucket resource named `websitegudisa`. The bucket’s name is set to the value provided by `var.bucket_name`.

- **`bucket`**: This argument specifies the name of the S3 bucket. It uses the value from the `bucket_name` variable.

- **`acl`**: The `acl` argument is set to `"public-read"`, which makes the bucket publicly accessible. This is necessary for hosting a static website so that users can access your content via a web browser.

- **`tags`**: Tags are key-value pairs associated with the bucket. Here, we add two tags:
  - **`Name`**: Sets the name of the bucket for identification purposes.
  - **`Environment`**: Indicates the environment, which is set to `"Dev"` in this example. You can use tags to categorize and manage resources more effectively.


---



---

#### Step 3: Configure Bucket Ownership and ACL

To ensure proper access control and ownership of your S3 bucket, you'll need to configure both bucket ownership and access control lists (ACLs). This step is crucial for managing permissions and access to your static website.

##### 1. Configure Bucket Ownership

Bucket ownership settings determine who has control over the objects uploaded to the bucket. By default, objects uploaded to a bucket are owned by the uploader. To change this and ensure that the bucket owner has control over all objects, use the `aws_s3_bucket_ownership_controls` resource.

Add the following configuration to your `main.tf` file:

```hcl
resource "aws_s3_bucket_ownership_controls" "bucket_ownership" {
  bucket = aws_s3_bucket.websitegudisa.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}
```

- **`resource "aws_s3_bucket_ownership_controls" "bucket_ownership"`**: Defines the ownership control settings for your S3 bucket.

- **`bucket`**: Refers to the bucket created in the previous step by using its ID (`aws_s3_bucket.websitegudisa.id`).

- **`rule`**: Contains the ownership control rules.
  - **`object_ownership`**: Set to `"BucketOwnerPreferred"`, which ensures that the bucket owner (rather than the uploader) has ownership of all objects. This setting is particularly useful if you want to consolidate object ownership and manage permissions more effectively.

##### 2. Configure Bucket ACL

Access Control Lists (ACLs) are used to manage access permissions for your S3 bucket and its contents. To make your bucket publicly accessible, you'll need to set its ACL to `public-read`.

Add the following configuration to your `main.tf` file:

```hcl
resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.websitegudisa.id
  acl    = "public-read"
}
```

- **`resource "aws_s3_bucket_acl" "bucket_acl"`**: Defines the ACL settings for your S3 bucket.

- **`bucket`**: Refers to the bucket created in the previous step by using its ID (`aws_s3_bucket.websitegudisa.id`).

- **`acl`**: Set to `"public-read"`, which allows all users to read the contents of the bucket. This is necessary for hosting a static website, so users can access your files via the web.


---


---

#### Step 4: Set Public Access Block

To manage the public access settings for your S3 bucket, you'll configure the bucket's public access block settings. This ensures that your bucket's accessibility aligns with your requirements for hosting a static website.

Add the following configuration to your `main.tf` file:

```hcl
resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket = aws_s3_bucket.websitegudisa.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
```

- **`resource "aws_s3_bucket_public_access_block" "block_public_access"`**: Defines the public access block settings for the S3 bucket.

- **`bucket`**: Refers to the bucket created earlier by using its ID (`aws_s3_bucket.websitegudisa.id`).

- **`block_public_acls`**: Set to `false`, which allows public ACLs on the bucket. This setting is required for making the bucket contents publicly accessible.

- **`block_public_policy`**: Set to `false`, which allows public policies on the bucket. This setting ensures that you can apply bucket policies that allow public access.

- **`ignore_public_acls`**: Set to `false`, which means the bucket will not ignore public ACLs. This setting ensures that public ACLs are respected.

- **`restrict_public_buckets`**: Set to `false`, which means the bucket will not restrict public access. This setting ensures that the bucket can be made publicly accessible if needed.

By configuring these settings, you ensure that your bucket's public access settings align with the requirements for hosting a static website, allowing your content to be accessible to users.

#### Step 5: Enable Bucket Versioning

Enabling versioning for your S3 bucket allows you to keep track of changes to objects over time. This feature is useful for recovering previous versions of objects if needed.

Add the following configuration to your `main.tf` file:

```hcl
resource "aws_s3_bucket_versioning" "gudisa_versioning" {
  bucket = aws_s3_bucket.websitegudisa.id

  versioning_configuration {
    status = "Enabled"
  }
}
```

- **`resource "aws_s3_bucket_versioning" "gudisa_versioning"`**: Defines the versioning configuration for the S3 bucket.

- **`bucket`**: Refers to the bucket created earlier by using its ID (`aws_s3_bucket.websitegudisa.id`).

- **`versioning_configuration`**: Contains the versioning settings for the bucket.
  - **`status`**: Set to `"Enabled"`, which activates versioning for the bucket. This setting ensures that previous versions of objects are retained and can be recovered if needed.

Enabling versioning provides an additional layer of protection for your data, allowing you to track and manage changes to objects in the bucket.

---



---

#### Step 6: Configure Static Website Hosting

To configure your S3 bucket to host a static website, you need to set up the bucket’s website configuration. This includes specifying the default index document and an error document.

Add the following configuration to your `main.tf` file:

```hcl
resource "aws_s3_bucket_website_configuration" "websitegudisa" {
  bucket = aws_s3_bucket.websitegudisa.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}
```

- **`resource "aws_s3_bucket_website_configuration" "websitegudisa"`**: Defines the website configuration for your S3 bucket.

- **`bucket`**: Refers to the bucket created earlier by using its ID (`aws_s3_bucket.websitegudisa.id`).

- **`index_document`**: Specifies the default page that will be served when users access the root URL of your static website.
  - **`suffix`**: Set to `"index.html"`, which means `index.html` will be used as the default landing page.

- **`error_document`**: Specifies the page that will be displayed when an error occurs (e.g., a 404 Not Found error).
  - **`key`**: Set to `"error.html"`, which means `error.html` will be shown for errors.

By setting up this configuration, you ensure that your S3 bucket will serve the specified default and error pages when hosting a static website.

#### Step 7: Upload Files to S3

To upload files to your S3 bucket, you can use Terraform’s `aws_s3_object` resource. This allows you to manage files directly within your Terraform configuration. Use a loop to handle multiple files efficiently.

Add the following configuration to your `main.tf` file:

```hcl
locals {
  files = {
    "index.html" = "index.html",
    "styles.css" = "styles.css"
  }
}

resource "aws_s3_object" "files" {
  for_each = local.files

  bucket       = aws_s3_bucket.websitegudisa.id
  key          = each.key
  source       = each.value
  acl          = "public-read"
  content_type = lookup({
    "index.html" = "text/html",
    "styles.css" = "text/css"
  }, each.key, "application/octet-stream")
}
```

- **`locals`**: Defines a local value `files` as a map, where each key is the name of the file to upload, and each value is the path to the file on your local machine.

- **`resource "aws_s3_object" "files"`**: Defines the S3 objects (files) to be uploaded to the bucket.
  - **`for_each`**: Iterates over the `local.files` map to upload each file specified.
  - **`bucket`**: Refers to the bucket created earlier by using its ID (`aws_s3_bucket.websitegudisa.id`).
  - **`key`**: The name of the file in the S3 bucket (from `each.key`).
  - **`source`**: The path to the local file to upload (from `each.value`).
  - **`acl`**: Set to `"public-read"` to make the files publicly accessible.
  - **`content_type`**: Specifies the MIME type of the file. Uses a lookup to set appropriate content types for HTML and CSS files, defaulting to `"application/octet-stream"` if the file type is not specified.

By using this configuration, you ensure that your static website files are uploaded to the S3 bucket and are accessible to users.

#### Step 8: Output the Bucket Information

To easily access the bucket name and the website URL after applying your Terraform configuration, you can define output values. This allows you to retrieve important information about your resources.

Add the following configuration to your `main.tf` file:

```hcl
output "bucket_name" {
  value = aws_s3_bucket.websitegudisa.bucket
}

output "website_url" {
  description = "The URL of the static website hosted in the S3 bucket."
  value       = "http://${aws_s3_bucket.websitegudisa.bucket}.s3-website-${var.region}.amazonaws.com"
}
```

- **`output "bucket_name"`**: Outputs the name of the S3 bucket created. This value can be useful for reference or in other configurations.

- **`output "website_url"`**: Outputs the URL where the static website is hosted. This URL is constructed using the bucket name and AWS region. The URL format is:
  - `"http://${aws_s3_bucket.websitegudisa.bucket}.s3-website-${var.region}.amazonaws.com"`

By defining these outputs, you provide easy access to the bucket name and the website URL, simplifying the process of accessing and managing your deployed static website.

---



---

#### Applying the Terraform Configuration

To deploy your static website configuration to AWS, follow these steps to apply your Terraform configuration. This process sets up the necessary AWS resources and makes your static website available.

1. **Initialize Terraform**

   Before applying the configuration, initialize your Terraform working directory. This command sets up the necessary files and downloads the required provider plugins.

   ```bash
   terraform init
   ```

   - **`terraform init`**: This command prepares your working directory for other Terraform commands. It initializes the backend, installs provider plugins, and configures the workspace.

2. **Create an Execution Plan**

   Review the changes that Terraform will make to your AWS infrastructure before applying them. This step ensures that your configuration behaves as expected.

   ```bash
   terraform plan
   ```

   - **`terraform plan`**: This command generates an execution plan, showing the changes Terraform will apply to your infrastructure. It helps you review the proposed modifications and verify that everything is correct before making any changes.

3. **Apply the Configuration**

   Apply your Terraform configuration to create and configure the AWS resources as defined in your `main.tf` and `variables.tf` files.

   ```bash
   terraform apply
   ```

   - **`terraform apply`**: This command applies the changes required to reach the desired state of the configuration. Terraform will prompt you to confirm the changes before proceeding.

   - **Confirm the changes when prompted**: Type `yes` to confirm and apply the changes. Terraform will then create and configure the resources as specified in your configuration files.

#### Conclusion

By following this guide, you have successfully configured an S3 bucket for static website hosting using Terraform. Here’s a summary of what you have accomplished:

- **Created an S3 Bucket**: Defined and provisioned an S3 bucket to host your static website.
- **Configured Public Access and ACLs**: Set up the bucket to allow public access and manage ownership controls.
- **Enabled Static Website Hosting**: Configured the bucket to serve static web content, specifying index and error documents.
- **Uploaded Website Files**: Used Terraform to upload your static website files, ensuring they are accessible to users.
- **Reviewed and Applied Configuration**: Initialized Terraform, reviewed the execution plan, and applied the configuration to deploy your resources.

Terraform’s infrastructure-as-code approach allows you to manage and provision your AWS resources in a repeatable and scalable manner. With this setup, you can easily extend your configuration to include additional features or integrate with other AWS services.

Feel free to modify and extend this configuration to suit your needs. Terraform’s flexibility provides powerful tools for managing your infrastructure efficiently and effectively.

---

