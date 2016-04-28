Try{
    $here = Split-Path -Parent $MyInvocation.MyCommand.Path
    $sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".FunctionalTests.", ".")
    
    Import-Module (Join-Path $here cdiskspd.psm1)

    $args = @{
        path = "C:\program files\Diskspd\amd64fre\diskspd.exe"
        arguments = @("-c1G","-b4K","-t2","-d10", "-a0,1", "C:\temp\testfile1.dat", "C:\temp\testfile2.dat")
        deleteTestFile = @("C:\temp\testfile1.dat", "C:\temp\testfile2.dat")
    }

    $output = Start-Diskspd @args

    Write-host "Test Output: $output"

    if((Test-Path C:\temp\testfile1.dat) -or (Test-Path C:\temp\testfile2.dat))
    {
        throw "did not delete the test files after completion."
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