[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True)]
    [string]$Root,
    [Parameter()]
    [string]$DiffOutput,
    [Parameter()]
    [switch]$IgnoreErrors # allows one to just format
)

$Root = Resolve-Path -LiteralPath $Root

# it is very frustrating that this method is not an existing cmdlet
# This is like Resolve-Path, but it also allows DiffOutput to not exist
$DiffOutput = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($DiffOutput)

$clangFormat = Get-Command 'clang-format' -ErrorAction 'SilentlyContinue'
if ($null -ne $clangFormat)
{
    $clangFormat = $clangFormat.Source
}

if ($IsWindows)
{
    if ([String]::IsNullOrEmpty($clangFormat) -or -not (Test-Path $clangFormat))
    {
        $clangFormat = 'C:\Program Files\LLVM\bin\clang-format.exe'
    }
    if (-not (Test-Path $clangFormat))
    {
        $clangFormat = 'C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Tools\Llvm\x64\bin\clang-format.exe'
    }
}

if ([String]::IsNullOrEmpty($clangFormat) -or -not (Test-Path $clangFormat))
{
    Write-Error 'clang-format not found; is it installed?'
    throw
}

$toolsrc = Get-Item "$Root/toolsrc"
Push-Location $toolsrc

try
{
    $files = Get-ChildItem -Recurse -LiteralPath "$toolsrc/src" -Filter '*.cpp'
    $files += Get-ChildItem -Recurse -LiteralPath "$toolsrc/include/vcpkg" -Filter '*.h'
    $files += Get-ChildItem -Recurse -LiteralPath "$toolsrc/include/vcpkg-test" -Filter '*.h'
    $files += Get-Item "$toolsrc/include/pch.h"
    $fileNames = $files.FullName

    & $clangFormat -style=file -i @fileNames

    $changedFiles = & "$PSScriptRoot/Get-ChangedFiles.ps1" -Directory $toolsrc
    if (-not $IgnoreErrors -and $null -ne $changedFiles)
    {
        $msg = @(
            "",
            "The formatting of the C++ files didn't match our expectation.",
            "See github.com/microsoft/vcpkg/blob/master/docs/maintainers/maintainer-guide.md#vcpkg-internal-code for solution."
        )
        $msg += "File list:"
        $msg += "    $changedFiles"
        $msg += ""

        if (-not [String]::IsNullOrEmpty($DiffOutput))
        {
            $msg += "You can access the diff from clang-format.diff in the build artifacts,"
            $msg += 'and apply the patch with `git apply`'
            # in order to avoid mangling diff output with `r`n
            $msg += "(debug): Writing git diff to $DiffOutput"
            Start-Process -FilePath 'git' -ArgumentList 'diff' `
                -NoNewWindow -Wait `
                -RedirectStandardOutput $DiffOutput
        }

        Write-Error ($msg -join "`n")
        throw
    }
}
finally
{
    Pop-Location
}
