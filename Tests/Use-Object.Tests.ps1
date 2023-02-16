Describe "Use-Object" {
    BeforeAll {
        ## SOURCE #############################################################
        Import-Module "$PSScriptRoot\..\ScriptFramework.psm1"

        ## SETUP ##############################################################
    }

    ## SUCCESS ################################################################
    Context "Success" {
        It "IDisposable" {
            $Test = {
                Use-Object ($Disposable = [System.IO.File]::OpenRead($PSCommandPath)) {}
                $Disposable.ReadByte()
            }
            $Test | Should -Throw "*: ""Cannot access a closed file."""
        }

        It "ComObject" {
            $Test = {
                Use-Object ($ComObject = New-Object -ComObject WScript.Shell) {}
                $ComObject
            }
            $Test | Should -Throw "COM object that has been separated from its underlying RCW cannot be used."
        }
    }

    ## FAILURE ################################################################
    Context "Failure" {
    }

    AfterAll {
        ## CLEAN UP ###########################################################
    }
}
