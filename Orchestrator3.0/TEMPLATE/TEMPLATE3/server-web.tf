resource "aws_network_interface" "<##INFRA_NAME##>-INSTANCE-WEB<##NUM##>-IP" {
        subnet_id = "${aws_subnet.<##INFRA_NAME##>-priv.id}"
        private_ips = ["10.0.2.<##NUM##>"]

        tags = {
                Name = "<##INFRA_NAME##>-INSTANCE-WEB<##NUM##>-IP"
        }
}

resource "aws_network_interface_sg_attachment" "<##INFRA_NAME##>-INSTANCE-WEB<##NUM##>-IP-SG-ATTACH" {
        security_group_id = "${aws_security_group.<##INFRA_NAME##>-SG-WEB.id}"
        network_interface_id = "${aws_network_interface.<##INFRA_NAME##>-INSTANCE-WEB<##NUM##>-IP.id}"
}

resource "aws_instance" "<##INFRA_NAME##>-INSTANCE-WEB<##NUM##>" {
        key_name = "<##KEY_NAME##>"
        ami = "ami-09e513e9eacab10c1"
	instance_type = "t2.micro"
	subnet_id   = "${aws_subnet.<##INFRA_NAME##>-pub.id}"
	vpc_security_group_ids = ["${aws_security_group.<##INFRA_NAME##>-SG-WEB.id}"]
	user_data = "${file("httpd.sh")}"
	associate_public_ip_address = false
	
	network_interface {
                network_interface_id = "${aws_network_interface.<##INFRA_NAME##>-INSTANCE-WEB<##NUM##>-IP.id}"
                device_index = 0
        }

	tags = {
                Name = "<##INFRA_NAME##>-INSTANCE-WEB<##NUM##>"
        }
}
