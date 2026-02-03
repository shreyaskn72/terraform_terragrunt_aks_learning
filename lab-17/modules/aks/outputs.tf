output "cluster_name" {
  value       = azurerm_kubernetes_cluster.this.name
  description = "The name of the AKS cluster"
}

output "kube_admin_config_raw" {
  value       = azurerm_kubernetes_cluster.this.kube_admin_config_raw
  description = "Raw kubeconfig for admin access"
}
