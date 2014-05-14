#Zálohování uživatelských stanic s OS Linux.

##Duplicity

Primárním zálohovacím nástrojem je [duplicity](http://duplicity.nongnu.org/).
Jedná se o řádkový nástroj, který umožňuje vytváře šifrované přírůstkové zálohy.
Podporuje více způsobů, jak / kam zálohy ukládat:

* lokální adresář
* rsync
* ssh
* ftp
* ... a spoustu dalších, viz. [dokumentace](http://duplicity.nongnu.org/duplicity.1.html)

##Duply

[Duply](http://sourceforge.net/projects/ftplicity/) je řádkový nástroj, který "zapouzdřuje" Duplicity.
Usnadňuje jeho konfiguraci a zjednodušuje jeho ovládání.

## GIT Repository *desktop-backup*

Tato GIT repository obsahuje ukázkovou konfiguraci pro Duply a několik podpůrných skriptů,
které práci s Duply dále usnadňují. 

#Instalace

Pomocí libovolného programu pro správu balíků OS instalujeme příslušné dva balíky a jejich závislosti:

    aptitude install duplicity duply

Do libovolného adresáře si stáhneme GIT Repository:

    git clone git@github.com:FgForrest/desktop-backup.git

GIT Repository obsahuje vzorový profil pro Duply:

    ls -la desktop-backup/duply/profile/test-exampleProfile/

    -rwxrwxr-x 1 mpe mpe  581 May 14 13:50 backup-cron.sh
    -rw-rw-r-- 1 mpe mpe 2276 May 14 13:50 conf
    -rwxrwxr-x 1 mpe mpe  289 May 14 13:50 duply.sh
    -rw-rw-r-- 1 mpe mpe  889 May 14 13:50 exclude

#Konfigurace

Můžeme buď upravit vzorový profil, nebo si vytvořit vlastní. Profilů můžeme mít libovolné množství.
Vlastní profil vytvoříme zkopírováním adresáře vzorového profilu pod jiným jménem:

    cd desktop-backup/duply/profile/
    cp -a test-exampleProfile moje

##Konfigurační soubor
Konfigurace profilu je v souboru `<profile>/conf`. Vzorový profil osahuje bohatě komentovanou základní konfiguraci.
Zde je třeba změnit:

* `SOURCE='/home/...'` - přepsat na cestu ke svému domácímu adresáři 
* `TARGET='file:///home/mpe/SHARE/FG/nas2/....'` - přepsat cílovou cestu, nebo zvolit úplně jiný cíl záloh
* `GPG_PW='__CHANGE_ME__'` - zvolit heslo, kterým budou zálohy šifrovány 

##Soubor výjimek
