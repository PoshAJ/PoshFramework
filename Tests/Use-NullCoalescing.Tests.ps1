Describe "Use-NullCoalescing" {
    BeforeAll {
        ## SOURCE #############################################################
        Import-Module "$PSScriptRoot\..\ScriptFramework.psm1"

        ## SETUP ##############################################################
    }

    ## SUCCESS ################################################################
    Context "Success" {
        It "Null" {
            $Test = $null | ?? { "VALUE" }
            $Test | Should -be "VALUE"
        }

        It "Not Null" {
            $Test = "VALUE" | ?? { 1 / 0 }
            $Test | Should -be "VALUE"
        }
    }

    ## FAILURE ################################################################
    Context "Failure" {
    }

    AfterAll {
        ## CLEAN UP ###########################################################
    }
}
