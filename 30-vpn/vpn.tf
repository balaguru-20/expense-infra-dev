resource "aws_key_pair" "openvpnas" {
  key_name   = "openvpnas"
  public_key = file("C:\\devops\\daws-82s\\openvpnas.pub") #public key using windows path
}

resource "aws_instance" "openvpn" {
  ami                    = data.aws_ami.openvpn.id
  key_name               = aws_key_pair.openvpnas.key_name #attaching pem key
  vpc_security_group_ids = [data.aws_ssm_parameter.vpn_sg_id.value]
  instance_type          = "t3.micro"
  subnet_id              = local.public_subnet_id
  user_data              = file("user-data.sh") #It will open's the file and gives the user data to the instance
  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-vpn"
    }
  )
}

output "vpn_ip" {
  value = aws_instance.openvpn.public_ip
}