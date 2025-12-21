#S3 bucket creation for source code 
resource "aws_s3_bucket" "eb_source_code" {
    bucket = var.bucket_name
    tags = {
        name = "eb-source-code"
    }
}

#object upload
resource "aws_s3_object" "s3_obj_upload" {
    for_each = toset(var.file_upload)
    bucket = aws_s3_bucket.eb_source_code.id
    source = "${path.module}/${each.value}/${each.value}.zip"
    key = "${each.value}.zip"    
}

#Elastic Beanstalk application creation
resource "aws_elastic_beanstalk_application" "eb_web_app" {
    name = "web_app_eb_app"
    description = "Terraform practice - blue green deployment strategy"
    tags = {
        Name = "Web-app-EB"
        Environment = "Development"
    }
}

#EB application version creation -> (blue or green based on the no of deployment were done.)
resource "aws_elastic_beanstalk_application_version" "blue_env_version" {
    application = aws_elastic_beanstalk_application.eb_web_app.name
    bucket = aws_s3_bucket.eb_source_code.id
    key = "app_v1.zip"
    name = "blue_version"
    depends_on = [aws_s3_object.s3_obj_upload]
}

#EB application version creation -> (blue or green based on the no of deployment were done.)
resource "aws_elastic_beanstalk_application_version" "green_env_version" {
    application = aws_elastic_beanstalk_application.eb_web_app.name
    bucket = aws_s3_bucket.eb_source_code.id
    key = "app_v2.zip"
    name = "green_version-v2"
    depends_on = [aws_s3_object.s3_obj_upload]
}

#EB environment creation -> blue
resource "aws_elastic_beanstalk_environment" "blue_environment" {
    name = "web-app-eb-blue"
    application = aws_elastic_beanstalk_application.eb_web_app.name
    description = "This is blue environment"
    tier = "WebServer"
    solution_stack_name = "64bit Amazon Linux 2023 v6.7.1 running Node.js 20"
    version_label = aws_elastic_beanstalk_application_version.blue_env_version.name
    
    #VPC and Subnet configuration for both EC2 and ELB
    setting {
        namespace = "aws:ec2:vpc"
        name = "VPCId"
        value = aws_vpc.app_vpc.id 
    }

    setting {
        namespace = "aws:ec2:vpc"
        name = "Subnets"
        value = join(",", [for subnet in aws_subnet.public-subnets : subnet.id])
    }

    setting {
        namespace = "aws:ec2:vpc"
        name = "ELBSubnets"
        value = join(",", [for subnet in aws_subnet.public-subnets : subnet.id])
    }

    setting {
        namespace = "aws:ec2:vpc"
        name = "ELBScheme"
        value = "public"
    }

    #Instance and ASG configuration
    setting {
        namespace = "aws:autoscaling:launchconfiguration"
        name = "InstanceType"
        value = "t2.micro"
    }

    setting {
        namespace = "aws:autoscaling:launchconfiguration"
        name = "IamInstanceProfile"
        value = aws_iam_instance_profile.ec2_instance_profile.name
    }

    setting {
        namespace = "aws:autoscaling:asg"
        name = "MinSize"
        value = 1
    }

    setting {
        namespace = "aws:autoscaling:asg"
        name = "MaxSize"
        value = 2
    }

    #Health check configuration
    setting {
        namespace = "aws:elasticbeanstalk:environment:process:default"
        name = "HealthCheckInterval"
        value = 30
    }

    setting {
        namespace = "aws:elasticbeanstalk:environment:process:default"
        name = "HealthCheckPath"
        value = "/"
    }

    setting {
        namespace = "aws:elasticbeanstalk:environment:process:default"
        name = "HealthyThresholdCount"
        value = 5
    }

    setting {
        namespace = "aws:elasticbeanstalk:environment:process:default"
        name = "UnhealthyThresholdCount"
        value = 5
    }

    setting {
        namespace = "aws:elasticbeanstalk:environment:process:default"
        name = "Protocol"
        value = "HTTP"
    }

    setting {
        namespace = "aws:elasticbeanstalk:environment:process:default"
        name = "Port"
        value = 8080  # application listening port
    }

    #Health report configuration
    # setting {
    #     namespace = "aws:elasticbeanstalk:healthreporting:system"
    #     name      = "SystemType"
    #     value     = "enhanced"
    # }

    # availability perspective configuration
    setting {
        namespace = "aws:elasticbeanstalk:environment"
        name = "EnvironmentType"
        value = "LoadBalanced"
    }

    setting {
        namespace = "aws:elasticbeanstalk:environment"
        name = "LoadBalancerType"
        value = "application"
    }

    setting {
        namespace = "aws:elasticbeanstalk:environment"
        name = "LoadBalancerIsShared"
        value = false #EB will create dedicated lb for this environment not used in shared way.
    }

    # setting {
    #     namespace = "aws:elasticbeanstalk:environment"
    #     name = "ServiceRole"
    #     value = 
    # }

    #configure deployment behaviors
    setting {
        namespace = "aws:elasticbeanstalk:command"
        name = "DeploymentPolicy"
        value = "Rolling"
    }

    setting {
        namespace = "aws:elasticbeanstalk:command"
        name = "BatchSizeType"
        value = "Percentage"
    }

    setting {
        namespace = "aws:elasticbeanstalk:command"
        name = "BatchSize"
        value = 50
    }
}


