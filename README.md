#Zálohování uživatelských stanic s OS Linux.

##Duplicity

Primárním zálohovacím nástrojem je [Duplicity](http://duplicity.nongnu.org/).
Jedná se o řádkový nástroj, který umožňuje vytváře šifrované přírůstkové zálohy.
Podporuje více způsobů, jak / kam zálohy ukládat:

* lokální adresář
* rsync
* ssh
* ftp
* ... a spoustu dalších, viz. [dokumentace](http://duplicity.nongnu.org/duplicity.1.html)

##Duply

[Duply](http://sourceforge.net/projects/ftplicity/) je řádkový nástroj, který "zapouzdřuje" *Duplicity*.
Usnadňuje jeho konfiguraci a zjednodušuje jeho ovládání.

## GIT Repository *desktop-backup*

Tato GIT repository obsahuje ukázkovou konfiguraci pro *Duply* a několik podpůrných skriptů,
které práci s *Duply* dále usnadňují. 

#Instalace

Pomocí libovolného programu pro správu balíků OS instalujeme příslušné dva balíky a jejich závislosti:

    aptitude install duplicity duply

Do libovolného adresáře si stáhneme GIT Repository:

    git clone https://github.com/FgForrest/desktop-backup.git

GIT Repository obsahuje vzorový profil pro *Duply*:

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
Konfigurace profilu je v souboru [`<profile>/conf`](https://github.com/FgForrest/desktop-backup/blob/master/duply/profile/test-exampleProfile/conf).
Vzorový profil osahuje bohatě komentovanou základní konfiguraci.
Zde je třeba změnit:

* `GPG_PW='__CHANGE_ME__'` - zvolit heslo, kterým budou zálohy šifrovány 
* `SOURCE='/home/...'` - přepsat na cestu ke svému domácímu adresáři 
* `TARGET='file:///home/mpe/SHARE/FG/nas2/....'` - přepsat cílovou cestu, nebo zvolit úplně jiný cíl záloh

Síťové disky, které lze pro zálohování na pobočkách použít, jsou popsány [na Jáchymovi](http://jachym.fg.cz/cs/jachym-info/1299.html). 

##Soubor výjimek
Konfigurace obsahu záloh je v souboru [`<profile>/exclude`](https://github.com/FgForrest/desktop-backup/blob/master/duply/profile/test-exampleProfile/exclude).
Název `exclude` je poněkud zavádějící, protože v něm nastavujeme co zálohovat i co nezálohovat.

Během zálohy se pro každý soubor nebo adresář v adresáři `TARGET` rozhoduje, jestli ho zálohovat, nebo ne.
Pokud je `exclude` soubor prázdný, zálohuje se vše. Pokud jsou v souboru nějaká pravidla, procházejí zhora dolů.
První pravidlo, kterému soubor nebo adresář vyhoví, určí, jestli se zálohovat bude (+) nebo nebude (-)
a další pravidla už se ignorují. Podrobně je vše popsáno v dokumentaci *Duplicity*.

Příklad 1: 

    ## Zálohuj SSH klíče, ostatní adresáře začínající tečkou vynech.
    + /home/mpe/.ssh/
    - /home/mpe/.*
    
    ## Vynech některé další adresáře
    - /home/mpe/SHARE
    - /home/mpe/Videos
    - /home/mpe/VirtualBox VMs

    ## Vše ostatní zálohuj

Příklad 2:

    ## Zálohuj některé adresáře
    + /home/mpe/.ssh/
    + /home/mpe/Documents
    
    ## Vše ostatní vynech
    - **

##Cron skript
Ve skriptu [`<profile>/backup-cron.sh`](https://github.com/FgForrest/desktop-backup/blob/master/duply/profile/test-exampleProfile/backup-cron.sh)
je třeba upravit cestu k cíli záloh:

    ## only backup if in FG local network
    ../../../scripts/isInFgNetwork.sh -e "/home/mpe/SHARE/FG/nas2/..." \
        || { echo "Not in FG local network, exiting..."; exit 0; }


#Použití

##Ruční práce se zálohami

Pro ruční ovládání záloh slouží skript [`<profile>/duply.sh <command>`](https://github.com/FgForrest/desktop-backup/blob/master/duply/profile/test-exampleProfile/duply.sh)`.
Příklad:

    cd desktop-backup/duply/profile/moje
    ./duply.sh status

Příkazy jsou popsány v dokumentaci *Duply*. Několik nejdůležitějších:

* `usage` - vypíše podrobný návod 
* `status` - vypíše stav a seznam dostupných záloh
* `list [age]` - vypíše seznam souborů v záloze (v poslední nebo před specifikovaným časem)  
* `verify` - vypíše rozdíly v zálohovaném adresáři proti poslední záloze 
* `backup` - provede zálohu, automaticky rozhodne, jestli *full* nebo *incremental*
* `full` - provede *full* zálohu
* `restore <target directory> [age]` - obnoví celou zálohu
* `fetch <rel. path in backup> <target directory> [age]` - obnoví jeden konkrétní soubor / adresář

##Automatické zálohy

Pro automatické zálohování slouží skript [`<profile>/backup-cron.sh`](https://github.com/FgForrest/desktop-backup/blob/master/duply/profile/test-exampleProfile/backup-cron.sh).
Skript ve vzorovém profilu provádí toto:

* Ověří, že je spuštěn v lokální FG síti a že existuje cílový adresář na sdíleném disku.
    Pokud ne, ukončí se a zálohu neprovede. (Skript [`isInFgNetwork.sh`](https://github.com/FgForrest/desktop-backup/blob/master/scripts/isInFgNetwork.sh)) 
* Uklidí případné pozůstatky po neůspěšných zálohách
* Provede zálohu
* Smaže nadbytečné záloh (podle nastavení proměnných `MAX_AGE` a `MAX_FULL_BACKUPS` v konfiguračním souboru profilu)

Skript je třeba pravidelně spouštět, třeba pomocí systémového plánovače `cron`.
