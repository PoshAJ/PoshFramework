<#PSScriptInfo

    .VERSION 2.0.1

    .GUID f89136dc-37a0-4a12-bb4a-f2fda0248b60

    .AUTHOR Anthony J. Raymond

    .COMPANYNAME

    .COPYRIGHT (c) 2022 Anthony J. Raymond

    .TAGS using idisposable comobject

    .LICENSEURI https://github.com/CodeAJGit/posh/blob/master/LICENSE

    .PROJECTURI https://github.com/CodeAJGit/posh

    .ICONURI

    .EXTERNALMODULEDEPENDENCIES

    .REQUIREDSCRIPTS

    .EXTERNALSCRIPTDEPENDENCIES

    .RELEASENOTES
        20220908-AJR: 2.0.0 - Initial Release
        20220921-AJR: 2.0.1 - Fix for External Help

    .PRIVATEDATA

#>

using namespace System.Runtime.InteropServices

function Use-Object {
    [CmdletBinding()]
    [OutputType([void])]

    ## PARAMETERS #############################################################
    param (
        [Parameter(
            Position = 0,
            Mandatory
        )]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [AllowNull()]
        [object]
        $InputObject,

        [Parameter(
            Position = 1,
            Mandatory
        )]
        [scriptblock]
        $Scriptblock
    )

    ## PROCESS ################################################################
    process {
        try {
            . $Scriptblock
        } catch {
            throw $_
        } finally {
            foreach ($Object in $InputObject) {
                if ($Object -is [IDisposable]) {
                    $Object.Dispose()
                } elseif ($Object -is [__ComObject]) {
                    $null = [Marshal]::ReleaseComObject($Object)
                }
            }
        }
    }
}


Set-Alias -Name using -Value Use-Object
