variable "aws_region" {
  description = "Region AWS del examen"
  type        = string
  default     = "us-east-2"
}

variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Nombre del Key Pair existente en AWS"
  type        = string
}

variable "admin_cidr" {
  description = "IP publica autorizada para SSH"
  type        = string
}
