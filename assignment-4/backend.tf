terraform {
  backend "remote" {
    organization = "tgw-solutions"
    workspaces {
      name = "varonis-assignment-4"
    }
  }
}