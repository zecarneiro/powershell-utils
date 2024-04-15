: Author: José M. C. Noronha
@echo off

doskey gouserotherapps=cd /d "%HOMEDRIVE%%HOMEPATH%\otherapps"
doskey gouserconfig=cd /d "%HOMEDRIVE%%HOMEPATH%\.config"
doskey directoryexists=powershell.exe directoryexists $*
doskey deletedirectory=powershell.exe deletedirectory $*
doskey deleteemptydirs=powershell.exe deleteemptydirs
doskey gohome=cd /d "%HOMEDRIVE%%HOMEPATH%"
doskey cd..=cd ..
doskey ..=cd..
doskey ldir=powershell.exe ldir
doskey countdirs=powershell.exe countdirs
doskey dirname=powershell.exe dirname $*
