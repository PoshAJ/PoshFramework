<#PSScriptInfo

    .VERSION 3.0.2

    .GUID 3dbe34cb-6c77-4df2-a983-14fac15b78ce

    .AUTHOR Anthony J. Raymond

    .COMPANYNAME

    .COPYRIGHT (c) 2022 Anthony J. Raymond

    .TAGS operators null-coalescing ??

    .LICENSEURI https://github.com/CodeAJGit/posh/blob/master/LICENSE

    .PROJECTURI https://github.com/CodeAJGit/posh

    .ICONURI

    .EXTERNALMODULEDEPENDENCIES

    .REQUIREDSCRIPTS

    .EXTERNALSCRIPTDEPENDENCIES

    .RELEASENOTES
        20220908-AJR: 3.0.0 - Initial Release
        20220921-AJR: 3.0.1 - Fix for External Help
        20221115-AJR: 3.0.2 - Moved TryCatch inside ForEach

    .PRIVATEDATA

#>

function Use-NullCoalescing {
    [CmdletBinding()]
    [OutputType([object])]

    ## PARAMETERS #############################################################
    param (
        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [AllowNull()]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [object]
        $InputObject,

        [Parameter(
            Position = 0,
            Mandatory
        )]
        [scriptblock]
        $IfNull
    )

    ## PROCESS ################################################################
    process {
        # wrapping in an array to handle $null as input
        :Main foreach ($Object in @($InputObject)) {
            try {
                if ($null -eq $Object) {
                    . $IfNull
                } else {
                    Write-Output $Object
                }
            } catch {
                $PSCmdlet.WriteError($_)
                continue Main
            }
        }
    }
}


Set-Alias -Name ?? -Value Use-NullCoalescing
