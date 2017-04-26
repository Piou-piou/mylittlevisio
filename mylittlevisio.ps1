# Copyright 2017 Nicolas Luc Gérard PILLOUD
# version 1.0

# Force le type d'execution
Set-ExecutionPolicy bypass

# Adresess IP visé
$destination = "127.0.0.1"






#============== CREATION FICHIER - BASE ===============================================
# Prend la date du serveur local
$date = Get-Date -format dd.MM.yyyy-hh.mm
# Get du ComputerName vers la destination
$infoprocesseur = Get-WmiObject -Class Win32_Processor -ComputerName $destination | Select-Object -Property [a-z]*
$nom = $infoprocesseur.PSComputerName

# Création du fichier HTML sur le serveur local
New-Item "C:\wamp64\www\powershell\$nom" –type Directory
New-Item "C:\wamp64\www\powershell\$nom" –type Directory
New-Item "C:\wamp64\www\powershell\$nom\$date.html" -ItemType File
# Chemin appliquer dans une variable
$chemin = "C:\wamp64\www\powershell\$nom\$date.html"
$cheminparent = "C:\wamp64\www\powershell\$nom"







#============== HTML ===========================================================
# First balise HTML et CSS
ADD-content -path $chemin -value '<hml><head><meta charset="utf-8" /></head><link href="http://127.0.0.1/powershell/style.css" rel="stylesheet" type="text/css" /><body>'
# Chemin logo
ADD-content -path $chemin -value '<img src="http://127.0.0.1/powershell/logo.jpg"><br>'










#============= MAIL INFO =====================================================
# Informations address du serveur de messagerie
$smtpServer = "smtp.example.org"
# Address Expéditeur
$from = "mylittlevisio <mylittlevisio@example.fr>"
# Adresse Reception
$to = "Helpdesk <npilloud@example.fr>"








#============== DATE ===========================================================
# Get DATE a distance vers destinations
$datedistant = Get-WmiObject -Class Win32_LocalTime -ComputerName $destination | Select-Object -Property [a-z]*
# Split et mise en forme de la DATE
$datedistantday = $datedistant.day -split "="
$datedistantmonth = $datedistant.month -split "="
$datedistantyear = $datedistant.year -split "="
$datedistanthour = $datedistant.hour -split "="
$datedistantminute = $datedistant.Minute -split "="

# Début tableau TIME
ADD-content -path $chemin -value "<h1>Time</h1>"
ADD-content -path $chemin -value "<table>" #html - début t1
#Ligne affichage HTML valeur TIME local server
ADD-content -path $chemin -value "<tr><td><h2>Heure server</h2></td><td>$date</td></tr>"
#Ligne affiachage HTML valeur TIME disatant
ADD-content -path $chemin -value "<tr><td><h2>Heure Poste</h2></td><td>$datedistantday.$datedistantmonth.$datedistantyear-$datedistanthour.$datedistantminute</td></tr>"
#fin tableau TIME
ADD-content -path $chemin -value "</table>" #html - fin t2
ADD-content -path $chemin -value "<br>"

ADD-content -path $chemin -value "<br>"





#============== DOMAIN =========================================================
ADD-content -path $chemin -value "<h1>Inforamtion</h1>"
#début tableau - t1

ADD-content -path $chemin -value "<table>" #html - début t1

$domain = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $destination
$domainpc = $domain.Domain
ADD-content -path $chemin -value "<tr><td><h2>Domain</h2></td><td>$domainpc</td></tr>"


#============== NOM PC =========================================================

ADD-content -path $chemin -value "<tr><td><h2>System Name</h2></td><td>$nom</td></tr>" #html - début tr1 et début td1 et FIN


#============== Manufacturer =========================================================
$manufacturer = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $destination
$Manufacturerpc = $manufacturer.Manufacturer


ADD-content -path $chemin -value "<tr><td><h2>Manufacturer</h2></td><td>$Manufacturerpc</td></tr>"






#============== USER ===========================================================
#début tableau - t2
$userconnecter = Get-WmiObject -Class Win32_ComputerSystem -Property UserName -ComputerName $destination
$userconnecter = $userconnecter.username 
ADD-content -path $chemin -value "<tr><td><h2>Last User</h2></td><td>$userconnecter</td></tr>" #html - début tr2 et début td2 et FIN










#========================= OS =====================================================
$a = get-itemproperty -path registry::"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
$aproductname = $a.ProductName 
ADD-content -path $chemin -value "<tr><td><h2>O.S</h2></td><td>$aproductname" #la ligne se finis dans partie 32 ou 64 bits ?

ADD-content -path $chemin -value " - "




#========================= 32 ou 64 bits ?? ===============================================
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






#========================= VERSION D'OS ===================================================

$versionos = get-WmiObject Win32_operatingsystem
$versionos = $versionos.version
ADD-content -path $chemin -value "<tr><td><h2>Version O.S</h2></td><td>$versionos</td></tr>"

ADD-content -path $chemin -value "</table>" #html - fin t1











#============================ DISQUE =========================================================
ADD-content -path $chemin -value "<h1>Disque physique</h1>"
#début tableau - t2
ADD-content -path $chemin -value "<table>" #html - début t2

$disques = Get-WmiObject -Class Win32_LogicalDisk -Filter "DriveType=3" -ComputerName $destination
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






# Envoie du MAIL d'information WARNING : espace faible
            $subject = "[WARNING] Mylittlevisio : '$nom' "
            $body = "<html><head></head><body><p>Low disk space for $nomdisque only $tailledisque .</p></body></html>"

Send-MailMessage -smtpserver $smtpserver -from $from -to $to -subject $subject -body $body -bodyasHTML -priority High
    }
}


ADD-content -path $chemin -value "<th colspan='2'>Total disques :"
ADD-content -path $chemin -value "$computerdisque</th>"






# Création du fichier "numberdisk.txt" qui sauvegarde le nombre de disque ! Ne s'écrase pas !
new-item $cheminparent -name "numberdisk.txt" -type file
$computerdisquehistorique = Get-Content $cheminparent\numberdisk.txt
$comparedisk = compare-object $computerdisquehistorique $computerdisque
#compare le nombre de disque ACTUEL avec le nombre de disque HISORIQUE - Si ERREUR envoie de mail !
if ($comparedisk)
{
            $subject = "[WARNING] Mylittlevisio : '$nom' "
            $body = "<html><head></head><body><p>Un disque est manquant !</p></body></html>"
}


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