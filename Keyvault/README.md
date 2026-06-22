# module-azure-key-vault

> Module Terraform pour créer un **Azure Key Vault** avec gestion des **access policies**, configuration réseau sécurisée, et intégration optionnelle à un **Private Endpoint**.

---

## Table des matières
- [Aperçu](#aperçu)
- [Compatibilité](#compatibilité)
- [Prérequis](#prérequis)
- [Entrées](#entrées)
- [Sorties](#sorties)
- [Exemple d'utilisation](#exemple-dutilisation)
- [Sécurité](#sécurité)
- [Tests & Qualité](#tests--qualité)
- [Journal des modifications](#journal-des-modifications)
- [Licence](#licence)

---

## Aperçu
Ce module permet de :
- Créer un **Azure Key Vault** (`azurerm_key_vault`) avec configuration réseau restreinte (`default_action = Deny`).
- Activer les bonnes pratiques de sécurité :  
  - **Soft Delete** (90 jours)  
  - **Purge Protection** activée  
  - **RBAC désactivé** (gestion par *access policies*)
- Créer plusieurs **Access Policies** :
  - **Runexploitation User** (permissions complètes sur les secrets et certificats)
  - **Centreon User** (lecture seule)
  - **App Gateway** (lecture seule, ID dépendant de l’environnement `setting`)
- Préparer une future intégration à un **Private Endpoint** (code commenté dans le module).
- Associer le Key Vault à un **subnet existant** (via data sources AzureRM).

---

## Compatibilité
| Terraform | Provider(s) | Cloud |
|------------|-------------|--------|
| >= 1.3     | azurerm >= 3.50.0 | Azure |

---

## Prérequis
- Terraform installé localement (`>= 1.3`)
- Provider `azurerm` configuré (Azure CLI, Service Principal, ou Managed Identity)
- Un **Resource Group** existant pour héberger le Key Vault
- Un **VNet/Subnet** existant si utilisation du Private Endpoint
- Permissions nécessaires :
  - `Microsoft.KeyVault/vaults/*`
  - `Microsoft.Network/virtualNetworks/subnets/*`
  - `Microsoft.Authorization/roleAssignments/*` (si RBAC activé ultérieurement)

---

## Entrées

| Nom | Type | Par défaut | Obligatoire | Description |
|------|------|-------------|-------------|--------------|
| PLAQUE | string | n/a | ✅ | Identifiant de plaque (ex: em50, ap50, am50). |
| ENV | string | n/a | ✅ | Environnement cible (`DEV`, `TST`, `PRD`, etc.). |
| APPLICATION_ID | string | n/a | ✅ | Identifiant de l’application associée au Key Vault. |
| location | string | n/a | ✅ | Région Azure du Key Vault. |
| setting | string | n/a | ✅ | Type de déploiement (`NPR` ou `PRD`) pour adapter les access policies App Gateway. |
| resource_group_name | string | n/a | ✅ | Nom du Resource Group hébergeant le Key Vault. |
| kv_name | string | n/a | ✅ | Nom du Key Vault à créer. |
| keyvault_inc | string | `"01"` | ❌ | Incrément ou suffixe du Key Vault (utile pour la nomenclature). |
| subnet_name | string | n/a | ✅ | Nom du sous-réseau cible pour un Private Endpoint (future utilisation). |
| virtual_network_name | string | n/a | ✅ | Nom du réseau virtuel associé au sous-réseau. |
| virtual_network_rg_name | string | n/a | ✅ | Nom du Resource Group du réseau virtuel. |
| pe_name | string | n/a | ❌ | Nom du Private Endpoint (optionnel / futur). |

---

## Sorties

| Nom | Description |
|------|-------------|
| key_vault_id | ID du Key Vault créé. |
| key_vault_uri | URI d’accès au Key Vault (https://...). |
| key_vault_name | Nom du Key Vault. |

---

## Exemple d'utilisation

```hcl
module "key_vault" {
  source = "git@github.com:servier-github/Azure_Terraform_Modules.git//Key_Vault?ref=develop"

  PLAQUE                 = "em50"
  ENV                    = "PRD"
  APPLICATION_ID          = "payapp"
  location               = "West Europe"
  setting                = "PRD"
  resource_group_name    = "rg-security-prod"
  kv_name                = "em50prdpayappkv01"

  subnet_name            = "subnet-keyvault"
  virtual_network_name   = "vnet-prod"
  virtual_network_rg_name = "rg-networking-prod"

  pe_name                = "pe-keyvault01"
}
