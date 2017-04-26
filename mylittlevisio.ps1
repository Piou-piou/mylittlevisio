Set-ExecutionPolicy bypass

$destination = "127.0.0.1"

#============== CREATION FICHIER - BASE ===============================================
$date = Get-Date -format dd.MM.yyyy-hh.mm

$infoprocesseur = Get-WmiObject -Class Win32_Processor -ComputerName $destination | Select-Object -Property [a-z]*
$nom = $infoprocesseur.PSComputerName

#local
New-Item "C:\wamp64\www\powershell\$nom" –type Directory
New-Item "C:\wamp64\www\powershell\$nom\$date.php" -ItemType File

$chemin = "C:\wamp64\www\powershell\$nom\$date.php"

#============== CREATION SCRIPT - PHP schéma disque ============================
$scriptgraph1 = "C:\wamp64\www\powershell\scriptgraph1.php"
$scriptengraph1 = "C:\wamp64\www\powershell\scriptendgraph1.php"



#============== HTML ===========================================================
ADD-content -path $chemin -value '<hml><head><meta charset="utf-8" /></head><link href="http://127.0.0.1/powershell/style.css" rel="stylesheet" type="text/css" /><body>'
ADD-content -path $chemin -value '<img src="http://127.0.0.1/powershell/logo.jpg"><br>'










#============== DATE ===========================================================
ADD-content -path $chemin -value $date

ADD-content -path $chemin -value "<br>"





#============== DOMAIN =========================================================
ADD-content -path $chemin -value "<h1>Inforamtion</h1>"
#début tableau - t1

ADD-content -path $chemin -value "<table>" #html - début t1

$domain = Get-WmiObject -Class Win32_ComputerSystem
$domainpc = $domain.Domain
ADD-content -path $chemin -value "<tr><td><h2>Domain</h2></td><td>$domainpc</td></tr>"


#============== NOM PC =========================================================

ADD-content -path $chemin -value "<tr><td><h2>System Name</h2></td><td>$nom</td></tr>" #html - début tr1 et début td1 et FIN


#============== Manufacturer =========================================================
$manufacturer = Get-WmiObject -Class Win32_ComputerSystem
$Manufacturerpc = $manufacturer.Manufacturer


ADD-content -path $chemin -value "<tr><td><h2>Manufacturer</h2></td><td>$Manufacturerpc</td></tr>"






#============== USER ===========================================================
#début tableau - t2
Get-WmiObject -Class Win32_Desktop -ComputerName .
ADD-content -path $chemin -value "<tr><td><h2>Last User</h2></td><td>$env:USERNAME</td></tr>" #html - début tr2 et début td2 et FIN










#============== OS =====================================================
$a = get-itemproperty -path registry::"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
$aproductname = $a.ProductName 
ADD-content -path $chemin -value "<tr><td><h2>O.S</h2></td><td>$aproductname" #la ligne se finis dans partie 32 ou 64 bits ?

ADD-content -path $chemin -value " - "

#============== 32 ou 64 bits ?? ===============================================
if ([intptr]::size -eq 8)
{
   ADD-content -path $chemin -value "64bits</td>" 
}
elseif ([intptr]::size -eq 4)
{
   ADD-content -path $chemin -value "32bits</td>"
}
else
{
   ADD-content -path $chemin -value "ERROR</td>"
}

#============== VERSION D'OS ===================================================

$versionos = get-WmiObject Win32_operatingsystem
$versionos = $versionos.version
ADD-content -path $chemin -value "<tr><td><h2>Version O.S</h2></td><td>$versionos</td></tr>"

ADD-content -path $chemin -value "</table>" #html - fin t1











#============== DISQUE =========================================================
ADD-content -path $chemin -value "<h1>Disque</h1>"
#début tableau - t2
ADD-content -path $chemin -value "<table>" #html - début t2

$disques = get-WmiObject Win32_LogicalDisk
$disques | Select-Object model, index, mediatype
$taille_totale = 0 # initialisation de la variable
    $computerdisque = 0
# boucle pour parcourir tous les disques
foreach ( $disque in $disques ) { 
    # calul de la taille en Giga octet
    $tailledisque = $disque.freespace / (1024*1024*1024)
    $tailledisque = [math]::round($tailledisque, 1) # Arrondi la taille à 1 décimale 

    $nomdisque=$disque.Name
    ADD-content -path $chemin -value "<tr><td><h2>$nomdisque</h2></td>"
    $taille_totale = $taille_totale + $taille
    $computerdisque= $computerdisque + 1 
    
    if ($tailledisque -gt "50")
    {
    ADD-content -path $chemin -value "<td><font color='green'>$tailledisque"
    ADD-content -path $chemin -value "</font>Go</td></tr>"
     } 
    else 
    { 
    ADD-content -path $chemin -value "<td><font color='red'>$tailledisque" 
    ADD-content -path $chemin -value "</font>Go</td></tr>"
    }

    #graphique - A modifier en cas de changement de chemin
    $nomdisquesplit = $nomdisque -split ":"
    $basegraph1 = "C:\wamp64\www\powershell\$nom\$nomdisquesplit.php"
    #historique schéma .txt
    New-Item $basegraph1 -ItemType File
    ADD-content -path $basegraph1 -value "['$date',$tailledisque],"

    ADD-content -path $chemin -value "<?php include('$scriptgraph1'); ?>"
    ADD-content -path $chemin -value "<?php include('$basegraph1'); ?>"
    ADD-content -path $chemin -value "<?php include('$scriptengraph1'); ?>"






}


ADD-content -path $chemin -value "<th colspan='2'>Total disques :"
ADD-content -path $chemin -value "$computerdisque</th>"

#fin tableau - t2
ADD-content -path $chemin -value "</table>" #html - fin t2
ADD-content -path $chemin -value "<br>"






#============== RAM =============================================================
ADD-content -path $chemin -value "<h1>RAM</h1>"
ADD-content -path $chemin -value "<br>"

$memory = get-WmiObject Win32_PhysicalMemory
$memory_totale = 0

#début tableau - t3
ADD-content -path $chemin -value "<table>" #html - début t3

foreach ( $cap in $memory ) { 
    # calul de la taille en Giga octet
    $memory_onebarrette = $cap.capacity / 1Gb
    $memory_totale = $memory_totale + $memory_onebarrette
    ADD-content -path $chemin -value "<tr><td>$memory_onebarrette"
    ADD-content -path $chemin -value "x1 Go</td></tr>"
}
    ADD-content -path $chemin -value "<tr><th>Total RAM : $memory_totale</th></tr>"
ADD-content -path $chemin -value "</table>" #html - début t3








#============== MATERIELS ========================================================
ADD-content -path $chemin -value "<h1>Materiels</h1>"
#début tableau - t4
ADD-content -path $chemin -value "<table>" #html - début t4

#=========== Processor ==============
$processor =  get-WmiObject Win32_Processor
$processor = $processor.name
ADD-content -path $chemin -value "<tr><td><h2>Processeur</h2></td><td>$processor</td></tr>"



#=== ventilo ===
$fan = get-WmiObject Win32_fan
$fan = $fan.status
    if ($fan -eq "OK")
    {
    ADD-content -path $chemin -value "<tr><td><h2>Ventilateur</h2></td><td><font color='green'>OK</font></td></tr>"
     } 
    else 
    { 
    ADD-content -path $chemin -value "<tr><td><h2>Ventilateur</h2></td><td><font color='red'>ERROR</font></td></tr>"
    }

ADD-content -path $chemin -value "</table>" #html - début t4











#============== HTML ===========================================================
ADD-content -path $chemin -value "</body></html>"