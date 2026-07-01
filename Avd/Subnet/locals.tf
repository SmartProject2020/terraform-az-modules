locals {
  # Tous les /24 possibles dans le VNET cible (ex: newbits=6 sur un /18 -> 64
  # blocs /24, newbits=4 sur un /20 -> 16 blocs /24)
  candidate_cidrs = [
    for i in range(0, floor(pow(2, var.newbits))) :
    cidrsubnet(var.vnet_address_space, var.newbits, i)
  ]

  # Subnet gere par ce module, s'il a deja ete cree par un apply precedent
  existing_self_subnet = try(data.azurerm_subnet.existing[var.subnet_name], null)

  # CIDR deja occupes par d'AUTRES subnets du VNET (le subnet gere par ce
  # module est exclu : son propre CIDR ne doit pas etre traite comme "occupe")
  # + exclusions manuelles
  existing_cidrs = toset(concat(
    [for name, s in data.azurerm_subnet.existing : s.address_prefixes[0] if name != var.subnet_name],
    var.excluded_cidrs
  ))

  # Premiers /24 non occupes par d'autres subnets, dans l'ordre croissant
  available_cidrs = [
    for c in local.candidate_cidrs : c
    if !contains(local.existing_cidrs, c)
  ]

  # CIDR attribue au Host Pool : si le subnet existe deja, on conserve son CIDR
  # actuel (idempotence — sinon next_cidr serait recalcule a chaque plan).
  # Sinon, premier /24 libre. coalesce() garantit un type string valide pour
  # address_prefixes ; si available_cidrs est vide, le lifecycle.precondition
  # de azurerm_subnet.this bloque le plan avec un message explicite.
  next_cidr = local.existing_self_subnet != null ? local.existing_self_subnet.address_prefixes[0] : coalesce(try(local.available_cidrs[0], null), "0.0.0.0/32")
}
