module "mysql_sg" {
    source = "git::https://github.com/soumya816-us/terraform-aws-security-group.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    sg_name = "mysql"
    sg_description = "created for Mysql instances in dev"
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    common_tags = var.common_tags

}
#created for backend purpose in dev

#created for bastion purpose in dev
module "bastion_sg" {
    source = "git::https://github.com/soumya816-us/terraform-aws-security-group.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    sg_name = "bastion"
    sg_description = "created for bastion instances in expense dev"
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    common_tags = var.common_tags

}
#open vpn ports are 22,443,1194,943
module "vpn_sg" {
    source = "git::https://github.com/soumya816-us/terraform-aws-security-group.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    sg_name = "vpn"
    sg_description = "created for bastion instances in expense dev"
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    common_tags = var.common_tags

}

#created for backend application load balancer security group
module "alb_ingress_sg" {
    source = "git::https://github.com/soumya816-us/terraform-aws-security-group.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    sg_name = "app_alb"
    sg_description = "created for application load balancer sg"
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    common_tags = var.common_tags

}

module "eks_control_plane_sg" {
    source = "git::https://github.com/soumya816-us/terraform-aws-security-group.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    sg_name = "eks-control-plane"
    sg_description = "created for application load balancer sg"
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    common_tags = var.common_tags

}

module "eks_node_sg" {
    source = "git::https://github.com/soumya816-us/terraform-aws-security-group.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    sg_name = "eks-node"
    sg_description = "created for application load balancer sg"
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    common_tags = var.common_tags

}

#all traffic from eks plane to eks node
resource "aws_security_group_rule" "eks_control_plane_node" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  source_security_group_id = module.eks_node_sg.sg_id
  security_group_id = module.eks_control_plane_sg.sg_id
}

#all traffic from eks node to eks plane
resource "aws_security_group_rule" "eks_node_eks_control_plane" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  source_security_group_id = module.eks_control_plane_sg.sg_id
  security_group_id = module.eks_node_sg.sg_id
}

#node accepting traffic from alb ingress
resource "aws_security_group_rule" "node_alb_ingress" {
  type              = "ingress"
  from_port         = 30000
  to_port           = 32767
  protocol          = "tcp"
  source_security_group_id = module.alb_ingress_sg.sg_id
  security_group_id = module.eks_node_sg.sg_id
}

resource "aws_security_group_rule" "node_vpc" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks = ["10.0.0.0/16"] #our private ip address range
  security_group_id = module.eks_node_sg.sg_id
}
#node accepting traffic from bastion host
resource "aws_security_group_rule" "node_bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.bastion_sg.sg_id
  security_group_id = module.eks_node_sg.sg_id
}

resource "aws_security_group_rule" "alb-ingress-bastion" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.bastion_sg.sg_id
  security_group_id = module.alb_ingress_sg.sg_id
}

resource "aws_security_group_rule" "alb-ingress-bastion-https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  source_security_group_id = module.bastion_sg.sg_id
  security_group_id = module.alb_ingress_sg.sg_id
}
#alb-ingress accepting traffic from public
resource "aws_security_group_rule" "alb-ingress-public-https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.alb_ingress_sg.sg_id
}


resource "aws_security_group_rule" "bastion-public" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.bastion_sg.sg_id
}


#accepting traffic from mysql to bastion
resource "aws_security_group_rule" "mysql_bastion" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = module.bastion_sg.sg_id
  security_group_id = module.mysql_sg.sg_id
}

resource "aws_security_group_rule" "mysql_eks_node" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = module.eks_node_sg.sg_id
  security_group_id = module.mysql_sg.sg_id
}

resource "aws_security_group_rule" "eks_control_plane_bastion" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  source_security_group_id = module.bastion_sg.sg_id
  security_group_id = module.eks_control_plane_sg.sg_id
}

resource "aws_security_group_rule" "eks_control_alb_ingress" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = module.alb_ingress_sg.sg_id
  security_group_id = module.eks_node_sg.sg_id
}

