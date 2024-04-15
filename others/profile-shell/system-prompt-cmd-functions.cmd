: Author: José M. C. Noronha
@echo off

doskey reboot=powershell.exe reboot
doskey shutdown=powershell.exe "shutdown"
doskey evaladvanced=powershell.exe evaladvanced $*
doskey commandexists=powershell.exe commandexists $*
doskey addalias=powershell.exe addalias $*
doskey addaliascmd=powershell.exe addaliascmd $*
doskey isadmin=powershell.exe isadmin
doskey editalias=powershell.exe editalias
doskey editaliascmd=powershell.exe editaliascmd
doskey editprofile=powershell.exe editprofile
doskey editcustomprofile=powershell.exe editcustomprofile
doskey editcustomprofilecmd=powershell.exe editcustomprofilecmd
doskey reloadprofile=powershell.exe reloadprofile
doskey ver=powershell.exe "ver"
doskey uptime=powershell.exe uptime
doskey ix=powershell.exe "ix"
doskey which=powershell.exe which $*
doskey export=SET $*
doskey pkill=powershell.exe pkill $*
doskey pgrep=powershell.exe pgrep $*
doskey restartexplorer=powershell.exe restartexplorer
