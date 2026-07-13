terraform {
    required_version = ">= 1.10"

    backend "s3" {
        bucket       = "driveflow-tfstate-959228203581"
        key          = "class-a/terraform.tfstate"
        region       = "eu-central-1"
        encrypt      = true
        use_lockfile = true
    }
}
