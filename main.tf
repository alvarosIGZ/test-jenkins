provider "aws"{
    region = "${var.aws_region}"
    profile= "${var.aws_profile}"
}

terraform{
  backend "s3"{
    bucket = "alvaro-jenkins-bucket"
    key    = "terraform.tfstate"
    region = "us-west-2"
  }
}

resource "aws_key_pair" "auth"{
 key_name = "${var.key_name}"   
 public_key= "${file(var.public_key_path)}"
}



# Security group: allow any IP to ssh into me (port 22), allow any IP to connect to me via internet in http (port 80)
# Allow me (the instance) to talk to anything on all ports through all protocols ("-1")

resource "aws_security_group" "instance"{
    name = "example-instance"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group_rule" "http"{
    security_group_id = "${aws_security_group.instance.id}"
    type = "ingress"

    from_port = 80
    to_port = 80
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "all_outbound"{
    security_group_id = "${aws_security_group.instance.id}"
    type = "egress"

    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_instance" "example-instance" {
    count= 1
    ami = "ami-aa5ebdd2"
    instance_type= "t2.micro"
    security_groups = ["${aws_security_group.instance.name}"]
    key_name = "${aws_key_pair.auth.id}"

    tags {
        Name = "example-instance"
    }
}