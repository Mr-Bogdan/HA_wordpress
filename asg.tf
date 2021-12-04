# Create EC2
resource "aws_launch_configuration" "wordpressec2" {
  security_groups             = [aws_security_group.sg1.id]
  image_id                    = var.ami
  instance_type               = var.instance_type
  user_data                   = data.template_file.script_for_slave.rendered
  key_name                    = var.key
  associate_public_ip_address = true
  lifecycle {
    create_before_destroy = true
  }
}

data "template_file" "script_for_slave" {
  template = file("slave.tpl")
  vars = {
    efs_id = "${aws_efs_file_system.efs.id}"
  }
}
# Auto Scaling Group
resource "aws_autoscaling_group" "web" {
  name                 = "ASG-terraform"
  launch_configuration = aws_launch_configuration.wordpressec2.name
  health_check_type    = "ELB"
  load_balancers       = [aws_elb.web.id]
  min_size             = 2
  max_size             = 4
  desired_capacity     = 2
  vpc_zone_identifier  = [aws_subnet.public1.id, aws_subnet.public2.id]
  depends_on           = [aws_launch_configuration.wordpressec2, aws_instance.instance1]

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  metrics_granularity = "1Minute"

  dynamic "tag" {
    for_each = {
      # TAGKEY = "TAGVALUE"
      Name  = "WebServer-in-ASG"
      Owner = "Devops"
    }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_elb" "web" {
  name                      = "WebSerber-ELB"
  security_groups           = [aws_security_group.sg1.id]
  subnets                   = [aws_subnet.public1.id, aws_subnet.public2.id]
  cross_zone_load_balancing = true
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:80"
    interval            = 30
  }
  tags = {
    Name = "WebSerber-ELB"
  }
}
