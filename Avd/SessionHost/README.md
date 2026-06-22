# Avd / SessionHost

Module enfant Terraform qui provisionne des **Session Hosts AVD** (machines virtuelles Windows)
et les rattache a un Host Pool existant : carte reseau, VM Windows, jonction Microsoft Entra ID,
et enregistrement de l'agent AVD via le token du Host Pool.

## Compatibilite

| Terraform | azurerm |
|-----------|---------|
| >= 1.3.0  | >= 3.53.0 |

## Prerequis

- Un Host Pool AVD existant (module [`Avd/HostPool`](../HostPool)) et son `registration_token`
- Un subnet existant fourni par la couche reseau / landing zone (equipe plateforme — TAD section 8.3.2)
- Un mot de passe administrateur local stocke de maniere securisee (Key Vault du pool)

## Nommage

Convention HLD v0.1 section 2.2 : `<AVD><HostPoolID>-<incremental-number>` (ex: `AVDMADMSYS1-1`).

> Le nom de la ressource Azure (`name`) suit la convention complete, mais le `computer_name`
> Windows est **tronque a 15 caracteres** (limite NetBIOS historique de Windows).

## Ressources gerees

- `azurerm_network_interface` (une par Session Host)
- `azurerm_windows_virtual_machine`
- `azurerm_virtual_machine_extension` `AADLoginForWindows` (jonction Entra ID, optionnelle via `entra_id_join`)
- `azurerm_virtual_machine_extension` `Microsoft.PowerShell.DSC` (agent AVD + enregistrement aupres du Host Pool)

## Inputs principaux

| Nom | Description | Type | Defaut |
|-----|-------------|------|--------|
| `resource_group_name` | RG du Host Pool cible | `string` | - |
| `location` | Region Azure | `string` | - |
| `name_prefix` | Prefixe de nommage (`AVD<HostPoolID>`) | `string` | - |
| `session_host_count` | Nombre de Session Hosts | `number` | - |
| `start_index` | Index incremental de depart | `number` | `1` |
| `vm_size` | SKU de la VM | `string` | - |
| `admin_username` / `admin_password` | Identifiants administrateur local | `string` | - |
| `subnet_id` | ID du subnet existant | `string` | - |
| `zones` | Availability Zones disponibles (repartition round-robin par index, `[]` = pas de zone) | `list(string)` | `[]` |
| `os_disk_type` | Type de disque managed | `string` | `Premium_LRS` |
| `source_image_reference` | Image marketplace (`publisher`/`offer`/`sku`/`version`) | `object` | - |
| `entra_id_join` | Jonction Microsoft Entra ID | `bool` | `true` |
| `host_pool_name` / `registration_token` | Reference et token du Host Pool | `string` (sensible pour le token) | - |
| `avd_agent_package_url` | URL du package DSC de l'agent AVD | `string` | - |

## Outputs

| Nom | Description |
|-----|-------------|
| `session_host_names` | Noms des VM (ressources Azure) |
| `session_host_ids` | IDs des VM |
| `computer_names` | Noms Windows tronques (15 caracteres) |
| `network_interface_ids` | IDs des cartes reseau |

## Exemple d'utilisation

```hcl
module "session_host" {
  source = "git::https://github.com/servier-github/terraform-az-modules.git//Avd/SessionHost?ref=poc"

  resource_group_name = "EM50-NPR-AVD00-POC-RG01"
  location            = "France Central"

  name_prefix        = "AVDMADMSYS1"
  session_host_count = 2
  start_index        = 1

  vm_size        = "Standard_D4s_v5"
  admin_username = "avdlocaladmin"
  admin_password = var.admin_password

  subnet_id    = data.azurerm_subnet.avd.id
  os_disk_type = "Premium_LRS"

  source_image_reference = {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "windows-11"
    sku       = "win11-23h2-avd"
    version   = "latest"
  }

  host_pool_name        = "MADMSYS1"
  registration_token    = var.registration_token
  avd_agent_package_url = "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_1.0.02790.442.zip"

  APPLICATION_ID      = "AVD00"
  servier_environment = "POC"
  backup_policy       = "NONPROD"
}
```

## Changelog

| Version | Description |
|---------|-------------|
| 1.1.0 | Ajout de `zones` (Availability Zones, repartition round-robin) |
| 1.0.0 | Creation initiale du module |
