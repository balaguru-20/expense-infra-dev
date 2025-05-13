resource "aws_key_pair" "openvpnas" {
  key_name =  "openvpnas" 
  public_key = file("C:\\devops\\daws-82s\\openvpnas.pub") #public key using windows path
}

resource "aws_instance" "openvpn" {
  ami                    = data.aws_ami.openvpn.id
  key_name = aws_key_pair.openvpnas.key_name #attaching pem key
  vpc_security_group_ids = [data.aws_ssm_parameter.vpn_sg_id.value]
  instance_type          = "t3.micro"
  subnet_id              = local.public_subnet_id
  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-vpn"
    }
  )
}