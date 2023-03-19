# Get Started

## Tools

To get started, make sure you have installed the following tools.

1. [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

2. [pre-commit](https://pre-commit.com/)

3. [black](https://github.com/psf/black)

## Pre-commit Hooks

To ensure quality in the code, we utilize pre-commit hooks using the [pre-commit](https://pre-commit.com/) tool. To install the pre-commit configurations, run the following command.

```
pre-commit install
```

In case the hooks fail, make sure you have formatted the repository through the following commands in the root directory.

```
black .
terraform fmt -recursive
```

## Deployment

To deploy the Data Warehoue infrastructure, create a secrets.tfvars file using the secrets.dist.tfvars as a template and run the following command.

```
terraform apply --var-file=secrets.tfvars
```

Terraform will deploy the AWS infrastructure as well as the ingestion Lambda application. The Lambda application's code will be copied to a new directory, its dependencies will be installed in the same directory and then the directory will be zipped and uploaded to AWS Lambda.

To destroy the Data Warehoue infrastructure, run the following command.

```
terraform destroy --var-file=secrets.tfvars
```
