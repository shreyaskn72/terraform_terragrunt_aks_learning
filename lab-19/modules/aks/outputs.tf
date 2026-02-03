output "cluster_name" {
  value = azurerm_kubernetes_cluster.this.name
}

output "private_fqdn" {
  value = azurerm_kubernetes_cluster.this.private_fqdn
}