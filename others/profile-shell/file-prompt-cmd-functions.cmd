: Author: José M. C. Noronha
@echo off

doskey fileexists=powershell.exe fileexists $*
doskey fileextension=powershell.exe fileextension $*
doskey filename=powershell.exe filename $*
doskey writefile=powershell.exe writefile $*
doskey delfilelines=powershell.exe delfilelines $*
doskey deletefile=powershell.exe deletefile $*
doskey countfiles=powershell.exe countfiles
doskey findfile=powershell.exe findfile $*
doskey movefilestoparent=powershell.exe movefilestoparent
doskey lf=powershell.exe lf
doskey filecontain=powershell.exe filecontain $*
doskey basename=powershell.exe basename $*
doskey touch=powershell.exe touch $*
