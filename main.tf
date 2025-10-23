terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "3.2.1"
    }
  }
}

resource "null_resource" "demo" {
  # change "prod" to "dev" later to test allowed/blocked scenarios
  triggers = {
    env = "prod"
  }

  provisioner "local-exec" {
    command = "echo running null_resource demo"
  }
}
