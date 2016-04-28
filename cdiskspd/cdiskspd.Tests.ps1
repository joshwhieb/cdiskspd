$script:here = Split-Path -Parent $MyInvocation.MyCommand.Path
$script:sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.ps1", ".psm1")
$script:modName = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.ps1", "")
$script:pathtosut = join-path $script:here $script:sut

if (get-module -name $modName) { remove-module -Name $modName }

$script:t = [scriptblock]::Create(( gc $script:pathtosut -Raw ) )
New-Module -Name $modName -ScriptBlock $t  | Import-Module -Force

Describe "cdiskspd"{
    Context "Single file delete"{
        It "Deletes 1 test file that was specified" {
            Mock Start-ProcessAsAdministrator {"output, read,write", "0"} -ModuleName $modName
            Mock Test-Path {return $true} -ModuleName $modName
            Mock Remove-Item {return $null} -ModuleName $modName
            $diskspdArgs = @{
              arguments   = @("-d10", "-c1G")
              deleteTestFile = @("C:\temp\testfile.dat")
            }
            $output, $error = Start-Diskspd @diskspdArgs
            Assert-MockCalled -CommandName Remove-Item -Times $diskspdArgs.deleteTestFile.Count -ModuleName $modName
        }
    }
    Context "Multiple file deletes"{
        It "Deletes 3 test files that were specified" {
            Mock Start-ProcessAsAdministrator {"output, read,write", "0"} -ModuleName $modName
            Mock Test-Path {$true} -ModuleName $modName
            Mock Remove-Item {} -ModuleName $modName
            $diskspdArgs = @{
              arguments   = @("-d10", "-c1G")
              deleteTestFile = @("C:\temp\testfile.dat", "C:\temp\testfile1.dat", "C:\temp\testfile2.dat")
            }
            $output, $error = Start-Diskspd @diskspdArgs
            Assert-MockCalled -CommandName Remove-Item -Times $diskspdArgs.deleteTestFile.Count -ModuleName $modName
        }
    }
}