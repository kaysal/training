
# key pairs
#--------------------------------

# tokyo

resource "aws_key_pair" "tokyo" {
  provider   = aws.tokyo
  key_name   = "salawu-live-demo"
  public_key = file(var.public_key_path)
}

# london

resource "aws_key_pair" "london" {
  key_name   = "salawu-live-demo"
  public_key = file(var.public_key_path)
}

# ohio

resource "aws_key_pair" "ohio" {
  provider   = aws.ohio
  key_name   = "salawu-live-demo"
  public_key = file(var.public_key_path)
}

# ohio

resource "aws_key_pair" "singapore" {
  provider   = aws.singapore
  key_name   = "salawu-live-demo"
  public_key = file(var.public_key_path)
}

# canada

resource "aws_key_pair" "canada" {
  provider   = aws.canada
  key_name   = "salawu-live-demo"
  public_key = file(var.public_key_path)
}
