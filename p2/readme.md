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
