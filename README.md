# REPO IS WIP!
This repository has two main components:

Discord Bot: A Python discord bot allows users to instantly provision a Squad server (minus actual provisioning time) through a Discord interface.
Infrastructure as Code (IaC): The backend infrastructure code used to provision the Squad servers on AWS. This is written in a declarative IaC language like Terraform or CloudFormation.

The Discord bot acts as a convenient frontend to trigger the server provisioning process. The IaC portion handles defining and managing the AWS resources needed to deploy a Squad server. Together, they enable easy, on-demand Squad server deployment via Discord.


### Setup:
- Install terraform on your machine
- Change occurances of "BrianJune2023.pem", replace with existing keypair name for your AWS instance.
- Change config files from default squad configs/replace with your settings,

### Todo:
- Increase preparation time (NOW: ~9 minutes to live server)
    - Attempt to cut down time by provisioning from an AMI with updated squad.
- Proper security group settings (literally opened all ports + ssh atm)
- Additional support for other cloud providers (Google Cloud Compute, Alibaba, etc)
- Make specific changes for configuration files, specific changes, being able to add an admin/whitelist **via the discord bot**

