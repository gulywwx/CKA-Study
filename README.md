## Lab

### 1. AWS

The current EC2/Terraform approach allows for scalable and reproducible deployments. Below is an overview of the steps involved:

1. Set up your AWS account and configure your IAM permissions.
2. Use Terraform to define your infrastructure as code.
3. Deploy your EC2 instances based on your Terraform configurations.

### 2. Vagrant

For a local setup, Vagrant with VirtualBox offers an easy way to create and configure lightweight, reproducible environments. Below is a minimal example of a Vagrantfile to get you started:

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"
  config.vm.network "forwarded_port", guest: 80, host: 8080
end
```

Follow these instructions:
1. Install Vagrant and VirtualBox.
2. Create a directory for your Vagrant project.
3. Save the Vagrantfile in this directory.
4. Run `vagrant up` to start your virtual machine.
5. Access your application via `http://localhost:8080`.  

This provides two effective ways of working with environments, whether leveraging cloud resources or running locally with Vagrant. 

