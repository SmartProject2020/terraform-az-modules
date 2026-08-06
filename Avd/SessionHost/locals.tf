locals {
  # Nom complet de la ressource Azure (peut depasser 15 caracteres)
  vm_names = [
    for i in range(var.session_host_count) : "${upper(var.name_prefix)}-${var.start_index + i}"
  ]

  # Nom Windows (computer_name) — limite NetBIOS a 15 caracteres
  computer_names = [for n in local.vm_names : substr(n, 0, 15)]

  common_tags = merge(data.azurerm_resource_group.rg.tags, {
    "managed-by"          = "terraform"
    "module"              = "avd-sessionhost"
    "application-id"      = var.APPLICATION_ID
    "backup-policy"       = var.backup_policy
    "servier-environment" = var.servier_environment
  })

  # ============================================================================
  # FSLogix — installation agent + cles de registre Profile/Logging.
  # Reference : https://learn.microsoft.com/fslogix/reference-configuration-settings
  # ============================================================================
  fslogix_script = <<-EOT
    $ErrorActionPreference = 'Stop'

    $zipPath = Join-Path $env:TEMP 'fslogix.zip'
    $extractPath = Join-Path $env:TEMP 'fslogix'
    Invoke-WebRequest -Uri 'https://aka.ms/fslogix_download' -OutFile $zipPath -UseBasicParsing
    Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force
    Start-Process -FilePath (Join-Path $extractPath 'x64\Release\FSLogixAppsSetup.exe') -ArgumentList '/install','/quiet','/norestart' -Wait -PassThru | Out-Null

    New-Item -Path 'HKLM:\SOFTWARE\FSLogix\Profiles' -Force | Out-Null
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\FSLogix\Profiles' -Name 'Enabled' -Type DWord -Value 1
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\FSLogix\Profiles' -Name 'VHDLocations' -Type MultiString -Value @('${var.fslogix_vhd_locations}')
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\FSLogix\Profiles' -Name 'SizeInMBs' -Type DWord -Value ${var.fslogix_size_in_mb}
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\FSLogix\Profiles' -Name 'IsDynamic' -Type DWord -Value ${var.fslogix_is_dynamic ? 1 : 0}
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\FSLogix\Profiles' -Name 'VolumeType' -Type String -Value '${var.fslogix_volume_type}'
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\FSLogix\Profiles' -Name 'FlipFlopProfileDirectoryName' -Type DWord -Value ${var.fslogix_flip_flop_profile_directory_name ? 1 : 0}
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\FSLogix\Profiles' -Name 'DeleteLocalProfileWhenVHDShouldApply' -Type DWord -Value ${var.fslogix_delete_local_profile_when_vhd_should_apply ? 1 : 0}
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\FSLogix\Profiles' -Name 'AccessNetworkAsComputerObject' -Type DWord -Value ${var.fslogix_access_network_as_computer_object ? 1 : 0}
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\FSLogix\Profiles' -Name 'KeepLocalDir' -Type DWord -Value ${var.fslogix_keep_local_dir ? 1 : 0}
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\FSLogix\Profiles' -Name 'PreventLoginWithFailure' -Type DWord -Value ${var.fslogix_prevent_login_with_failure ? 1 : 0}
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\FSLogix\Profiles' -Name 'RoamIdentity' -Type DWord -Value ${var.fslogix_roam_identity ? 1 : 0}
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\FSLogix\Profiles' -Name 'RoamSearch' -Type DWord -Value ${var.fslogix_roam_search}
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\FSLogix\Profiles' -Name 'NoProfileContainingFolder' -Type DWord -Value ${var.fslogix_no_profile_containing_folder ? 1 : 0}
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\FSLogix\Profiles' -Name 'VHDNameMatch' -Type String -Value '${var.fslogix_vhd_name_match}'
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\FSLogix\Profiles' -Name 'VHDNamePattern' -Type String -Value '${var.fslogix_vhd_name_pattern}'

    New-Item -Path 'HKLM:\SOFTWARE\FSLogix\Logging' -Force | Out-Null
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\FSLogix\Logging' -Name 'LoggingEnabled' -Type DWord -Value ${var.fslogix_logging_enabled}
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\FSLogix\Logging' -Name 'LoggingLevel' -Type DWord -Value ${var.fslogix_logging_level}
  EOT
}
