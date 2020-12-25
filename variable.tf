variable "vpc_cidr" {
    default = "10.0.0.0/16"
}
variable     "public_subnet_cidrs" { 
    default = ["10.0.1.0/24"] 
    }
	
variable "public_subnet_azs" {
	default = ["ap-south-1a"]
	}
	


variable "ami_id"{
	default = "ami-04b1ddd35fd71475a"
	}

variable "instance_type"{
	default = "t2.micro"
}

variable "ec2_key_name" {
	default = ""
}
