<#PSScriptInfo

    .VERSION 1.0.1

    .GUID c8c8065c-fa7f-435f-a796-c22cd9397bde

    .AUTHOR Anthony J. Raymond

    .COMPANYNAME

    .COPYRIGHT (c) 2022 Anthony J. Raymond

    .TAGS gmsa service credential

    .LICENSEURI https://github.com/CodeAJGit/posh/blob/master/LICENSE

    .PROJECTURI https://github.com/CodeAJGit/posh

    .ICONURI

    .EXTERNALMODULEDEPENDENCIES

    .REQUIREDSCRIPTS

    .EXTERNALSCRIPTDEPENDENCIES

    .RELEASENOTES
        20220921-AJR: 1.0.0 - Initial Release
        20221027-AJR: 1.0.1 - Fixed bug for ADServiceAccount dropping out of scope

    .PRIVATEDATA

#>

using namespace System.Security
using namespace System.Runtime.InteropServices
using namespace System.Management.Automation
using namespace System.DirectoryServices
using namespace System.DirectoryServices.ActiveDirectory

function Get-ADServiceAccountCredential {
    [CmdletBinding()]
    [OutputType([pscredential])]

    # MIT License ~ Copyright (c) 2021 Ryan Ephgrave
    # Modified Get-GMSACredential.ps1 from GMSACredential (https://github.com/Ryan2065/gMSACredentialModule)

    ## PARAMETERS #############################################################
    param (
        [Parameter(
            Position = 0,
            Mandatory,
            ValueFromPipelineByPropertyName,
            ValueFromPipeline
        )]
        [Alias("distinguishedName", "objectGUID", "objectSid", "sAMAccountName")]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Identity,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $Server
    )

    ## BEGIN ##################################################################
    begin {
        $Properties = @(
            @{n = "sAMAccountName"; e = { $_.Properties."samaccountname" } }
            @{n = "Length"; e = { $_.Properties."msds-managedpassword".Length } }
            @{n = "ManagedPassword"; e = {
                    $Length = $_.Properties."msds-managedpassword".Length
                    Write-Output ($IntPtr = [Marshal]::AllocHGlobal($Length))
                    [Marshal]::Copy([byte[]] $_.Properties."msds-managedpassword".ForEach({ $_ }), 0, $IntPtr, $Length)
                }
            }
        )
    }

    ## PROCESS ################################################################
    process {
        :Main foreach ($Object in $Identity) {
            try {
                try {
                    # https://ldapwiki.com/wiki/ObjectGUID
                    $ObjectGUID = ([guid] $Object).ToByteArray().ForEach({ $_.ToString("X2") }) -join "\"
                    $Filter = "(&(objectGUID=\${ObjectGUID})(ObjectCategory=msDS-GroupManagedServiceAccount))"
                } catch {
                    $Filter = "(&(|(distinguishedName=${Object})(objectSid=${Object})(sAMAccountName=$( $Object -ireplace "[^$]$", "$&$" )))(ObjectCategory=msDS-GroupManagedServiceAccount))"
                }

                New-Variable -Name ADServiceAccount -Option AllScope

                Use-Object ($DirectorySearcher = [DirectorySearcher] $Filter) {
                    if ($Server) {
                        $DirectorySearcher.SearchRoot = [DirectoryEntry] "LDAP://${Server}"
                    }

                    $DirectorySearcher.SearchRoot.AuthenticationType = "Sealing"
                    $DirectorySearcher.PropertiesToLoad.AddRange(@("sAMAccountName", "msDS-ManagedPassword"))

                    $ADServiceAccount = $DirectorySearcher.FindOne() | Select-Object -Property $Properties

                    if (-not $ADServiceAccount) {
                        throw [ErrorRecord]::new(
                            [ActiveDirectoryObjectNotFoundException] "Cannot find an object with identity: '${Object}' under: '$( $DirectorySearcher.SearchRoot.distinguishedName )'.",
                            "ObjectException",
                            [ErrorCategory]::ObjectNotFound,
                            $Object
                        )
                    } elseif ($ADServiceAccount.Length -eq 0) {
                        throw [ErrorRecord]::new(
                            [ActiveDirectoryOperationException] "Cannot retrieve service account password. A process has requested access to an object, but has not been granted those access rights.",
                            "OperationException",
                            [ErrorCategory]::PermissionDenied,
                            $Object
                        )
                    }
                }

                # https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-adts/a9019740-3d73-46ef-a9ae-3ea8eb86ac2e
                $SecureString = ConvertTo-SecureString -String ([Marshal]::PtrToStringUni([int64] $ADServiceAccount.ManagedPassword + 16)) -AsPlainText -Force

                Write-Output ([pscredential]::new($ADServiceAccount.sAMAccountName, $SecureString))
                ## EXCEPTIONS #################################################
            } catch [SetValueInvocationException] {
                $PSCmdlet.WriteError(
                    [ErrorRecord]::new(
                        [ActiveDirectoryServerDownException] "Unable to contact the server. This may be because this server does not exist, it is currently down, or it does not have the Active Directory Services running.",
                        "ServerException",
                        [ErrorCategory]::ResourceUnavailable,
                        $null
                    )
                )
                continue Main
            } catch {
                $PSCmdlet.WriteError($_)
                continue Main
            } finally {
                if ($ADServiceAccount) {
                    [Marshal]::Copy([byte[]]::new($ADServiceAccount.Length), 0, $ADServiceAccount.ManagedPassword, $ADServiceAccount.Length)
                    [Marshal]::FreeHGlobal($ADServiceAccount.ManagedPassword)

                    $ADServiceAccount = $SecureString = $null
                    $null = [GC]::GetTotalMemory($true)
                }
            }
        }
    }

    ## END ####################################################################
    end {
    }
}
