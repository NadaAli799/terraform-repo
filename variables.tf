variable "db_username" {
  description = "The username for the MySQL database"
  type        = string
}

variable "db_password" {
  description = "The password for the MySQL database"
  type        = string
  sensitive   = true
}
