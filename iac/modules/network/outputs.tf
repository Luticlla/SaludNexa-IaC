output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "IDs of the two public subnets required by the ALB."
  value       = [for key in ["a", "b"] : aws_subnet.public[key].id]
}

output "app_subnet_ids" {
  description = "IDs of the private application subnets used by ECS tasks."
  value       = [aws_subnet.app.id]
}

output "nat_gateway_id" {
  description = "ID of the NAT gateway used by private tasks."
  value       = aws_nat_gateway.this.id
}
