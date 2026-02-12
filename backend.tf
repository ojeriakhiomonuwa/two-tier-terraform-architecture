terraform {
  backend "s3" {
    bucket = "state-file-bucket-5190"
    key    = "backend/test.tfstate"
    region = "us-east-1"
    dynamodb_table = "Dynamodb-state-lock"
    use_lockfile = true
  }
}