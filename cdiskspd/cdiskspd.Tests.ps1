$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"


Describe "cdiskspd"{
    It "Returns exit code 3. Function throws exception for nonzero exit code."{
        Mock Run-ProcessAsAdministrator { "output, read, write", "3" }
        {Run-Diskspd -arguments @()} | Should throw
    }
    It "Returns exit code 0. Correct call to diskspd and function runs without error."{
        Mock run-ProcessAsAdministrator {"output, read, write", "0"}
        $output, $error = Run-Diskspd -arguments @("-d10","c1G")
        $error | Should be "0"
    }
}