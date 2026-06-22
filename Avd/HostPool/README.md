# Avd/HostPool

> Module Terraform pour créer un **Azure Virtual Desktop Host Pool** (Pooled ou Personal) avec son **token d'enregistrement** des Session Hosts, conformément au TAD "Azure AVD for SERVIER".

---

## Aperçu

Ce module crée :
- Un **Host Pool AVD** (`azurerm_virtual_desktop_host_pool`), Pooled (multisession) ou Personal selon `type`
- Les **informations d'enregistrement** (`azurerm_virtual_desktop_host_pool_registration_info`) avec un token renouvelé automatiquement via `time_rotating` (durée pilotée par `registration_expiration_hours`), consommé par le module [`Avd/SessionHost`](../SessionHost) pour joindre les VMs au pool

Le Resource Group cible doit déjà exister (chaque Host Pool dispose de son propre RG, cf. TAD section 1.1) — il est référencé via `resource_group_name` et ses tags sont fusionnés avec ceux du module (`merge`).

---

## Compatibilité

| Terraform | Provider(s)                          | Cloud |
|-----------|--------------------------------------|-------|
| >= 1.3.0  | azurerm >= 3.53.0, time >= 0.9.0     | Azure |

---

## Prérequis

- Un **Resource Group** existant pour héberger le Host Pool (cf. module [`ResourceGroup`](../../ResourceGroup))
- Permissions `Microsoft.DesktopVirtualization/hostPools/*`

---

## Entrées principales

| Nom | Type | Obligatoire | Description |
|---|---|---|---|
| `resource_group_name` | string | ✅ | RG dédié au Host Pool |
| `name` | string | ✅ | Nom du Host Pool — convention HLD v0.1 : `<M\|P><PoolID><version>` (ex: `MADMSYS1`) |
| `type` | string | ✅ | `Pooled` (multisession) ou `Personal` |
| `load_balancer_type` | string | ✅ | `BreadthFirst`, `DepthFirst` ou `Persistent` |
| `personal_desktop_assignment_type` | string | ❌ | `Automatic` ou `Direct` — pertinent uniquement si `type = Personal` |
| `maximum_sessions_allowed` | number | ❌ | Pertinent uniquement si `type = Pooled` |
| `friendly_name` / `description` | string | ❌ | Métadonnées affichées aux utilisateurs |
| `start_vm_on_connect` | bool | ❌ (def: `true`) | Démarrage auto des Session Hosts à la connexion |
| `validate_environment` | bool | ❌ (def: `false`) | Pool de validation |
| `custom_rdp_properties` | string | ❌ | Propriétés RDP (ex: RDP ShortPath — TAD §3.8) |
| `registration_expiration_hours` | number | ❌ (def: `8`) | Durée de validité du token d'enregistrement |
| `APPLICATION_ID` / `servier_environment` / `backup_policy` | string | ✅ | Tags standards Servier |

> Le module neutralise automatiquement `maximum_sessions_allowed` pour un pool `Personal` et `personal_desktop_assignment_type` pour un pool `Pooled`, afin d'éviter toute incohérence silencieuse acceptée par le provider.

---

## Sorties

| Nom | Description |
|---|---|
| `host_pool_id` | ID du Host Pool |
| `host_pool_name` | Nom du Host Pool |
| `registration_token` | Token d'enregistrement (sensible) — à consommer par `Avd/SessionHost` |
| `registration_expiration_date` | Date d'expiration du token (RFC3339) |

---

## Exemple d'utilisation

```hcl
module "host_pool" {
  source = "git::https://github.com/servier-github/terraform-az-modules.git//Avd/HostPool?ref=poc"

  resource_group_name = "EM50-PRD-AVD00-PRD-RG01"
  name                = "MADMSYS1"
  type                = "Pooled"
  load_balancer_type  = "BreadthFirst"

  maximum_sessions_allowed = 8
  start_vm_on_connect      = true

  APPLICATION_ID      = "AVD00"
  servier_environment = "PRD"
  backup_policy       = "PROD"
}
```

---

## Journal des modifications

- **v0.1** — Création initiale (Host Pool + registration info)
