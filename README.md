# basic-site-2020

This is my opinionated view of how to create and maintain a basic website using the following:

Service | Service Provider
---|---
Source Versioning | **Github.com** (git, PRs and other services)
Hosting | **AWS** (numerous services)
Provisioning | **Terraform Cloud** (IaC)

## Bootstrapping

### Github.com

1. Fork this repo on github.com and make public

### AWS

1. Create a fresh AWS account
1. Enable Access Key and configure your local `~/.aws/credentials` file with it as follows:

    ```ini
    [basic-site-2020-root]
    aws_access_key_id = XXXXX11111XXXXX11111
    aws_secret_access_key = abcdef/ghijklmno+pqrstuv/wxyz
    region = eu-west-1
    ```

1. Test it - make sure you get a valid response from:

    ```bash
    aws --profile basic-site-2020-root sts get-caller-identity
    ```

1. Create a user for Terraform Cloud and issue Access Keys

    ```bash
    export TF_USER=terraform.cloud ; \
    aws --profile basic-site-2020-root iam create-user --user-name ${TF_USER} && \
    aws --profile basic-site-2020-root iam wait user-exists --user-name ${TF_USER} && \
    aws --profile basic-site-2020-root iam create-access-key --user-name ${TF_USER}
    ```

1. Add `AccessKeyId` and `SecretAccessKey` to `~/.aws/credentials` as above, with profile name `basic-site-2020-root`
1. Test it - make sure you get a valid response from:

    ```bash
    aws --profile basic-site-2020-terraform sts get-caller-identity
    ```

1. Create an IAM group, give full admin rights to it, and add the `terraform.cloud` user to it

    ```bash
    export TF_USER=terraform.cloud ; \
    aws --profile basic-site-2020-root iam create-group --group-name Admins && \
    aws --profile basic-site-2020-root iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AdministratorAccess --group-name Admins && \
    aws --profile basic-site-2020-root iam add-user-to-group --user-name ${TF_USER} --group-name Admins
    ```

1. Test it - make sure you get a valid response from:

    ```bash
    export TF_USER=terraform.cloud ; \
    aws --profile basic-site-2020-terraform iam get-user --user-name ${TF_USER}
    ```

1. Remove root access key from `~/.aws/credentials` and follow the steps in `Security Status` at
https://console.aws.amazon.com/iam/home to lock down the rest of the account.

### Terraform Cloud (TFC)

1. Create a free account
1. Create a `basic-site-2020` workspace
1. Point VCS at the github repo created above.
1. Create the following environment variables

    Key | Value | Sensitive
    ---|---|---
    AWS_ACCESS_KEY_ID | <terraform.cloud aws_access_key_id> | True
    AWS_SECRET_ACCESS_KEY | <terraform.cloud aws_secret_access_key> | True
    AWS_DEFAULT_REGION | <Your local AWS zone, in my case: eu-west-1> | False

1. Queue a plan, check it and if it looks ok then apply.

## Deploy changes

If you are going to author your content in this repository, then you will need to the remove the `ignore_changes` block
of the static content object.  Deploying changes is then as easy as making changes to the default branch in this
repository via whichever git process you prefer.

## Additional config

### Scaling

Cloudfront and S3 should suffice for scaling of users, however as you scale content, you should consider splitting paths
out into one or more repositories.

To make things easier, each repository should concern itself with a single path, e.g.
<https://yoursite.com/products> or <https://yoursite.com/services> could have a repository each. You could then look at
dynamically generating the root `index.html` via a lambda function or similar.

### Friendly DNS

To make the site easier to use, you can put a friendly name on the domain through a series of delegated DNS to Route53
and creating a cert in AWS ACM with DNS validation.

### Safer changes

To make changes safer, you can create an additional TFC workspace for testing changes in, this can be based off a
different git branch than the default branch provided, or using variables and versioned modules within Terraform.
