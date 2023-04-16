# locals {
#   aws_auth_data = {
#     mapUsers = yamlencode({
#       userarn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/Pfe.jeon"
#       username = "Pfe.jeon"
#       groups = [ "system:bootstrappers", "system:master" ]
#     })
#   }
# }

# resource "kubernetes_config_map" "aws_auth" {
#   # force = true

#   metadata {
#     name      = "aws-auth"
#     namespace = "kube-system"
#   }

#   data = local.aws_auth_data

#   lifecycle {
#     ignore_changes = [
#       data, metadata[0].labels, metadata[0].annotations
#     ]
#   }
# }
