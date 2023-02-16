---
external help file: ScriptFramework-help.xml
Module Name: ScriptFramework
online version: https://github.com/CodeAJGit/posh/blob/master/Modules/ScriptFramework/docs/Resolve-PSPath.md
schema: 2.0.0
---

# Resolve-PSPath

## SYNOPSIS
Resolves a path with wildcard support.

## SYNTAX

### Path
```
Resolve-PSPath [-Path] <String[]> [-Provider] [<CommonParameters>]
```

### LiteralPath
```
Resolve-PSPath -LiteralPath <String[]> [-Provider] [<CommonParameters>]
```

## DESCRIPTION
The Resolve-PSPath cmdlet resolves a drive or provider qualified absolute or relative path that may contain wildcard characters into one or more provider-internal paths.

## PARAMETERS

### -LiteralPath
Specifies the path to be resolved. The value of the LiteralPath parameter is used exactly as typed. No characters are interpreted as wildcard character

```yaml
Type: String[]
Parameter Sets: LiteralPath
Aliases: PSPath

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Path
Specifies the PowerShell path to resolve.

```yaml
Type: String[]
Parameter Sets: Path
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Provider
Outputs the PSProvider for the specified path(s).

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### String
You can pipe a string that contains a path to this cmdlet.

## OUTPUTS

### String
Returns a string value for the resolved path.

### System.Management.Automation.ProviderInfo
Returns a ProviderInfo object if you specify the Provider parameter.

## NOTES
This cmdlet is designed to work with the data exposed by any provider. To list the providers available in your session, type Get-PSProvider. For more information, see [about_Providers](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_providers).

## RELATED LINKS
[https://docs.microsoft.com/en-us/dotnet/api/system.management.automation.pathintrinsics.getresolvedproviderpathfrompspath]()
[https://docs.microsoft.com/en-us/dotnet/api/system.management.automation.pathintrinsics.getunresolvedproviderpathfrompspath]()
