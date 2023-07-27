terraform {
  backend "s3" {
    bucket = "mountcorona"
    key    = "terraform-states/sle"
    region = "ca-central-1"
  }
}
