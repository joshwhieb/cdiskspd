<#
.Synopsis
   Runs a process in this shell as administrator
.DESCRIPTION
   Runs a process in this shell as administrator
.EXAMPLE
   Start-ProcessAsAdministrator -path "C:\program files\diskspd\amd64fre\diskspd.exe
#>
function Start-ProcessAsAdministrator
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [string]
        $path,

        # Param2 help description
        [string[]]
        $arguments
    )

    Begin
    {
        $psi = New-object System.Diagnostics.ProcessStartInfo 
        $psi.CreateNoWindow = $true 
        $psi.UseShellExecute = $false 
        $psi.RedirectStandardOutput = $true 
        $psi.RedirectStandardError = $true 
        $psi.FileName = $path
        $psi.Arguments = $arguments 
        $process = New-Object System.Diagnostics.Process 
        $process.StartInfo = $psi 
        $process.StartInfo.Verb = "RunAs"
    }
    Process
    {
        $process.Start() | Out-Null
        $output = $process.StandardOutput.ReadToEnd() 
        $process.WaitForExit()
        $process.Dispose()
        $exitCode = $process.ExitCode 
    }
    End
    {
        return $output,$exitCode
    }
}

<#
.Synopsis
   Runs the diskspd executable
.DESCRIPTION
   Runs the diskspd exe.  Will throw exception if an invalid exit code is caught.  Has the feature to delete test files.
.EXAMPLE
    $args = @{
        path = "C:\program files\Diskspd\amd64fre\diskspd.exe"
        arguments = @("-c1G","-b4K","-t2","-d10", "-a0,1", "C:\temp\testfile1.dat", "C:\temp\testfile2.dat")
        deleteTestFile = @("C:\temp\testfile1.dat", "C:\temp\testfile2.dat")
    }

    $output, $exitCode = Start-Diskspd @args
    $output
#>
function Start-Diskspd
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        # Param1 help descripti
        $path = "C:\Program Files\Diskspd\amd64fre\diskspd.exe",

        # Param2 help description
        [string[]]
        $arguments,

        [string[]]
        $deleteTestFile
    )

    Begin
    {
        $output = $null
        $exitCode = $null
    }
    Process
    {
        $output, $exitCode = Start-ProcessAsAdministrator -path $path -arguments $arguments

        # Delete the test file if the variable exists
        if($deleteTestFile)
        {
            foreach($testFilePath in $deleteTestFile)
            {
                if(Test-Path $testFilePath)
                {
                    Remove-Item -Path $testFilePath -Force -Recurse
                }
                else
                {
                    Write-Debug "The testfile path does not exist.  Not deleting."
                }
            }
        }
    }
    End
    {
        if($exitCode -ne 0 -and $exitCode -ne $null)
        {
            throw "Nonzero exit code returned from diskspd: $exitCode"
        }
        else
        {
            return $output,$exitCode
        }
    }
}

Export-ModuleMember Start-ProcessAsAdministrator
Export-ModuleMember Start-Diskspd