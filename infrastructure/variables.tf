variable "domain_name" {
  type        = string
  description = "Main domain of the website (ex. thanel.dev)"
}

variable "project_name" {
  type        = string
  description = "Name identifier for the project, used for resources and tags (es. thanel-dev-blog)"
}

variable "github_oidc_subject_claim_prefix" {
  type        = string
  description = "In your Github repository, Settings -> Actions -> OIDC -> Default subject claim prefix"
}

variable "github_branch" {
  type        = string
  description = "Branch autorized to deploy"
  default     = "main"
}
