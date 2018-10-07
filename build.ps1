$exclude = @("build.ps1","*.zip")
Get-ChildItem -Path $from -Recurse -Exclude $exclude |
    ForEach-Object { 
        Write-Host $_
        Compress-Archive -LiteralPath $_ -CompressionLevel Optimal -DestinationPath test.zip -Update
    }
