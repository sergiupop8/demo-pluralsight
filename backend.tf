# #create backend for tfstate
#    terraform {
#    backend "azurerm" {
#     resource_group_name  = "${var.prefix}-${var.az_rg}"
#     storage_account_name = "${var.prefixst}${var.az_storage_acc}${random_integer.suffix.result}"
#     container_name       = "${var.prefixst}-${var.az_container_name}"
#     key                  = "terraform.tfstate"
#   }
# }
