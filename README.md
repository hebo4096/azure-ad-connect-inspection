# azure-ad-connect-inspection
deploy azure ad connect environment on azure by terraform.

## how to deploy
```
# initialization for terraform code
terraform init

# make sure your configuration works.
terraform plan

# set your deploy.
terraform apply
```
## configurations
1. set up your custom domain on azure ad connect.

2. set your parameters when you apply.
    - admin_password
        - password of admin user for Active Directory.
    - admin_username
        - username of admin user for Active Directory.
    - admin_username
    - custom_domain
        - custom domain set on your Azure AD environment.
    - location
        - region to set this environment.
    - prefix
        - resource names will be named with this value in head.
        - ex. if you set bohebohe as prefix, your resource group name will be "bohebohe-rg".
    - your_home_ip
        - Global IP Address used.
        - setting several Global IP is currently not supported.

3. set up your azure ad connect on the deployed aadc server.
    - note: your NetBIOS used to login will be set to the custom_domain strings before the dots
        - ex. if you set bohebohe.com as custom_domain, bohebohe will be your NetBIOS.
