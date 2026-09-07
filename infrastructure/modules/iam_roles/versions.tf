# Declares which providers this module needs (with version constraints).
# NOTE: no `provider "aws" {}` block here — that configuration (region,
# profile, default_tags) lives only in the root env (envs/*/providers.tf).
# Modules inherit the configured provider from the root that calls them.

terraform {
    required_version = ">= 1.10"

    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 6.0"
        }
    }
}
