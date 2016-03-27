Try{
    $here = Split-Path -Parent $MyInvocation.MyCommand.Path
    $sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".FunctionalTests.", ".")
    
    Import-Module (Join-Path $here cdiskspd.psm1)

    $args = @{
        path = "C:\program files\Diskspd\amd64fre\diskspd.exe"
        arguments = @("-c1G","-b4K","-t2","-d10", "-a0,1", "C:\temp\testfile1.dat", "C:\temp\testfile2.dat")
        deleteTestFile = @("C:\temp\testfile1.dat", "C:\temp\testfile2.dat")
    }

    $output, $exitCode = Start-Diskspd @args

    Write-host "Test Output: $output"

    if($exitCode -ne 0 -and $exitCode -ne $null)
    {
        throw "Nonzero exit code returned from diskspd: $exitCode"
    }
    else
    {
        Write-Host "Functional test result: passed" -ForegroundColor Green
    }
}
Catch
{
    $_.Exception.Message
    Write-Host "Functional test result: failed" -ForegroundColor Red
}