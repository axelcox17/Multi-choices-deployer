provider "aws" {
	region = "eu-west-3"
}

resource "aws_vpc" "<##INFRA_NAME##>-vpc" {
	cidr_block = "10.0.0.0/16"

	tags = {
		Name = "<##INFRA_NAME##>-vpc"
	}
}

resource "aws_subnet" "<##INFRA_NAME##>-pub" {
	vpc_id = "${aws_vpc.<##INFRA_NAME##>-vpc.id}"
	cidr_block = "10.0.1.0/24"

	tags = {
		Name = "<##INFRA_NAME##>-pub"
	}
}

resource "aws_subnet" "<##INFRA_NAME##>-priv" {
	vpc_id = "${aws_vpc.<##INFRA_NAME##>-vpc.id}"
	cidr_block = "10.0.2.0/24"
	
	tags = {
		Name = "<##INFRA_NAME##>-priv"
	}
}

resource "aws_internet_gateway" "<##INFRA_NAME##>-igw" {
	vpc_id = "${aws_vpc.<##INFRA_NAME##>-vpc.id}"

	tags = {
		Name = "<##INFRA_NAME##>-igw"
	}
}

resource "aws_eip" "<##INFRA_NAME##>-nateip" {
	vpc = true	
}

resource "aws_nat_gateway" "<##INFRA_NAME##>-natgw" {
	subnet_id = "${aws_subnet.<##INFRA_NAME##>-pub.id}"
	allocation_id = "${aws_eip.<##INFRA_NAME##>-nateip.id}"

	tags = {
		Name = "<##INFRA_NAME##>-natgw"
	}
}

resource "aws_route" "<##INFRA_NAME##>-defroute" {
	route_table_id = "${aws_vpc.<##INFRA_NAME##>-vpc.default_route_table_id}"
	destination_cidr_block = "0.0.0.0/0"
	gateway_id = "${aws_internet_gateway.<##INFRA_NAME##>-igw.id}"
}

resource "aws_route_table" "<##INFRA_NAME##>-privrtb" {
	vpc_id = "${aws_vpc.<##INFRA_NAME##>-vpc.id}"

	route {
		cidr_block = "0.0.0.0/0"
		nat_gateway_id = "${aws_nat_gateway.<##INFRA_NAME##>-natgw.id}"
	}
}

resource "aws_route_table_association" "<##INFRA_NAME##>-privrtb-assoc" {
	route_table_id = "${aws_route_table.<##INFRA_NAME##>-privrtb.id}"
	subnet_id = "${aws_subnet.<##INFRA_NAME##>-priv.id}"
}

resource "aws_security_group" "<##INFRA_NAME##>-SG-ADM" {
	name = "<##INFRA_NAME##>-SG-ADM"
	description = "<##INFRA_NAME##>-SG-ADM"
	vpc_id = "${aws_vpc.<##INFRA_NAME##>-vpc.id}"

	ingress {
		description = "Allow SSH from External"
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
		ipv6_cidr_blocks = []
	}

	egress {
		description = "Allow out Traffic"
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
		ipv6_cidr_blocks = []
	}
}

resource "aws_security_group" "<##INFRA_NAME##>-SG-RPROXY" {
	name = "<##INFRA_NAME##>-SG-RPROXY"
	description = "<##INFRA_NAME##>-SG-RPROXY"
	vpc_id = "${aws_vpc.<##INFRA_NAME##>-vpc.id}"

        ingress {
                description = "Allow SSH from Admin"
                from_port = 22
                to_port = 22
                protocol = "tcp"
		security_groups = ["${aws_security_group.<##INFRA_NAME##>-SG-ADM.id}"]
        }

	ingress {
		description = "Allow HTTP from External"
		from_port = 80
		to_port = 80
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
		ipv6_cidr_blocks = []
	}

        egress {
                description = "Allow out Traffic"
                from_port = 0
                to_port = 0
                protocol = "-1"
                cidr_blocks = ["0.0.0.0/0"]
                ipv6_cidr_blocks = []
        }
}

resource "aws_security_group" "<##INFRA_NAME##>-SG-SQUID" {
        name = "<##INFRA_NAME##>-SG-SQUID"
        description = "<##INFRA_NAME##>-SG-SQUID"
        vpc_id = "${aws_vpc.<##INFRA_NAME##>-vpc.id}"

        ingress {
                description = "Allow HTTP from Reverse Proxy"
                from_port = 3128
                to_port = 3128
                protocol = "tcp"
                security_groups = ["${aws_security_group.<##INFRA_NAME##>-SG-WEB.id}"]
        }

        egress {
                description = "Allow out Traffic"
                from_port = 0
                to_port = 0
                protocol = "-1"
                cidr_blocks = ["0.0.0.0/0"]
                ipv6_cidr_blocks = []
        }
}

resource "aws_security_group" "<##INFRA_NAME##>-SG-WEB" {
        name = "<##INFRA_NAME##>-SG-WEB"
        description = "<##INFRA_NAME##>-SG-WEB"
        vpc_id = "${aws_vpc.<##INFRA_NAME##>-vpc.id}"

        ingress {
                description = "Allow SSH from Admin"
                from_port = 22
                to_port = 22
                protocol = "tcp"
                security_groups = ["${aws_security_group.<##INFRA_NAME##>-SG-ADM.id}"]
        }

        ingress {
                description = "Allow HTTP from Reverse Proxy"
                from_port = 80
                to_port = 80
                protocol = "tcp"
                security_groups = ["${aws_security_group.<##INFRA_NAME##>-SG-RPROXY.id}"]
        }

        egress {
                description = "Allow out Traffic"
                from_port = 0
                to_port = 0
                protocol = "-1"
                cidr_blocks = ["0.0.0.0/0"]
                ipv6_cidr_blocks = []
        }
}

resource "aws_instance" "<##INFRA_NAME##>-INSTANCE-ADM" {
	key_name = "<##KEY_NAME##>"
	ami = "ami-09e513e9eacab10c1"
	vpc_security_group_ids = ["${aws_security_group.<##INFRA_NAME##>-SG-ADM.id}"]
	subnet_id = "${aws_subnet.<##INFRA_NAME##>-pub.id}"
	instance_type = "t2.micro"
	associate_public_ip_address = "true"

	tags = {
		Name = "<##INFRA_NAME##>-INSTANCE-ADM"
	}
}

resource "aws_instance" "<##INFRA_NAME##>-INSTANCE-RPROXY" {
        key_name = "<##KEY_NAME##>"
        ami = "ami-09e513e9eacab10c1"
        vpc_security_group_ids = ["${aws_security_group.<##INFRA_NAME##>-SG-RPROXY.id}", "${aws_security_group.<##INFRA_NAME##>-SG-SQUID.id}"]
        subnet_id = "${aws_subnet.<##INFRA_NAME##>-pub.id}"
	instance_type = "t2.micro"
	associate_public_ip_address = "true"
	user_data = "${file("haproxy.sh")}"

	provisioner "local-exec" {
		command = "echo ${self.public_ip} > temp_ip"
	}

        tags = {
                Name = "<##INFRA_NAME##>-INSTANCE-RPROXY"
        }
}


