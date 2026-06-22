# Avd/Subnet

> Module Terraform pour créer le **subnet dédié** d'un Host Pool AVD (1 Host Pool = 1 subnet, HLD AVD v0.1 section 9.2), avec allocation automatique du prochain `/24` libre dans le VNET cible et son **Network Security Group** ("flux standard", HLD section 9.5.1).

---

## Aperçu

Ce module crée :
- Un **subnet** (`azurerm_subnet`) dans un VNET existant, en `/24`, dont le CIDR est calculé automatiquement (prochain bloc libre)
- Un **Network Security Group** (`azurerm_network_security_group`) avec les règles "flux standard" (HLD §9.5.1) appliquées par défaut, complétables via `extra_security_rules` ("flux métier", HLD §9.5.2)
- L'**association** subnet ↔ NSG

Le VNET et son Resource Group cibles doivent déjà exister — ils sont déterminés par le root module appelant via une table de correspondance `${SETTING}-${NETWORK_ZONE}` (cf. mémoire architecture v2 / `Automation_Services_Avd/HostPool`).

---

## Compatibilité

| Terraform | Provider(s)        | Cloud |
|-----------|--------------------|-------|
| >= 1.3.0  | azurerm >= 3.53.0  | Azure |

---

## Algorithme d'allocation du `/24`

1. Lecture des subnets existants du VNET cible via data source (`azurerm_virtual_network` + `azurerm_subnet` par nom).
2. Si un subnet nommé `subnet_name` existe déjà (apply précédent), son CIDR actuel est conservé tel quel — **idempotence** : le module ne réattribue jamais un nouveau `/24` à un subnet qu'il gère déjà.
3. Sinon, calcul de tous les `/24` possibles dans `vnet_address_space` via `cidrsubnet(vnet_address_space, newbits, i)` (ex: `newbits=6` pour un `/18`, `newbits=4` pour un `/20`), et le premier `/24` ne correspondant à aucun **autre** subnet existant (ni à `excluded_cidrs`) est attribué au Host Pool.

> ⚠️ La détection des subnets existants se fait par **correspondance exacte de CIDR**. Un subnet existant non aligné sur la grille `/24` (ex: `GatewaySubnet` ou `AzureBastionSubnet` en `/26`/`/27`) ne serait pas détecté comme un conflit potentiel. Dans ce cas, ajoutez son CIDR (ou le bloc `/24` qui le contient) dans `excluded_cidrs`.

Si aucun `/24` n'est disponible, le plan échoue avec un message explicite (`lifecycle.precondition`).

---

## "Flux Standard" (HLD §9.5.1) — règles NSG par défaut

Les NSG ne filtrent pas par FQDN (contrairement à un firewall) : les flux obligatoires du HLD §9.5.1 sont traduits via les service tags Azure les plus proches.

| Règle | Direction | Protocole | Port | Destination | Couvre (HLD §9.5.1) |
|---|---|---|---|---|---|
| `AllowAvdCoreServicesOutbound` | Outbound | TCP | 443 | `AzureCloud` | Core AVD broker, Service Bus, monitoring, stockage AVD (items 1-3) |
| `AllowRdpShortpathOutbound` | Outbound | UDP | 3478 | `Internet` | RDP Shortpath / STUN-TURN (item 5) |
| `AllowCertificateValidationOutbound` | Outbound | TCP | 80 | `Internet` | OCSP / CRL, validation de certificats (item 4) |

Les flux métier (HLD §9.5.2, matrice Horizon → AVD) sont ajoutés via `extra_security_rules`.

---

## Entrées principales

| Nom | Type | Obligatoire | Description |
|---|---|---|---|
| `resource_group_name` | string | ✅ | RG contenant le VNET cible |
| `virtual_network_name` | string | ✅ | Nom du VNET cible |
| `vnet_address_space` | string | ✅ | Plage d'adresses du VNET (ex: `10.202.0.0/18`) |
| `newbits` | number | ✅ | Bits à ajouter pour obtenir un `/24` (ex: `6` pour `/18`, `4` pour `/20`) |
| `subnet_name` | string | ✅ | Nom du subnet dédié au Host Pool |
| `nsg_name` | string | ✅ | Nom du NSG associé |
| `location` | string | ✅ | Région Azure du NSG |
| `excluded_cidrs` | list(string) | ❌ (def: `[]`) | CIDR `/24` à exclure manuellement de l'allocation |
| `extra_security_rules` | list(object) | ❌ (def: `[]`) | Règles NSG additionnelles (flux métier, HLD §9.5.2) |
| `tags` | map(string) | ❌ (def: `{}`) | Tags appliqués au NSG (les subnets Azure ne supportent pas les tags) |

---

## Sorties

| Nom | Description |
|---|---|
| `subnet_id` | ID du subnet créé — à consommer par `Avd/SessionHost` (NIC) et le stockage FSLogix |
| `subnet_name` | Nom du subnet créé |
| `subnet_address_prefix` | CIDR `/24` alloué automatiquement |
| `network_security_group_id` | ID du NSG associé |
| `network_security_group_name` | Nom du NSG associé |

---

## Exemple d'utilisation

```hcl
module "subnet" {
  source = "git::https://github.com/servier-github/terraform-az-modules.git//Avd/Subnet?ref=poc"

  resource_group_name  = "EM50-PRD-AVDAZ-PRD-RG01"
  virtual_network_name = "EM50-PRD-AVDAZ-VNET01"
  vnet_address_space   = "10.202.0.0/18"
  newbits              = 6

  subnet_name = "MADMSYS1-SNET01"
  nsg_name    = "MADMSYS1-NSG01"
  location    = "France Central"

  tags = local.common_tags
}
```

---

## Journal des modifications

- **v0.1** — Création initiale (subnet `/24` auto-alloué + NSG "flux standard")
