: Author: José M. C. Noronha
@echo off

doskey cutadvanced=powershell.exe cutadvanced $*
doskey extract=powershell.exe "extract" $*
doskey openurl=powershell.exe openurl $*
doskey hasinternet=powershell.exe hasinternet
doskey mypubip=powershell.exe mypubip
doskey download=powershell.exe download $*
doskey sha1=powershell.exe sha1 $*
doskey md5=powershell.exe md5 $*
doskey sha256=powershell.exe sha256 $*
doskey df=powershell.exe df
doskey wslshutdown=powershell.exe wslshutdown $*
doskey wslconfigadvanced=powershell.exe wslconfigadvanced
