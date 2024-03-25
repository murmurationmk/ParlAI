data "aws_ami" "linux-ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name      = "name"
    values    = ["al2023-ami-2023*"]
  }
}