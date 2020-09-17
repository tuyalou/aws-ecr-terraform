provider "aws" {
  version = "2.59"
}

resource "aws_ecr_repository" "repo" {
  name   = "${var.image_name}"
}


resource "aws_ecr_lifecycle_policy" "repo_policy" {
  repository = "${aws_ecr_repository.repo.name}"

  
  policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Remove untagged images",
      "selection": {
        "tagStatus": "untagged",
        "countType": "imageCountMoreThan",
        "countNumber": 1
      },
      "action": {
        "type": "expire"
      }
    },
    {
      "rulePriority": 2,
      "description": "Rotate images when reach ${var.max_image_count} images stored",
      "selection": {
        "tagStatus": "any",
        "tagPrefixList": ["v"],
        "countType": "imageCountMoreThan",
        "countNumber": ${var.max_image_count}
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
}
  
  

data "aws_ecr_image" "ecr_image" {
  repository_name = "${aws_ecr_repository.repo.name}"
  image_tag       = "${var.tags}"
}

