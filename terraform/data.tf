data "external" "env" {
  program = ["pwsh", "-Command", "$ht=@{}; Get-ChildItem env: | Select Key,Value | % { $ht.Add($_.Key,$_.Value)}; $ht | ConvertTo-Json"]
}

data "azurerm_kubernetes_cluster" "this" {
  name                = var.aks_cluster_name
  resource_group_name = var.aks_resource_group_name
}
