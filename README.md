# aws-terraform-fms-put-apps-list
This repo provides a demonstration of how to execute a custom AWS CLI command from Terraform to create an AWS Firewall Manager Application List.

## Prerequisites
Make sure your account has the ability to configure AWS Firewall Manager.  Follow the steps defined in the blog post [here](https://aws.amazon.com/blogs/security/use-aws-firewall-manager-to-deploy-protection-at-scale-in-aws-organizations/).

## AWS CLI Test
Once you have confirmed the necessary setup to access and configure AWS Firewall Manager we can test it via the AWS CLI.  We will run a command to create an Application List.  Then we will remove it.  If both steps are successful you can continue on to the Terraform Example section below.

1. Using the AWS CLI create the AWS Firewall Manager Application List.  Verify the Application List was created from the AWS Console before continuing on to the following steps.

```
aws fms put-apps-list --apps-list 'ListName="DJL DEMO APPS LIST",AppsList=[{AppName=MySQL,Protocol=TCP,Port=3306}]'
```

2. Using the output json from step #1 copy the ListId UUID.  Or you can run the following command to get the ListId if you didn't change the List Name in step 1.
```
export DEMO_FMS_LIST_ID=`aws fms list-apps-lists --max-results 5 | jq -r '.AppsLists[] | select(.ListName == "DJL DEMO APPS LIST") | .ListId'`
```

3. AWS CLI, delete the AWS Firewall Manager Application List that we created in Step 1.  After running the command below the Application List should be delete. Verify via the AWS console.
```
aws fms delete-apps-list --list-id ${DEMO_FMS_LIST_ID}
```

4. Clean up envornment. Unset the Environment variable created in step 2
```
unset DEMO_FMS_LIST_ID
```

## Terraform Custom AWS CLI Example
I provided a simple example of what it looks like to run the custom AWS CLI commands we ran above the the previous section.  Here is a link to a pretty interesting post on the subject [Invoking the AWS CLI with Terraform](https://faun.pub/invoking-the-aws-cli-with-terraform-4ae5fd9de277).
1. Initalize the Terraform environment
```
terraform init
```

2. Apply the changes to run the custom AWS CLI Command.  It should create two terraform resources, 1) create-demo-fms-apps-list: which will execute the similar CLI command line statement in step 1.  2) output-id: which will output the ID to a text file called "id.log".
```
terraform apply
```

3. To delete the resource you need to implement logic to delete it when you need to. Simply running `terraform destroy` will not have any effect in cleaning up the AWS resource.  If you look at the `main.tf` file you will find a resource called `delete-demo-fms-apps-list` which has a logical condition defined in the `count` parameter.  If `delete == "false"` count will be set to 1 and it will attempt to run the command to remove the resource.

4. To delete the resources on the terraform side you will still need to run the destroy command.
```
terraform destroy
```

## Questions & Comments
If you have any questions or comments on the demo please reach out to me [Devin Lewis - AWS Solutions Architect](mailto:lwdvin@amazon.com?subject=AWS%2FTerraform%20FMS%20Create%20Application%20List%20%28aws-terraform-fms-put-apps-list%29)

Of if you would like to provide personal feedback to me please click [Here](https://feedback.aws.amazon.com/?ea=lwdvin&fn=Devin&ln=Lewis)

