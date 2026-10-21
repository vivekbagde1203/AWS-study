How we will deploy it
1. Build the VPC foundation
   
   Create the VPC, two AZs, public and private subnets, Internet Gateway, NAT Gateway, and route tables.
2. Configure security
   
   Create separate ALB, EC2, and RDS security groups. Use Systems Manager Session Manager instead of exposing SSH to the internet.
3. Deploy the database and storage
   
   Create private PostgreSQL RDS, the S3 bucket with SSE-KMS and versioning, and an EC2 IAM role with least-privilege permissions.
4. Deploy DevVerse on private EC2
   
   Install Nginx and Flask, configure the database connection, and verify the application locally from the instance.
5. Add the Load Balancer
   
   Create the target group, configure /api/health, register the EC2 targets, and access the application through the ALB DNS name.
6. Automate with Auto Scaling
   
   Create the launch template and ASG, set a desired capacity of two across the AZs, and test instance replacement and scaling.
7. Run student experiments
   
   Add tasks, upload files, generate requests, inspect target health, stop an instance, and observe recovery.
