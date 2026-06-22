# module-azure-resource-group

> Module Terraform pour **créer un Resource Group Azure** avec un **jeu de tags standardisés** (application, environnement, gouvernance, sauvegarde, etc.).

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
Ce module crée un **Resource Group** (`azurerm_resource_group`) et applique un **ensemble de tags** provenant des variables d’entrée pour assurer la **traçabilité**, la **gouvernance** et la **cohérence inter-équipes**.

Tags gérés dans le module (clés) :
- `application-id`
- `backup-policy`
- `servier-environment`
> D’autres tags sont prévus dans les variables (project_code, sponsor_code, criticality, zoning, etc.) mais **commentés** dans `main.tf`. Tu peux les **décommenter** si tu souhaites les appliquer.

---

## Compatibilité
| Terraform | Provider(s) | Cloud |
|-----------|-------------|-------|
| >= 1.3    | azurerm >= 3.50.0 | Azure |

---

## Prérequis
- Terraform installé localement (`>= 1.3`)
- Provider `azurerm` configuré (Azure CLI, Service Principal ou Managed Identity)
- Droits suffisants pour créer des Resource Groups et appliquer des tags dans la subscription cible

---

## Entrées

| Nom | Type | Par défaut | Obligatoire | Description |
|-----|------|------------|-------------|-------------|
| `location` | string | n/a | ✅ | Région Azure du Resource Group (ex. `westeurope`). |
| `name` | string | n/a | ✅ | Nom du Resource Group. |
| `application_id` | string | n/a | ✅ | Identifiant d’application. **Tag** `application-id`. |
| `project_code` | string | n/a | ✅ | Code projet (non tagué par défaut dans le `main.tf`). |
| `sponsor_code` | string | n/a | ✅ | Code sponsor (non tagué par défaut). |
| `ddsi_cost_center` | string | n/a | ✅ | Centre de coûts (non tagué par défaut). |
| `criticality` | string | n/a | ✅ | Criticité (non taguée par défaut). |
| `zoning` | string | n/a | ✅ | Zoning (non tagué par défaut). |
| `backup_policy` | string | n/a | ✅ | Politique de sauvegarde. **Tag** `backup-policy`. |

**Optionnels (utilisables comme tags si tu décommentes les lignes dans `main.tf`)**

| Nom | Type | Par défaut | Description |
|-----|------|------------|-------------|
| `servier_resource_name` | string | `"TBD"` | Nom logique interne. |
| `servier_environment` | string | `"dev"` | Environnement (ex. `dev`, `val`, `prd`). **Tag** `servier-environment`. |
| `backup` | string | `"yes"` | Indicateur de sauvegarde. |
| `monitoring` | string | `"yes"` | Indicateur de supervision. |
| `os_diag` | string | `"no"` | Diagnostics OS. |
| `country` | string | `"TBD"` | Pays. |
| `purpose` | string | `"MISC"` | Finalité / usage. |
| `schedule` | string | `"TBD"` | Fenêtre horaire. |
| `auto_start` | string | `"08:00"` | Heure de démarrage auto. |
| `auto_stop` | string | `"20:00"` | Heure d’arrêt auto. |
| `servier_compliance` | string | `""` | Indicateur conformité. |
| `setting` | string | `""` | Contexte (ex. `NPR`, `PRD`). |

> 💡 Bonnes pratiques : si tu souhaites **appliquer davantage de tags**, décommente les lignes correspondantes dans `main.tf` pour les clés :
> `ddsi-cost-center`, `sponsor-code`, `project-code`, `criticality`, `zoning`, `servier-compliance`, etc.

---

## Sorties
 
Completer le `outputs.tf` minimal comme suit :

```hcl
output "resource_group_id" {
  description = "ID du Resource Group"
  value       = azurerm_resource_group.rg.id
}

output "resource_group_name" {
  description = "Nom du Resource Group"
  value       = azurerm_resource_group.rg.name
}

output "resource_group_location" {
  description = "Région du Resource Group"
  value       = azurerm_resource_group.rg.location
}

output "resource_group_tags" {
  description = "Tags appliqués au Resource Group"
  value       = azurerm_resource_group.rg.tags
}
