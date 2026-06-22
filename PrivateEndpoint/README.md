# module-azure-private-endpoint

> Module Terraform pour créer un **Private Endpoint** vers une ressource Azure (SQL, Storage, Web Apps, ACR, PostgreSQL, Key Vault, etc.) avec association à la **Private DNS Zone** correspondante et intégration dans un **subnet** donné.

---

## Table des matières
- [Aperçu](#aperçu)
- [Compatibilité](#compatibilité)
- [Prérequis](#prérequis)
- [Entrées](#entrées)
- [Sorties](#sorties)
- [Exemple d'utilisation](#exemple-dutilisation)
- [Sécurité & Bonnes pratiques](#sécurité--bonnes-pratiques)
- [Tests & Qualité](#tests--qualité)
- [Journal des modifications](#journal-des-modifications)
- [Licence](#licence)

---

## Aperçu
Ce module permet de :
- Sélectionner un **type de ressource** cible via `var.resource_type` (ex. `blob`, `sqlServer`, `vault`, `postgresqlServer`, `containerRegistry`, etc.).
- Résoudre automatiquement la **Private DNS Zone** associée (ex. `privatelink.blob.core.windows.net`) à l’aide d’un **provider alias** (hub/central DNS).
- Créer le **Private Endpoint** et le **Private DNS Zone Group** pointant sur la zone résolue.
- Connecter le PE au **sous-réseau** spécifié et **propager les tags**.

Types supportés (`resource_type`) :  
`sqlServer`, `blob`, `file`, `queue`, `table`, `web`, `sites`, `dfs`, `mariadbServer`, `registry`, `postgresqlServer`, `vault`, `containerRegistry`.

---

## Compatibilité
| Terraform | Providers | Cloud |
|---|---|---|
| >= 1.3 | azurerm >= 3.50.0 | Azure |

---

## Prérequis
- Terraform `>= 1.3`
- Provider `azurerm` configuré, avec **un alias** pointant vers la **subscription “hub DNS”** qui héberge les Private DNS Zones (ex. `azurerm.hub_subscription`).
- Un **Virtual Network** et un **subnet** existants pour héberger le Private Endpoint.
- L’**ID de la ressource cible** (`connection_resource_id`) accessible depuis l’abonnement où est créé le PE.
- Permissions :
  - `Microsoft.Network/privateEndpoints/*`
  - `Microsoft.Network/virtualNetworks/subnets/*`
  - `Microsoft.Network/privateDnsZones/*`

> ℹ️ La Private DNS Zone **doit exister** dans la subscription “hub DNS”. Le module la résout via `data.azurerm_private_dns_zone`.

---

## Entrées

| Nom | Type | Défaut | Obligatoire | Description |
|---|---|---|---|---|
| `resource_group_name` | string | n/a | ✅ | RG où créer le Private Endpoint. |
| `resource_group_name_vnet` | string | n/a | ✅ | RG contenant le VNet/subnet cible. |
| `network_name` | string | n/a | ✅ | Nom du Virtual Network. |
| `subnet_name` | string | n/a | ✅ | Nom du subnet où placer le Private Endpoint. |
| `endpoint_name` | string | n/a | ✅ | Nom du Private Endpoint. |
| `connection_resource_id` | string | n/a | ✅ | **Resource ID** de la ressource à connecter en privé. |
| `resource_type` | string | n/a | ✅ | Sous-ressource (doit être l’une de : `sqlServer`, `blob`, `file`, `queue`, `table`, `web`, `sites`, `dfs`, `mariadbServer`, `registry`, `postgresqlServer`, `vault`, `containerRegistry`). |
| `is_manual_connection` | bool | `false` | ❌ | Si `true`, crée une connexion privée **manuelle** (approuvée côté cible ensuite). |
| `tags` | map(string) | `{}` | ❌ | Tags supplémentaires appliqués au Private Endpoint. |

> 🔁 Le mapping **resource_type → Private DNS Zone** est défini en `locals.dns_names` dans le module.

---

## Sorties

| Nom | Description |
|---|---|
| `private_endpoint_id` | ID du Private Endpoint créé. |
| `private_endpoint_name` | Nom du Private Endpoint. |
| `subnet_id` | ID du subnet utilisé. |
| `private_dns_zone_id` | ID de la Private DNS Zone associée. |
| `resource_type_used` | Valeur de `resource_type` utilisée. |

*(Si besoin, vous pouvez étendre le module pour exposer l’IP privée via l’interface réseau du PE.)*

---

## Exemple d'utilisation

```hcl
# Providers : subscription courante (déploiement PE) + subscription hub (DNS privé)
provider "azurerm" {
  features {}
}

provider "azurerm" {
  alias           = "hub_subscription"
  features        {}
  subscription_id = "00000000-0000-0000-0000-000000000000" # Sub Hub DNS
}

module "private_endpoint_blob" {
  source = "git@github.com:your-org/terraform-modules.git//Private_Endpoint?ref=v1.0.0"

  providers = {
    azurerm.hub_subscription = azurerm.hub_subscription
  }

  # Côté réseau applicatif
  resource_group_name_vnet = "rg-networking-prod"
  network_name             = "vnet-prod"
  subnet_name              = "snet-storage"

  # Ressource cible & PE
  resource_group_name      = "rg-app-prod"
  endpoint_name            = "pe-app-storage-01"
  connection_resource_id   = "/subscriptions/xxxx/resourceGroups/rg-storage-prod/providers/Microsoft.Storage/storageAccounts/contosoprodsa"

  # Type de sous-ressource (détermine la Private DNS Zone utilisée)
  resource_type            = "blob" # privatelink.blob.core.windows.net

  # Optionnel
  is_manual_connection     = false
  tags = {
    app         = "contoso-app"
    environment = "prod"
    managed-by  = "terraform"
  }
}

output "pe_id" {
  value = module.private_endpoint_blob.private_endpoint_id
}