#EB environment creation -> green
resource "aws_elastic_beanstalk_environment" "green_environment" {
    name = "web-app-eb-green"
    application = aws_elastic_beanstalk_application.eb_web_app.name
    description = "This is green environment"
    tier = "WebServer"
    solution_stack_name = "64bit Amazon Linux 2023 v6.7.1 running Node.js 20"
    version_label = aws_elastic_beanstalk_application_version.green_env_version.name
    
    #VPC and Subnet configuration for both EC2 and ELB
    setting {
        namespace = "aws:ec2:vpc"
        name = "VPCId"
        value = aws_vpc.app_vpc.id 
    }

    setting {
        namespace = "aws:ec2:vpc"
        name = "Subnets"
        value = join(",", [for subnet in aws_subnet.public-subnets : subnet.id])
    }

    setting {
        namespace = "aws:ec2:vpc"
        name = "ELBSubnets"
        value = join(",", [for subnet in aws_subnet.public-subnets : subnet.id])
    }

    setting {
        namespace = "aws:ec2:vpc"
        name = "ELBScheme"
        value = "public"
    }

    #Instance and ASG configuration
    setting {
        namespace = "aws:autoscaling:launchconfiguration"
        name = "InstanceType"
        value = "t2.micro"
    }

    setting {
        namespace = "aws:autoscaling:launchconfiguration"
        name = "IamInstanceProfile"
        value = aws_iam_instance_profile.ec2_instance_profile.name
    }

    setting {
        namespace = "aws:autoscaling:asg"
        name = "MinSize"
        value = 1
    }

    setting {
        namespace = "aws:autoscaling:asg"
        name = "MaxSize"
        value = 2
    }

    #Health check configuration
    setting {
        namespace = "aws:elasticbeanstalk:environment:process:default"
        name = "HealthCheckInterval"
        value = 30
    }

    setting {
        namespace = "aws:elasticbeanstalk:environment:process:default"
        name = "HealthCheckPath"
        value = "/"
    }

    setting {
        namespace = "aws:elasticbeanstalk:environment:process:default"
        name = "HealthyThresholdCount"
        value = 5
    }

    setting {
        namespace = "aws:elasticbeanstalk:environment:process:default"
        name = "UnhealthyThresholdCount"
        value = 5
    }

    setting {
        namespace = "aws:elasticbeanstalk:environment:process:default"
        name = "Protocol"
        value = "HTTP"
    }

    setting {
        namespace = "aws:elasticbeanstalk:environment:process:default"
        name = "Port"
        value = 8080  # application listening port
    }

    #Health report configuration
    # setting {
    #     namespace = "aws:elasticbeanstalk:healthreporting:system"
    #     name      = "SystemType"
    #     value     = "enhanced"
    # }

    # availability perspective configuration
    setting {
        namespace = "aws:elasticbeanstalk:environment"
        name = "EnvironmentType"
        value = "LoadBalanced"
    }

    setting {
        namespace = "aws:elasticbeanstalk:environment"
        name = "LoadBalancerType"
        value = "application"
    }

    setting {
        namespace = "aws:elasticbeanstalk:environment"
        name = "LoadBalancerIsShared"
        value = false #EB will create dedicated lb for this environment not used in shared way.
    }

    # setting {
    #     namespace = "aws:elasticbeanstalk:environment"
    #     name = "ServiceRole"
    #     value = 
    # }

    #configure deployment behaviors
    setting {
        namespace = "aws:elasticbeanstalk:command"
        name = "DeploymentPolicy"
        value = "Rolling"
    }

    setting {
        namespace = "aws:elasticbeanstalk:command"
        name = "BatchSizeType"
        value = "Percentage"
    }

    setting {
        namespace = "aws:elasticbeanstalk:command"
        name = "BatchSize"
        value = 50
    }
}
