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


By the end of the project, students should be able to demonstrate all of these:
- [ ] The application EC2 instances have no public IP addresses.
- [ ] The ALB routes requests to healthy private instances.
- [ ] The database remains available when an application instance is replaced.
- [ ] Auto Scaling launches a replacement instance when required.
- [ ] IAM permissions allow approved S3 uploads without static credentials.
- [ ] S3 encryption, versioning, and access restrictions work as intended.
- [ ] EBS volumes are encrypted.
- [ ] The private subnet route and NAT Gateway allow outbound access without exposing EC2 directly.

Each /19 subnet increments the second octet's value by 32 in the third octet:
Subnet	  CIDR-Address  range
Subnet 1	10.0.0.0/19	  10.0.0.0 – 10.0.31.255
Subnet 2	10.0.32.0/19	10.0.32.0 – 10.0.63.255
Subnet 3	10.0.64.0/19	10.0.64.0 – 10.0.95.255
Subnet 4	10.0.96.0/19	10.0.96.0 – 10.0.127.255
Subnet 5	10.0.128.0/19	10.0.128.0 – 10.0.159.255
Subnet 6	10.0.160.0/19	10.0.160.0 – 10.0.191.255
Subnet 7	10.0.192.0/19	10.0.192.0 – 10.0.223.255
Subnet 8	10.0.224.0/19	10.0.224.0 – 10.0.255.255
That gives us exactly 8 non-overlapping /19 subnets within the VPC.


Route tables we need
Route table	        Default route	              Associated subnets
devverse-public-rt	0.0.0.0/0 → IGW	            Both public subnets
devverse-app-rt-a	  0.0.0.0/0 → NAT-A	          App Private AZ-A
devverse-app-rt-b	  0.0.0.0/0 → NAT-B	          App Private AZ-B
devverse-db-rt	    No internet default route	  Both DB subnets

Let's create the VPC
VPC with CIDR 10.0.0.0/16, enable DNS resolution and DNS hostnames, and then create these six subnets in their respective Availability Zones.

Let's create the six subnets
In the AWS Console, open VPC → Subnets → Create subnet.

Select your VPC: 10.0.0.0/16 and your chosen AWS Region. Create these subnets, selecting the corresponding Availability Zone for each.

Subnet name	            IPv4 CIDR	    Availability Zone
devverse-public-a	      10.0.0.0/19	  AZ-A
devverse-public-b	      10.0.32.0/19	AZ-B
devverse-app-private-a	10.0.64.0/19	AZ-A
devverse-app-private-b	10.0.96.0/19	AZ-B
devverse-db-private-a	  10.0.128.0/19	AZ-A
devverse-db-private-b	  10.0.160.0/19	AZ-B
Choose two different Availability Zones for AZ-A and AZ-B. Use those same two AZs consistently for the application and database subnets.

Important settings
- Keep all six subnets in the same VPC.
- Leave auto-assign public IPv4 disabled on the private application and database subnets.
- We'll configure public IP behavior and routing for the public subnets separately.

Verify your subnets
Once created, open VPC → Subnets and confirm that all six subnets show the correct CIDRs and VPC ID.

Create and attach an Internet Gateway (IGW)
Follow these steps in the AWS Console
1. Open VPC → Internet gateways.
2. Click Create internet gateway.
3. Set the name tag to devverse-igw.
4. Click Create internet gateway.
5. Select devverse-igw, choose Actions → Attach to a VPC.
6. Select your DevVerse VPC (10.0.0.0/16) and confirm the attachment.

Verify the result
Your Internet Gateway should show:
- Name: devverse-igw
- State: Attached
- VPC: Your DevVerse VPC

Create the public route table
Think of a route table as a GPS for network traffic. It tells AWS where to send packets when they leave a subnet.

Follow these steps in AWS Console
1. Open VPC → Route tables.
2. Click Create route table.
3. Enter the name devverse-public-rt.
4. Select your DevVerse VPC (10.0.0.0/16) and create it.
5. Open the new route table, select Routes → Edit routes → Add route.
6. Set the destination to 0.0.0.0/0 and the target to your devverse-igw Internet Gateway.
7. Save changes.

Associate both public subnets
In the same route table, open Subnet associations → Edit subnet associations and select:
- devverse-public-a — 10.0.0.0/19
- devverse-public-b — 10.0.32.0/19
Save the associations.

Verify your routes
Your route table should now contain these two routes:
Destination	Target
10.0.0.0/16	local
0.0.0.0/0	devverse-igw
The first route is created automatically by AWS. The second is the route you added.

Create Elastic IP addresses (2)
Create the NAT Gateway (2)

Configure the private application route tables
We'll create two separate route tables, one for each Availability Zone. This keeps outbound traffic within its own AZ during normal operation.


Private App AZ-A 10.0.64.0/19
devverse-app-rt-a
10.0.0.0/16 local
0.0.0.0/0 NAT-A
Public AZ-A → NAT Gateway A → Internet Gateway

Private App AZ-B 10.0.96.0/19
10.0.0.0/16 local
0.0.0.0/0  NAT-B
Public AZ-B → NAT Gateway B → Internet Gateway

Part A — Create route table A
1. Open VPC → Route tables → Create route table.
2. Name: devverse-app-rt-a
3. Select your DevVerse VPC.
4. Create the route table.
5. Open Routes → Edit routes → Add route.
6. Destination: 0.0.0.0/0
7. Target: select NAT Gateway → devverse-nat-a.
8. Save changes.
9. Open Subnet associations → Edit subnet associations.
10. Select only devverse-app-private-a (10.0.64.0/19) and save.

Part B — Create route table B
Repeat with these settings:
Setting	            Value
Route table	        devverse-app-rt-b
Default route	      0.0.0.0/0
Target	            devverse-nat-b
Associated subnet	  devverse-app-private-b (10.0.96.0/19)
Do not associate the database subnets with either application route table.


Verify the configuration
Destination	App RT-A	 App RT-B
10.0.0.0/16	Local	     Local
0.0.0.0/0	  NAT-A	     NAT-B

Why are we doing this? When an EC2 instance in AZ-A downloads a package, the request goes through NAT-A. The NAT Gateway translates the source address for internet communication, and the response returns through the established connection. The EC2 instance still has no public IP address.

