Describe "Resolve-PSPath" {
    BeforeAll {
        ## SOURCE #############################################################
        Import-Module "$PSScriptRoot\..\ScriptFramework.psm1"

        ## SETUP ##############################################################
        Push-Location "$PSScriptRoot"

        $Path = Get-Item "*"
        $LiteralPath = Get-Item -LiteralPath "."
    }

    ## SUCCESS ################################################################
    Context "Success" {
        It "Path" {
            $Test = Resolve-PSPath "*"
            $Test | Should -Be $Path.FullName
        }

        It "LiteralPath" {
            $Test = Resolve-PSPath -LiteralPath "."
            $Test | Should -Be $LiteralPath.FullName
        }

        It "Path & Provider" {
            $Test = Resolve-PSPath "*" -Provider
            $Test | Should -Be $Path.PSProvider[0]
        }

        It "LiteralPath & Provider" {
            $Test = Resolve-PSPath -LiteralPath "." -Provider
            $Test | Should -Be $LiteralPath.PSProvider
        }
    }

    ## FAILURE ################################################################
    Context "Failure" {
        It "PathNotFound" {
            $Test = { Resolve-PSPath "\\ThrowError" -ErrorAction Stop }
            $Test | Should -Throw "Cannot find path '*' because it does not exist."
        }
    }

    AfterAll {
        ## CLEAN UP ###########################################################
        Pop-Location
    }
}
