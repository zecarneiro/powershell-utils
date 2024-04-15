: Author: José M. C. Noronha
@echo off

doskey log=powershell.exe log $*
doskey errorlog=powershell.exe errorlog $*
doskey infolog=powershell.exe infolog $*
doskey warnlog=powershell.exe warnlog $*
doskey oklog=powershell.exe oklog $*
doskey promptlog=powershell.exe promptlog $*
doskey titlelog=powershell.exe titlelog $*
doskey headerlog=powershell.exe headerlog $*
doskey separatorlog=powershell.exe separatorlog $*
