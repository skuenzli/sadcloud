# Config-only modules (near-zero cost)
all_cloudformation_findings = true
all_cloudtrail_findings = true
all_cloudwatch_findings = true
# Config recorder already exists in demo-1; skip to avoid conflict
all_config_findings = false
all_ebs_findings = true
all_ec2_sg_findings = true
all_ecr_findings = true
all_kms_findings = true
all_s3_findings = true
all_sns_findings = true
all_sqs_findings = true

# IAM skipped: existing privesc users already cover IAM findings
all_iam_findings = false

# Expensive modules (disabled - require always-on resources)
all_findings = false
all_ec2_findings = false
all_eks_findings = false
all_elasticsearch_findings = false
all_elb_findings = false
all_elbv2_findings = false
all_lightsail_findings = false
all_rds_findings = false
all_redshift_findings = false
all_ses_findings = false
