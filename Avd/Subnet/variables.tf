# ==============================================================================
# Variables required
# ==============================================================================

variable "resource_group_name" {
  description = "Nom du Resource Group contenant le VNET cible (lookup SETTING+NETWORK_ZONE, cf. root HostPool)"
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

variable "nsg_name" {
  description = "Nom du Network Security Group associe au subnet"
  type        = string
}

variable "location" {
  description = "Region Azure du Network Security Group"
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

variable "extra_security_rules" {
  description = <<-EOT
    Regles NSG additionnelles ("flux metier", HLD section 9.5.2), ajoutees en
    complement des regles "flux standard" (HLD section 9.5.1) appliquees par
    defaut par ce module. Meme structure que security_rule (azurerm_network_security_group).
  EOT
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  default = []
}

variable "tags" {
  description = "Tags appliques au NSG (les subnets Azure ne supportent pas les tags)"
  type        = map(string)
  default     = {}
}
