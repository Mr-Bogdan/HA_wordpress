provider "aws" {
  profile = var.profile
  region  = var.region
}

resource "aws_instance" "instance1" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key
  vpc_security_group_ids = [aws_security_group.sg1.id]
  subnet_id              = aws_subnet.public1.id
  user_data              = data.template_file.script_for_main.rendered
  tags = {
    Name      = "EFS_TEST1"
    Terraform = "true"
  }
  volume_tags = {
    Name      = "EFS_TEST_ROOT1"
    Terraform = "true"
  }
  depends_on = [aws_efs_mount_target.efs_a, aws_efs_mount_target.efs_b]
}

resource "aws_db_instance" "wordpressdb" {
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  name                   = var.database_name
  username               = var.database_user
  password               = var.database_password
  vpc_security_group_ids = [aws_security_group.sg1.id]
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.mysql.name
  tags = {
    Role = "db"
    Env  = "rds"
  }
}


resource "aws_efs_file_system" "efs" {
  creation_token = "EFS Shared Data"
  encrypted      = true
  tags = {
    Name = "EFS Shared Data"
  }
}
resource "aws_efs_mount_target" "efs_a" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = aws_subnet.public1.id
  security_groups = [aws_security_group.sg1.id]
}

resource "aws_efs_mount_target" "efs_b" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = aws_subnet.public2.id
  security_groups = [aws_security_group.sg1.id]
}

data "template_file" "script_for_main" {
  template = file("script.tpl")
  vars = {
    efs_id = "${aws_efs_file_system.efs.id}"
  }
}
