<#PSScriptInfo

    .VERSION 2.0.1

    .GUID f8e1f634-6755-4e1d-b824-7516cadc690d

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
using namespace System.Management.Automation

function Write-Log {
    [CmdletBinding(
        DefaultParameterSetName = "Type"
    )]
    [OutputType([void])]

    ## PARAMETERS #############################################################
    param (
        [Parameter(
            Mandatory,
            DontShow,
            ParameterSetName = "PSEventArgs"
        )]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSEventArgs]
        $PSEventArgs,

        [Parameter(
            ParameterSetName = "Type"
        )]
        [ValidateSet("Log", "Information", "Warning", "Error")]
        [string]
        $Type = "Log",

        [Parameter(
            Position = 0,
            Mandatory,
            ParameterSetName = "Type"
        )]
        [string]
        $Message
    )

    ## BEGIN ##################################################################
    begin {
        if (-not $PSLogDetails) {
            $PSCmdlet.ThrowTerminatingError(
                [ErrorRecord]::new(
                    ([PSInvalidOperationException] "An error occurred writing the log: The host is not currently logging."),
                    "InvalidOperation",
                    [ErrorCategory]::InvalidOperation,
                    $null
                )
            )
        } else {
            $TypeMap = @{
                Log         = "LOG"
                Information = "INFO"
                Warning     = "WARN"
                Error       = "ERROR"
            }

            $Template = {
                "{0:$( $Format[0] )}`t[{1}]`t{2}" -f $DateTime.($Format[1]).Invoke(), $TypeMap.$Type, $Message
            }

            if ($PSEventArgs) {
                $DateTime = $PSEventArgs.TimeGenerated

                switch ($PSEventArgs.SourceIdentifier) {
                    "PSLogInformation" {
                        $Type = "Information"
                        $Message = $PSEventArgs.SourceEventArgs.NewItems.MessageData
                    }
                    "PSLogWarning" {
                        $Type = "Warning"
                        $Message = $PSEventArgs.SourceEventArgs.NewItems.Message
                    }
                    "PSLogError" {
                        $Type = "Error"
                        $Message = $PSEventArgs.SourceEventArgs.NewItems.Exception.Message
                    }
                }
            } else {
                $DateTime = [datetime]::Now
            }
        }
    }

    ## PROCESS ################################################################
    process {
        :Main foreach ($PSLog in $PSLogDetails) {
            try {
                $Format = $PSLog.Utc | ?: { "yyyy\-MM\-dd HH:mm:ss\Z", "ToUniversalTime" } { "yyyy\-MM\-dd HH:mm:ss", "ToLocalTime" }

                Use-Object ($File = [File]::AppendText($PSLog.Path)) {
                    $File.WriteLine($Template.Invoke()[0])
                }

                ## EXCEPTIONS #################################################
            } catch [MethodInvocationException] {
                $PSCmdlet.WriteError(
                    [ErrorRecord]::new(
                        $_.Exception.InnerException,
                        "MethodException",
                        [ErrorCategory]::InvalidOperation,
                        $PSLog
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
    }
}
