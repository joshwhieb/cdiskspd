function Run-ProcessAsAdministrator($path, $arguments)
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
    $process.Start() | Out-Null
    $output = $process.StandardOutput.ReadToEnd() 
    $process.WaitForExit()
    $process.Dispose()
    $exitCode = $process.ExitCode 
    return $output,$exitCode
}

function Run-Diskspd($path = "C:\Program Files\Diskspd\amd64fre\diskspd.exe", $arguments, $deleteTestFile)
{
    $output, $exitCode = run-ProcessAsAdministrator -path $path -arguments $arguments

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

    if($exitCode -ne 0)
    {
        throw "Nonzero exit code returned from diskspd"
    }
    else
    {
        return $output,$exitCode
    }
}



## $output, $exitcode = run-ProcessAsAdministrator -path "C:\program files\Diskspd\amd64fre\diskspd.exe" -arguments @("-c1G","-b4K","-t2","-d10", "-a0,1", "testfile1.dat", "testfile2.dat")