<#PSScriptInfo

    .VERSION 2.0.1

    .GUID 95a4093a-bdad-4888-9435-75f4b0648226

    .AUTHOR Anthony J. Raymond

    .COMPANYNAME

    .COPYRIGHT (c) 2022 Anthony J. Raymond

    .TAGS pslog log logging

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

using namespace System.IO
using namespace System.Text
using namespace System.Management.Automation
using namespace System.Collections.ObjectModel

function Start-Log {
    [CmdletBinding(DefaultParameterSetName = "Path")]
    [OutputType([void])]

    ## PARAMETERS #############################################################
    param (
        [Parameter(
            Position = 0,
            ValueFromPipelineByPropertyName,
            ValueFromPipeline,
            ParameterSetName = "Path"
        )]
        [Parameter(
            Position = 0,
            ValueFromPipelineByPropertyName,
            ValueFromPipeline,
            ParameterSetName = "PathAppend"
        )]
        [Parameter(
            Position = 0,
            ValueFromPipelineByPropertyName,
            ValueFromPipeline,
            ParameterSetName = "PathNoClobber"
        )]
        [ValidateScript({ # Validate IsFileSystem
                if ((Resolve-PSPath -Path $_ -Provider).Name -ne "FileSystem") {
                    throw "The argument specified must resolve to a valid path on the FileSystem provider."
                } else {
                    $true
                }
            })]
        [ValidateScript({ # Validate IsPath
                if (Test-Path -Path $_ -IsValid) {
                    $true
                } else {
                    throw "The argument specified must resolve to a valid file or folder path."
                }
            })]
        [string[]]
        $Path = [Environment]::GetFolderPath("MyDocuments"),

        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = "LiteralPath"
        )]
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = "LiteralPathAppend"
        )]
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = "LiteralPathNoClobber"
        )]
        [Alias("PSPath")]
        [ValidateScript({ # Validate IsFileSystem
                if ((Resolve-PSPath -LiteralPath $_ -Provider).Name -ne "FileSystem") {
                    throw "The argument specified must resolve to a valid path on the FileSystem provider."
                } else {
                    $true
                }
            })]
        [ValidateScript({ # Validate IsPath
                if (Test-Path -LiteralPath $_ -IsValid) {
                    $true
                } else {
                    throw "The argument specified must resolve to a valid file or folder path."
                }
            })]
        [string[]]
        $LiteralPath,

        [Parameter(ParameterSetName = "PathAppend")]
        [Parameter(ParameterSetName = "LiteralPathAppend")]
        [switch]
        $Append,

        [Parameter(ParameterSetName = "PathNoClobber")]
        [Parameter(ParameterSetName = "LiteralPathNoClobber")]
        [switch]
        $NoClobber,

        [Parameter()]
        [switch]
        $AsUtc,

        [Parameter()]
        [switch]
        $PassThru
    )

    ## BEGIN ##################################################################
    begin {
        $DateTime = [datetime]::Now

        $Format = $AsUtc | ?: { "yyyy\-MM\-dd HH:mm:ss\Z", "ToUniversalTime", "yyyyMMdd\-HHmmss\Z" } { "yyyy\-MM\-dd HH:mm:ss", "ToLocalTime", "yyyyMMdd\-HHmmss" }
        $FileMode = $Append | ?: { [FileMode]::Append } { $NoClobber | ?: { [FileMode]::CreateNew } { [FileMode]::Create } }

        $Template = {
            "**********************"
            "Windows PowerShell log start"
            "Version: {0} ({1})" -f $PSVersionTable.PSVersion, $PSVersionTable.PSEdition
            "Start time: {0:$( $Format[0] )}" -f $DateTime.($Format[1]).Invoke()
            "**********************"
        }
    }

    ## PROCESS ################################################################
    process {
        $Process = ($PSCmdlet.ParameterSetName -cmatch "^LiteralPath") | ?: { Resolve-PSPath -LiteralPath $LiteralPath } { Resolve-PSPath -Path $Path }

        :Main foreach ($Item in $Process) {
            try {
                if (-not ($LogDir = [DirectoryInfo] (Split-Path $Item -Parent)).Exists) {
                    $LogDir = [Directory]::CreateDirectory($LogDir.FullName)
                }

                if (-not ($LogFile = [FileInfo] (Split-Path $Item -Leaf)).Extension) {
                    $LogDir = [Directory]::CreateDirectory($LogDir.FullName + "\" + $LogFile.Name)

                    $LogFile = [FileInfo] ("PowerShell_log.{0}.{1:$( $Format[2] )}.txt" -f ([guid]::NewGuid() -isplit "-")[0], $DateTime.($Format[1]).Invoke())
                }

                Use-Object ($File = [File]::Open($LogDir.FullName + "\" + $LogFile.Name, $FileMode)) {
                    if ($Append) {
                        $NewLine = [Encoding]::UTF8.GetBytes([Environment]::NewLine)
                        $File.Write($NewLine, 0, $NewLine.Length)
                    }

                    foreach ($Line in $Template.Invoke()) {
                        $Bytes = [Encoding]::UTF8.GetBytes($Line + [Environment]::NewLine)
                        $File.Write($Bytes, 0, $Bytes.Length)
                    }
                }

                $Global:PSLogDetails += @(@{ Path = $File.Name; Utc = $AsUtc })
                Write-Information -InformationAction Continue -MessageData "Log started, output file is '$( $File.Name )'" -InformationVariable null
                ## EXCEPTIONS #################################################
            } catch [MethodInvocationException] {
                $PSCmdlet.WriteError(
                    [ErrorRecord]::new(
                        $_.Exception.InnerException,
                        "MethodException",
                        [ErrorCategory]::InvalidOperation,
                        $Item
                    )
                )
                continue Main
            } catch {
                $PSCmdlet.WriteError($_)
                continue Main
            }
        }
    }

    ## END ####################################################################
    end {
        if (-not (Get-EventSubscriber | Where-Object SourceIdentifier -CMatch "^PSLog") -and $PSLogDetails) {
            $Global:PSLogInformation = [ObservableCollection[InformationRecord]]::new()
            $Global:PSLogWarning = [ObservableCollection[WarningRecord]]::new()
            $Global:PSLogError = [ObservableCollection[ErrorRecord]]::new()

            $Action = { Write-Log -PSEventArgs $Event }

            $null = Register-ObjectEvent -EventName CollectionChanged -InputObject $PSLogInformation -SourceIdentifier PSLogInformation -Action $Action
            $null = Register-ObjectEvent -EventName CollectionChanged -InputObject $PSLogWarning -SourceIdentifier PSLogWarning -Action $Action
            $null = Register-ObjectEvent -EventName CollectionChanged -InputObject $PSLogError -SourceIdentifier PSLogError -Action $Action

            $Global:PSDefaultParameterValues["Write-Information:InformationVariable"] = "+PSLogInformation"
            $Global:PSDefaultParameterValues["Write-Warning:WarningVariable"] = "+PSLogWarning"
            $Global:PSDefaultParameterValues["Write-Error:ErrorVariable"] = "+PSLogError"
        }

        if ($PassThru) {
            Write-Output $PSLogDetails.Path -NoEnumerate
        }
    }
}
