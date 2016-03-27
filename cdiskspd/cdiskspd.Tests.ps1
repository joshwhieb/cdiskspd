$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"


Describe "cdiskspd"{
    Context "Exit code checks"{
        It "Returns exit code 3. Function throws exception for nonzero exit code."{
            Mock Run-ProcessAsAdministrator { "output, read, write", "3" }
            {Run-Diskspd -arguments @()} | Should throw
        }
        It "Returns exit code 0. Correct call to diskspd and function runs without error."{
            Mock Run-ProcessAsAdministrator {"output, read, write", "0"}
            $output, $error = Run-Diskspd -arguments @("-d10","c1G")
            $error | Should be "0"
        }
    }
    Context "Single file delete"{
        It "Deletes 1 test file that was specified" {
            Mock run-ProcessAsAdministrator {"output, read,write", "0"}
            Mock Test-Path {$true}
            Mock Remove-Item {}
            $diskspdArgs = @{
              arguments   = @("-d10", "-c1G")
              deleteTestFile = @("C:\temp\testfile.dat")
            }
            $output, $error = Run-Diskspd @diskspdArgs
            Assert-MockCalled -CommandName Remove-Item -Times $diskspdArgs.deleteTestFile.Count
        }
    }
    Context "Multiple file deletes"{
        It "Deletes 3 test files that were specified" {
            Mock run-ProcessAsAdministrator {"output, read,write", "0"}
            Mock Test-Path {$true}
            Mock Remove-Item {}
            $diskspdArgs = @{
              arguments   = @("-d10", "-c1G")
              deleteTestFile = @("C:\temp\testfile.dat", "C:\temp\testfile1.dat", "C:\temp\testfile2.dat")
            }
            $output, $error = Run-Diskspd @diskspdArgs
            Assert-MockCalled -CommandName Remove-Item -Times $diskspdArgs.deleteTestFile.Count
        }
    }
}