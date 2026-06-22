# module-azure-storage-account-core

> Module Terraform pour créer un **compte de stockage Azure** avec configuration de base (tiers, kind, réplication, rétention blob) et **règles réseau optionnelles** (intégration à un sous-réseau si le pare-feu est en `Deny`).

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

Ce module déploie un **`azurerm_storage_account`** avec :
- Paramétrage **tier/kind/replication/access tier**.
- **TLS minimum**, désactivation de l’accès public aux blobs, **clé partagée activée**.
- Politiques de rétention **blob** & **container**.
- **Pare-feu réseau** : `default_action = Allow|Deny`, avec possibilité d’**autoriser un sous-réseau** si `add_network = true` et `network_rules_action = "Deny"` (via `virtual_network_subnet_ids`).
- Routage Microsoft par défaut.

Les **tags** du Resource Group sont propagés au compte de stockage.

---

## Compatibilité

| Terraform | Provider(s) | Cloud |
|----------:|-------------|-------|
| >= 1.3    | `azurerm` ≥ 3.5x | Azure |

> Vérifie la version exacte du provider selon tes contraintes internes.

---

## Prérequis

- Terraform installé (≥ 1.3) et provider `azurerm` configuré (Azure CLI, SPN, ou Managed Identity).
- **Resource Group** cible existant.
- Si `add_network = true` et `network_rules_action = "Deny"` : le **VNet/Subnet** référencé doit exister et être **résolvable** par l’identité d’exécution.

---

## Entrées

### Obligatoires

| Nom | Type | Description |
|-----|------|-------------|
| `resource_group_name` | string | Nom du Resource Group cible. |
| `storage_account_name` | string | Nom globalement unique du compte de stockage. |
| `storage_account_tier` | string | `Standard` ou `Premium`. |
| `storage_account_kind` | string | `StorageV2`, `BlobStorage`, `FileStorage`, etc. |
| `storage_account_replication_type` | string | `LRS`, `ZRS`, `GRS`, `GZRS`, … |
| `storage_account_access_tier` | string | `Hot`, `Cool` (selon le kind). |
| `minimum_tls_version` | string | `TLS1_2` recommandé. |
| `blob_delete_retention_policy_days` | number | Jours de rétention des blobs supprimés. |
| `container_delete_retention_policy_days` | number | Jours de rétention des containers supprimés. |
| `network_rules_action` | string | `Allow` ou `Deny`. |
| `add_network` | bool | `true` pour restreindre à un subnet si `Deny`. |
| `selected_network_name` | string | Nom du VNet (si `add_network = true`). |
| `selected_subnet_name` | string | Nom du subnet (si `add_network = true`). |
| `selected_network_rg_name` | string | RG du réseau (si `add_network = true`). |

> Le module calcule `virtual_network_subnet_ids` uniquement si `add_network = true` **et** `network_rules_action = "Deny"`.

---

## Sorties

| Nom | Description |
|-----|-------------|
| `storage_account_id` | ID du compte de stockage. |
| `storage_account_name` | Nom du compte de stockage. |

---

## Exemple d'utilisation

```hcl
provider "azurerm" {
  features {}
}

module "storage_account_core" {
  source = "git@github.com:servier-github/Azure_Terraform_Modules.git//Storage_Account_Core?ref=develop"

  resource_group_name                  = "rg-data-prd"
  storage_account_name                 = "em50prdstocore01"

  storage_account_tier                 = "Standard"
  storage_account_kind                 = "StorageV2"
  storage_account_replication_type     = "ZRS"
  storage_account_access_tier          = "Hot"
  minimum_tls_version                  = "TLS1_2"

  blob_delete_retention_policy_days    = 7
  container_delete_retention_policy_days = 7

  # Pare-feu réseau : Deny + autorisation d’un sous-réseau spécifique
  network_rules_action                 = "Deny"
  add_network                          = true
  selected_network_rg_name             = "rg-network-prd"
  selected_network_name                = "vnet-prd"
  selected_subnet_name                 = "snet-storage"

  # Si tu veux tout ouvrir (temporairement) :
  # network_rules_action = "Allow"
  # add_network = false
}

output "storage_id" {
  value = module.storage_account_core.storage_account_id
}
