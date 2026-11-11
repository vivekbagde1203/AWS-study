Our architecture will use:
- AWS Region: ap-south-1 (Mumbai), assuming your account supports the required services and quotas.
- Availability Zones: Three AZs.
- Networking: Dedicated VPC, public/private subnets, routing, NAT gateways, and VPC endpoints.
- Compute: Private EKS managed node groups using EC2 launch templates.
- Ingress: Internet-facing ALB with AWS Load Balancer Controller.
- Security: IAM least privilege, EKS Pod Identity, KMS, security groups, Kubernetes RBAC, and network policies.
- Storage: EBS CSI driver with encrypted persistent volumes.
- Scaling: HPA and Karpenter, with separate bootstrap node capacity.
- Deployment: Terraform, Helm, and Argo CD.
- Observability: CloudWatch, Prometheus, Grafana, and OpenTelemetry.
- Reliability: Multi-AZ scheduling, PodDisruptionBudgets, health checks, and recovery testing.
Important: A production-grade architecture doesn't mean enabling every AWS service. It means choosing the correct components for your application's availability, security, performance, recovery, and cost requirements.

Your project is already organized into:
terraform/
├── env/
│   └── dev/
│       ├── main.tf
│       ├── provider.tf
│       ├── variable.tf
│       ├── terraform.tfvars
│       └── output.tf
│
└── modules/
    ├── vpc/
    ├── iam/
    ├── eks/
    └── nodegroup/

Critical issues I found
Issue 1 — Your EKS API endpoint is publicly accessible
Issue 2 — Your Node Group module is completely empty
Issue 3 — Your Terraform state is stored locally
Do not commit these files to GitHub or distribute the archive publicly.

For our project, we will use:
- S3 remote state.
- State encryption.
- Bucket versioning.
- Terraform state locking.
- IAM-based access restrictions.
- State recovery procedures.
Issue 4 — Your Kubernetes version needs review
kubernetes_version = "1.32.0" --> kubernetes_version = "1.32"
Issue 5 — Your networking is missing production components
For Project 1, we will introduce:
- Three-AZ architecture.
- Three isolated database subnets.
- Explicit subnet tagging for load balancers.
- VPC endpoints for selected AWS services.
- VPC Flow Logs.
- Security group design.
- DNS validation.
- NAT gateway cost controls.
- Network connectivity testing.

Issue 6 — IAM permissions need improvement
Exact files we need to modify
Here is our implementation plan based on your existing project.
File	Required changes
env/dev/main.tf	Connect new modules, add configuration inputs
env/dev/provider.tf	Pin Terraform/AWS provider versions and configure remote backend
env/dev/terraform.tfvars	Update subnets, cluster settings, tags, NAT mode
env/dev/variable.tf	Add typed variables and validation
env/dev/output.tf	Add cluster, node group, networking outputs
modules/vpc/main.tf	Add third AZ, isolated subnets, tagging, endpoints, Flow Logs
modules/vpc/variable.tf	Add network configuration variables
modules/vpc/output.tf	Export subnet maps and route information
modules/iam/main.tf	Separate cluster, node, and add-on permissions
modules/eks/main.tf	Configure endpoint access, logging, encryption, access entries
modules/nodegroup/main.tf	Implement managed node groups and launch templates
modules/nodegroup/variable.tf	Configure capacity, instance types, labels, scaling
modules/nodegroup/output.tf	Export node group information

One architectural improvement I recommend
terraform/
├── bootstrap/
│
├── env/
│   ├── dev/          # Preserve existing work
│   └── prod-lab/     # New enterprise EKS platform
│
└── modules/
    ├── vpc/
    ├── iam/
    ├── eks/
    ├── nodegroup/
    ├── security/
    ├── vpc-endpoints/
    └── observability/

Date: 11Nov2026
eks-enterprise/
├── bootstrap/
│   ├── versions.tf
│   ├── variables.tf
│   └── main.tf
│
├── env/
│   ├── dev/
│   │   └── existing Terraform files
│   └── prod-lab/
│       ├── versions.tf
│       ├── variables.tf
│       ├── main.tf
│       └── outputs.tf
│
├── modules/
│   ├── vpc/
│   │   ├── main.tf
│   │   ├── variable.tf
│   │   └── output.tf
│   ├── iam/
│   ├── eks/
│   └── nodegroup/
│
└── README.md

Upgrade your VPC from 2 AZs to 3 AZs
public_a  = "10.0.0.0/19"
public_b  = "10.0.32.0/19"

private_a = "10.0.64.0/19"
private_b = "10.0.96.0/19"

In public add one more AZ and same add in private as well

public_c = {
  cidr_block        = "10.0.128.0/19"
  availability_zone = "ap-south-1c"
  nat_gateway_key   = "public_c"
}


In Private
private_c = {
  cidr_block        = "10.0.160.0/19"
  availability_zone = "ap-south-1c"
  nat_gateway_key   = "public_c"
}

The final subnet allocation for this exercise will be:

Subnet	        CIDR	        AZ
Public A	10.0.0.0/19	1a
Public B	10.0.32.0/19	1b
Public C	10.0.128.0/19	1c
Private A	10.0.64.0/19	1a
Private B	10.0.96.0/19	1b
Private C	10.0.160.0/19	1c

These six subnets fit within 10.0.0.0/16 without overlapping.
For now, our existing modules/vpc/main.tf supports this change because it already uses for_each. It will automatically plan additional subnets, a NAT gateway, and associated routes.
