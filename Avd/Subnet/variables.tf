# ==============================================================================
# Variables required
# ==============================================================================

variable "resource_group_name" {
  description = "Nom du Resource Group contenant le VNET et la Route Table (lookup SETTING+NETWORK_ZONE, cf. root HostPool)"
  type        = string
}

variable "virtual_network_name" {
  description = "Nom du VNET cible dans lequel le subnet dedie au Host Pool sera cree"
  type        = string
}

variable "vnet_address_space" {
  description = "Plage d'adresses du VNET cible (ex: 10.202.0.0/18), utilisee pour calculer le prochain /24 libre"
  type        = string
}

variable "newbits" {
  description = "Nombre de bits a ajouter au masque du VNET pour obtenir un /24 (ex: 6 pour /18, 4 pour /20)"
  type        = number
}

variable "subnet_name" {
  description = "Nom du subnet dedie au Host Pool (1 Host Pool = 1 subnet, HLD section 9.2)"
  type        = string
}

variable "route_table_name" {
  description = "Nom de la Route Table pre-existante a associer au subnet (geree par l equipe reseau)"
  type        = string
}

# ==============================================================================
# Variables optionnelles
# ==============================================================================

variable "excluded_cidrs" {
  description = <<-EOT
    Liste de CIDR /24 a exclure manuellement de l'allocation automatique, en plus
    des subnets existants detectes via data source. A utiliser pour reserver des
    blocs ou pour couvrir des subnets existants qui ne sont pas alignes sur la
    grille /24 (ex: GatewaySubnet, AzureBastionSubnet en /26 ou /27) et que la
    detection par correspondance exacte ne peut donc pas voir.
  EOT
  type        = list(string)
  default     = []
}
