@{

    RootModule        = "ScriptFramework.psm1"

    ModuleVersion     = "1.1.2"

    # CompatiblePSEditions = @()

    GUID              = "c91f141d-3103-49f0-8813-88a68479ae3e"

    Author            = "Anthony J. Raymond"

    # CompanyName = ""

    Copyright         = "(c) 2022 Anthony J. Raymond"

    Description       = "Simple framework that can be used to build PowerShell script and modules."

    # PowerShellVersion = ""

    # PowerShellHostName = ""

    # PowerShellHostVersion = ""

    # DotNetFrameworkVersion = ""

    # CLRVersion = ""

    # ProcessorArchitecture = ""

    # RequiredModules = @()

    # RequiredAssemblies = @()

    # ScriptsToProcess = @()

    # TypesToProcess = @()

    # FormatsToProcess = @()

    # NestedModules = @()

    FunctionsToExport = @(
        "Resolve-PSPath"
        "Start-Log"
        "Write-Log"
        "Stop-Log"
        "Use-NullCoalescing"
        "Use-Object"
        "Use-Ternary"
        "Get-ADServiceAccountCredential"
    )

    CmdletsToExport   = @()

    VariablesToExport = ""

    AliasesToExport   = @(
        "using"
        "?:"
        "??"
    )

    # DscResourcesToExport = @()

    # ModuleList = @()

    # FileList = @()

    PrivateData       = @{

        PSData = @{

            Tags         = @(
                "script"
                "framework"
                "log"
            )

            LicenseUri   = "https://github.com/CodeAJGit/posh/blob/master/LICENSE"

            ProjectUri   = "https://github.com/CodeAJGit/posh"

            # IconUri = ""

            ReleaseNotes =
            @"
    20220914-AJR: 1.0.0 - Initial Release
    20220921-AJR: 1.1.0 - Added Get-ADServiceAccountCredential
    20221027-AJR: 1.1.2 - Fixed bug in Get-ADServiceAccountCredential
"@

        }

    }

    HelpInfoURI       = "https://github.com/CodeAJGit/posh/blob/master/Modules/ScriptFramework/readme.md"

    # DefaultCommandPrefix = ""

}
