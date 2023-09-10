# resource "kubernetes_manifest" "tekton-pipelines" {
#   manifest = yamldecode(file("${path.module}/files/tekton/pipelines/tekton-pipelines.yaml"))
# }

# resource "kubernetes_manifest" "tekton-dashboard" {
#   manifest = yamldecode(file("${path.module}/files/tekton/pipelines/tekton-dashboard.yaml"))
# }

# resource "kubernetes_manifest" "tekton-ingress" {
#   manifest = yamldecode(file("${path.module}/files/tekton/pipelines/tekton-ingress-dashboard.yaml"))
# }

# data "kubernetes_config_map" "aws_auth" {
#   metadata {
#     name = "aws-auth"
#     namespace = "kube-system"
#   }
# }

# resource "kubernetes_namespace" "namespace" {
#   metadata {
#     name = var.k8s.name
#   }
# }

# resource "kubernetes_deployment" "deployment" {
#   metadata {
#     name      = var.k8s.name
#     namespace = kubernetes_namespace.namespace.metadata.0.name
#   }
#   spec {
#     replicas = 2
#     selector {
#       match_labels = {
#         "app.kubernetes.io/name" = "${var.k8s.name}-app"
#       }
#     }
#     template {
#       metadata {
#         labels = {
#           "app.kubernetes.io/name" = "${var.k8s.name}-app"
#         }
#       }
#       spec {
#         container {
#           image = "public.ecr.aws/l6m2t8p7/docker-2048:latest"
#           image_pull_policy = "Always"
#           name  = "${var.k8s.name}-app"
#           port {
#             container_port = 80
#           }
#         }
#       }
#     }
#   }
# }

# resource "kubernetes_service" "service" {
#   metadata {
#     name      = "${var.k8s.name}-svc"
#     namespace = "${kubernetes_namespace.namespace.metadata.0.name}"
#   }
#   spec {
#     type = "NodePort"
#     selector = {
#       "app.kubernetes.io/name" = "${var.k8s.name}-svc"
#     }
#     port {
#       port        = 80
#       target_port = 80
#       protocol = "TCP"
#     }
#   }
# }

# resource "kubernetes_ingress_v1" "ingress" {
#   metadata {
#     name = "${var.k8s.name}-ing"
#     namespace = kubernetes_namespace.namespace.metadata.0.name
#     annotations = {
#       "alb.ingress.kubernetes.io/scheme" = "internet-facing"
#       "alb.ingress.kubernetes.io/target-type" = "ip"
#     }
#   }

#   spec {
#     ingress_class_name = "alb"
#     rule {
#       http {
#         path {
#           path = "/"
#           backend {
#             service {
#               name = kubernetes_service.service.metadata.0.name
#               port {
#                 number = kubernetes_service.service.spec.0.port.0.port
#               }
#             }
#           }
#         }
#       }
#     }
#   }
# }
