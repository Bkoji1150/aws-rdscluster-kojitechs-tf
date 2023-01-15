
# data "aws_ami" "ami" {
#   most_recent = true

#   owners = ["amazon"]

#   filter {
#     name   = "name"
#     values = ["amzn2-ami-kernel-5.10-hvm-*-gp2"]
#   }

#   filter {
#     name   = "root-device-type"
#     values = ["ebs"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }
# }

# resource "aws_iam_role" "ssm_fleet_instance" {
#   name = "${var.component_name}-ssm-234-role"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Sid    = ""
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         }
#       },
#     ]
#   })
#   tags = {
#     Name = "${var.component_name}-ssm-234-role"
#   }
# }

# resource "aws_iam_instance_profile" "instance_profile" {
#   name = "${var.component_name}-ssm-fleet23d-instance-profile"
#   role = aws_iam_role.ssm_fleet_instance.name
# }

# resource "aws_iam_policy" "policy" {
#   name        = "${var.component_name}-ssm-ew3-policy"
#   description = "allow ecs instance to be managed by ssm"
#   policy      = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": [
#          "ssm:UpdateInstanceInformation",
#           "ssmmessages:CreateControlChannel",
#           "ssmmessages:CreateDataChannel",
#           "ssmmessages:OpenControlChannel",
#           "ssmmessages:OpenDataChannel"
#       ],
#       "Resource": "*",
#       "Effect": "Allow"
#     }   
#   ]
# }
# EOF
# }

# resource "aws_iam_role_policy_attachment" "ec2_policy_attach" {
#   role       = aws_iam_role.ssm_fleet_instance.name
#   policy_arn = aws_iam_policy.policy.arn
# }

# resource "aws_security_group" "jumber_sever" {
#   name        = "${var.component_name}-jumber_sever"
#   description = "allow ec2 to db"
#   vpc_id      = local.vpc_id
#   lifecycle {
#     create_before_destroy = true
#   }
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "${var.component_name}-jumber-sever"
#   }
# }
# resource "aws_instance" "jumber_sever" {
#   ami                    = data.aws_ami.ami.id
#   instance_type          = "t2.xlarge"
#   subnet_id              = local.private_subnets_ids[0]
#   vpc_security_group_ids = [aws_security_group.jumber_sever.id]
#   iam_instance_profile   = aws_iam_instance_profile.instance_profile.name

#   tags = {
#     Name = "${var.component_name}-jumbersever"
#   }
# }
