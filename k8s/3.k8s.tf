

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.k8s.name
  }
}

resource "kubernetes_deployment" "deployment" {
  metadata {
    name      = var.k8s.name
    namespace = kubernetes_namespace.namespace.metadata.0.name
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        "app.kubernetes.io/name" = "${var.k8s.name}-app"
      }
    }
    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = "${var.k8s.name}-app"
        }
      }
      spec {
        container {
          image = "public.ecr.aws/l6m2t8p7/docker-2048:latest"
          image_pull_policy = "Always"
          name  = "${var.k8s.name}-app"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "service" {
  metadata {
    name      = "${var.k8s.name}-svc"
    namespace = "${kubernetes_namespace.namespace.metadata.0.name}"
  }
  spec {
    type = "NodePort"
    selector = {
      "app.kubernetes.io/name" = "${var.k8s.name}-svc"
    }
    port {
      port        = 80
      target_port = 80
      protocol = "TCP"
    }
  }
}

resource "kubernetes_ingress" "ingress" {
  metadata {
    name = "${var.k8s.name}-ing"
    namespace = kubernetes_namespace.namespace.metadata.0.name
    annotations = {
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"
      "alb.ingress.kubernetes.io/target-type" = "ip"
    }
  }

  spec {
    ingress_class_name = "alb"
    rule {
      http {
        path {
          path = "/"
          backend {
            service_name = "${var.k8s.name}-svc"
            service_port = 80
            # service {
            #   name = "${var.svc}"
            #   port {
            #     number = 80
            #   }
            # }
          }
        }
      }
    }
  }
}
