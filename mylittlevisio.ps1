# Copyright 2017 Nicolas Luc Gérard PILLOUD
# version 1.1

#Chemin d'Install Ultime
$ultimatepath = "C:\mylittlevisio\" 
$rootpath = $ultimatepath

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

#============== FUNCTION ECRITURE CHEMIN ===============================================
function do_racine
{
$rootpath = $textBox.Text
new-item "$rootpath\_config\rootpath.txt" –type file -force
$rootpathfile = "$rootpath\config\rootpath.txt"
Add-Content -Path $rootpathfile -Value $rootpath
}

#============== FUNCTION fastexec ===============================================
function do_fastexec
{
# Force le type d'execution
Set-ExecutionPolicy bypass

# Adresess IP visé
$destination = $textBox1.Text






#============== CREATION FICHIER - BASE ===============================================
# Prend la date du serveur local
$date = Get-Date -format dd.MM.yyyy-hh.mm
# Get du ComputerName vers la destination
$infoprocesseur = Get-WmiObject -Class Win32_Processor -ComputerName $destination | Select-Object -Property [a-z]*
$nom = $infoprocesseur.PSComputerName



#================INDICATION DU REPERTOIRE RACINE - UNIQUE VARIABLE A MODIFIER ! ========================
$rootpath = $ultimatepath

#Variable indicatif - NE PAS MODIFIER
New-Item "$rootpath\$nom" -Type Directory
New-Item "$rootpath\$nom\$date.html" -ItemType File
New-Item "$rootpath\$nom\_save" -Type Directory
# Chemin appliquer dans une variable
$path = "$rootpath\$nom\$date.html"
$pathparent = "$rootpath\$nom"
$pathsave = "$rootpath\$nom\_save"








#============== HTML ===========================================================
# First balise HTML et CSS
$pathCSS = "$rootpath\_config\style.css"
ADD-content -path $path -value "<hml><head><meta charset='utf-8' /></head><link href='$pathCSS' rel='stylesheet' type='text/css' /><body>"
# Chemin logo
ADD-content -path $path -value '<img src="http://127.0.0.1/powershell/logo.jpg"><br>'










#============= MAIL INFO =====================================================
# Informations address du serveur de messagerie
$smtpServer = "smtp.example.org"
# Address Expéditeur
$from = "mylittlevisio <mylittlevisio@example.fr>"
# Adresse Reception
$to = "Helpdesk <npilloud@example.fr>"








#============== TIME ===========================================================
# Get DATE a distance vers destinations
$datedistant = Get-WmiObject -Class Win32_LocalTime -ComputerName $destination | Select-Object -Property [a-z]*
# Split et mise en forme de la DATE
$datedistantday = $datedistant.day -split "="
$datedistantmonth = $datedistant.month -split "="
$datedistantyear = $datedistant.year -split "="
$datedistanthour = $datedistant.hour -split "="
$datedistantminute = $datedistant.Minute -split "="

# Début tableau TIME
ADD-content -path $path -value "<h1>Time</h1>"
ADD-content -path $path -value "<table>" #html - début t1
#Ligne affichage HTML valeur TIME local server
ADD-content -path $path -value "<tr><td><h2>Heure server</h2></td><td>$date</td></tr>"
#Ligne affiachage HTML valeur TIME disatant
ADD-content -path $path -value "<tr><td><h2>Heure Poste</h2></td><td>$datedistantday.$datedistantmonth.$datedistantyear-$datedistanthour.$datedistantminute</td></tr>"
#fin tableau TIME
ADD-content -path $path -value "</table>" #html - fin t2
ADD-content -path $path -value "<br>"



#============== INFO INTERFACE ======================
# Début tableau INTERAFCE
ADD-content -path $path -value "<h1>Interface</h1>"
ADD-content -path $path -value "<table>" #html - début t1


$allinterface = get-wmiobject -class "Win32_NetworkAdapterConfiguration" -computername $destination |Where{$_.IpEnabled -Match "True"} 



 foreach ($oneinterface in $allinterface) 
    {
    $oneinterfacedesscription = $oneinterface.Description
    $oneinterfaceMAC = $oneinterface.MACAddress  
    #Ligne affichage HTML valeur INTERFACE qui possède une IP
    ADD-content -path $path -value "<tr><td>$oneinterfacedesscription</td><td>$oneinterfaceMAC</td></tr>"  
       
      
    }


#fin tableau TIME
ADD-content -path $path -value "</table>" #html - fin t2
ADD-content -path $path -value "<br>"








#============== DOMAIN =========================================================
ADD-content -path $path -value "<h1>Inforamtion</h1>"
#début tableau - t1

ADD-content -path $path -value "<table>" #html - début t1

$domain = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $destination
$domainpc = $domain.Domain
ADD-content -path $path -value "<tr><td><h2>Domain</h2></td><td>$domainpc</td></tr>"


#============== NOM PC =========================================================

ADD-content -path $path -value "<tr><td><h2>System Name</h2></td><td>$nom</td></tr>" #html - début tr1 et début td1 et FIN


#============== Manufacturer =========================================================
$manufacturer = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $destination
$Manufacturerpc = $manufacturer.Manufacturer


ADD-content -path $path -value "<tr><td><h2>Manufacturer</h2></td><td>$Manufacturerpc</td></tr>"






#============== USER ===========================================================
#début tableau - t2
$userconnecter = Get-WmiObject -Class Win32_ComputerSystem -Property UserName -ComputerName $destination
$userconnecter = $userconnecter.username 
ADD-content -path $path -value "<tr><td><h2>Last User</h2></td><td>$userconnecter</td></tr>" #html - début tr2 et début td2 et FIN










#========================= OS =====================================================
$a = get-itemproperty -path registry::"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
$aproductname = $a.ProductName 
ADD-content -path $path -value "<tr><td><h2>O.S</h2></td><td>$aproductname" #la ligne se finis dans partie 32 ou 64 bits ?

ADD-content -path $path -value " - "




#========================= 32 ou 64 bits ?? ===============================================
if ([intptr]::size -eq 8)
{
   ADD-content -path $path -value "64bits</td>" 
}
elseif ([intptr]::size -eq 4)
{
   ADD-content -path $path -value "32bits</td>"
}
else
{
   ADD-content -path $path -value "ERROR</td>"
}






#========================= VERSION D'OS ===================================================

$versionos = get-WmiObject Win32_operatingsystem
$versionos = $versionos.version
ADD-content -path $path -value "<tr><td><h2>Version O.S</h2></td><td>$versionos</td></tr>"

ADD-content -path $path -value "</table>" #html - fin t1











#============================ DISQUE =========================================================
ADD-content -path $path -value "<h1>Disque physique</h1>"
#début tableau - t2
ADD-content -path $path -value "<table>" #html - début t2

$disques = Get-WmiObject -Class Win32_LogicalDisk -Filter "DriveType=3" -ComputerName $destination
$taille_totale = 0 # initialisation de la variable
    $computerdisque = 0
# boucle pour parcourir tous les disques
foreach ( $disque in $disques ) { 
    # calul de la taille en Giga octet
    $tailledisque = $disque.freespace / (1024*1024*1024)
    $tailledisque = [math]::round($tailledisque, 1) # Arrondi la taille à 1 décimale 

    $nomdisque=$disque.Name
    ADD-content -path $path -value "<tr><td><h2>$nomdisque</h2></td>"
    $taille_totale = $taille_totale + $taille
    $computerdisque= $computerdisque + 1 
    
    if ($tailledisque -gt "50")
    {
    ADD-content -path $path -value "<td><font color='green'>$tailledisque"
    ADD-content -path $path -value "</font>Go</td></tr>"
     } 
    else 
    { 
    ADD-content -path $path -value "<td><font color='red'>$tailledisque" 
    ADD-content -path $path -value "</font>Go</td></tr>"






# Envoie du MAIL d'information WARNING : espace faible
            $subject = "[WARNING] Mylittlevisio : '$nom' "
            $body = "<html><head></head><body><p>Low disk space for $nomdisque only $tailledisque .</p></body></html>"

Send-MailMessage -smtpserver $smtpserver -from $from -to $to -subject $subject -body $body -bodyasHTML -priority High
    }
}


ADD-content -path $path -value "<th colspan='2'>Total disques :"
ADD-content -path $path -value "$computerdisque</th>"






# Création du fichier "numberdisk.txt" qui sauvegarde le nombre de disque ! Ne s'écrase pas !
new-item $pathsave -name "numberdisk.txt" -type file
$computerdisquehistorique = Get-Content $pathsave\numberdisk.txt
$comparedisk = compare-object $computerdisquehistorique $computerdisque
#compare le nombre de disque ACTUEL avec le nombre de disque HISORIQUE - Si ERREUR envoie de mail !
if ($comparedisk)
{
            $subject = "[WARNING] Mylittlevisio : '$nom' "
            $body = "<html><head></head><body><p>Un disque est manquant !</p></body></html>"
}


#fin tableau - t2
ADD-content -path $path -value "</table>" #html - fin t2
ADD-content -path $path -value "<br>"












#============== RAM =============================================================
ADD-content -path $path -value "<h1>RAM</h1>"
ADD-content -path $path -value "<br>"

$memory = get-WmiObject Win32_PhysicalMemory
$memory_totale = 0

#début tableau - t3
ADD-content -path $path -value "<table>" #html - début t3

foreach ( $cap in $memory ) { 
    # calul de la taille en Giga octet
    $memory_onebarrette = $cap.capacity / 1Gb
    $memory_totale = $memory_totale + $memory_onebarrette
    ADD-content -path $path -value "<tr><td>$memory_onebarrette"
    ADD-content -path $path -value "x1 Go</td></tr>"
}
    ADD-content -path $path -value "<tr><th>Total RAM : $memory_totale</th></tr>"
ADD-content -path $path -value "</table>" #html - début t3




# Création du fichier "numberdisk.txt" qui sauvegarde le nombre de disque ! Ne s'écrase pas !
new-item $pathsave -name "numberram.txt" -type file
$memory_totalehistorique = Get-Content $pathsave\numberram.txt
$compareram = compare-object $memory_totalehistorique $memory_totale
#compare le nombre de disque ACTUEL avec le nombre de disque HISORIQUE - Si ERREUR envoie de mail !
if ($compareram)
{
            $subject = "[WARNING] Mylittlevisio : '$nom' "
            $body = "<html><head></head><body><p>Une RAM est manquant !</p></body></html>"
}




#fin tableau - t2
ADD-content -path $path -value "</table>" #html - fin t2
ADD-content -path $path -value "<br>"












#============== MATERIELS ========================================================
ADD-content -path $path -value "<h1>Materiels</h1>"
#début tableau - t4
ADD-content -path $path -value "<table>" #html - début t4

#=========== Processor ==============
$processor =  get-WmiObject Win32_Processor
$processor = $processor.name
ADD-content -path $path -value "<tr><td><h2>Processeur</h2></td><td>$processor</td></tr>"



#=== ventilo ===
$fan = get-WmiObject Win32_fan
$fan = $fan.status
    if ($fan -eq "OK")
    {
    ADD-content -path $path -value "<tr><td><h2>Ventilateur</h2></td><td><font color='green'>OK</font></td></tr>"
     } 
    else 
    { 
    ADD-content -path $path -value "<tr><td><h2>Ventilateur</h2></td><td><font color='red'>ERROR</font></td></tr>"
    }

ADD-content -path $path -value "</table>" #html - début t4











#============== HTML ===========================================================
ADD-content -path $path -value "</body></html>"
}



#============== FUNCTION Reset CSS ===============================================
function do_resetCSS
{

#============= Chemin appliquer dans une variable ==================
$path = "$rootpath\$nom\$date.html"
$pathparent = "$rootpath\$nom"
$pathsave = "$rootpath\$nom\_save"
$pathCSS = "$rootpath\_config\style.css"

new-item "$pathCSS" –type file -force
Add-Content -Path "$pathCSS"-Value "
body {
	width: 580px;
	color: #000;
	font-family: Verdana,'Trebuchet MS','Lucida Grande', Arial, sans-serif;
	font-size: .8em;
	line-height: 1.25em;
	margin: auto;
	padding: 10px;
	text-align: center;
}

img {
	width: 35%;
	padding: 10px;
}

h1 {
	font-family:Georgia, Tahoma, Arial, Serif;
	font-weight:normal;
	line-height:1.6em;
	padding: 0;
	margin: 0;
}

h2 { /* colonne de gauche des tableaux */
   font-weight: bold;
   	font-family:Georgia, Tahoma, Arial, Serif;
	font-weight:normal;
	line-height:1.6em;
	padding: 0;
	margin: 0;
}

table {
	background: #345;
	margin-bottom: 10px;
	width: 580px;
}

th {
	background: #eee;	
}

td {
	background: #eee;
	text-align: center;
	vertical-align: center;
}

img.pass {
	width: 25;
	padding: 0px;
}

div#chart_div {
	padding: 10px;
}













dl#csschart, dl#csschart dt, dl#csschart dd
{
    margin:0;
    padding:0;
}
 
dl#csschart
{
    background:url(bg_chart.gif) no-repeat 0 0;
    width:467px;
    height:385px;
}

dl#csschart dt
{
    display:none;
}    

dl#csschart dd
{
    position:relative;
    float:left;
    display:inline;
    width:33px;
    height:330px;
    margin-top:22px;
} 
 
dl#csschart dd.first
{
    margin-left:33px;               
}            
  
dl#csschart span
{
    position:absolute;
    display:block;
    width:33px; 
    bottom:0;
    left:0; 
    z-index:1;
    color:#555;
    text-decoration:none;
}
 
dl#csschart span em
{
    display:block;
    font-style:normal;
    float:left;
    line-height:200%;
    background:#fff;
    color:#555;
    border:1px solid #b1b1b1;
    position:absolute;
    top:50%;
    left:3px;
    text-align:center;
    width:23px;
}            
  
dl#csschart span.p0{height:0%;}
dl#csschart span.p1{height:1%;}
dl#csschart span.p2{height:2%;}
.
.
.
dl#csschart span.p100{height:100%;}
"

}





#============== Instance Fenetre ===============================================
$form = New-Object System.Windows.Forms.Form 
$form.Text = "Data Entry Form"
$form.Size = New-Object System.Drawing.Size(1000,1000) 
$form.StartPosition = "CenterScreen"



<#============== CANCEl ===============================================
$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Point(150,120)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = "Cancel"
$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $CancelButton
$form.Controls.Add($CancelButton)
#>



#============== TEXT - Installation Path : ===============================================
$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20) 
$label.Size = New-Object System.Drawing.Size(280,20) 
$label.Text = "Installation path :"
$form.Controls.Add($label) 
#============== TEXTBOX ===============================================
$textBox = New-Object System.Windows.Forms.TextBox 
$textBox.Location = New-Object System.Drawing.Point(10,40) 
$textBox.Size = New-Object System.Drawing.Size(260,20)
$textBox.Text = $ultimatepath  
$form.Controls.Add($textBox) 
#============== BUTTON Lance action FUNCTION ECRITURE CHEMIN ===============================================
$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Point(275,39)
$OKButton.Size = New-Object System.Drawing.Size(75,22)
$OKButton.Text = "OK"
$OKButton.Add_Click({do_racine} ) #action bouton
$form.AcceptButton = $OKButton
$form.Controls.Add($OKButton)


#============== TEXT - Reset CSS : ===============================================
$label2 = New-Object System.Windows.Forms.Label
$label2.Location = New-Object System.Drawing.Point(400,20) 
$label2.Size = New-Object System.Drawing.Size(280,20) 
$label2.Text = "Reset CSS :"
$form.Controls.Add($label2)  
#============== BUTTON Lance action FUNCTION ECRITURE CHEMIN ===============================================
$OKButton2 = New-Object System.Windows.Forms.Button
$OKButton2.Location = New-Object System.Drawing.Point(400,39)
$OKButton2.Size = New-Object System.Drawing.Size(75,22)
$OKButton2.Text = "OK"
$OKButton2.Add_Click({do_resetCSS} ) #action bouton
$form.AcceptButton = $OKButton2
$form.Controls.Add($OKButton2)





#============== TEXT - Fast execution : : ===============================================
$label1 = New-Object System.Windows.Forms.Label
$label1.Location = New-Object System.Drawing.Point(10,120) 
$label1.Size = New-Object System.Drawing.Size(280,20) 
$label1.Text = "Fast Execution :"
$form.Controls.Add($label1) 
#============== TEXTBOX ===============================================
$textBox1 = New-Object System.Windows.Forms.TextBox 
$textBox1.Location = New-Object System.Drawing.Point(10,140) 
$textBox1.Size = New-Object System.Drawing.Size(260,20) 
$textBox1.Text = ""
$form.Controls.Add($textBox1) 
#============== BUTTON Lance action FUNCTION ECRITURE CHEMIN ===============================================
$OKButton1 = New-Object System.Windows.Forms.Button
$OKButton1.Location = New-Object System.Drawing.Point(275,139)
$OKButton1.Size = New-Object System.Drawing.Size(75,22)
$OKButton1.Text = "OK"
$OKButton1.Add_Click({do_fastexec} ) #action bouton
$form.AcceptButton = $OKButton1
$form.Controls.Add($OKButton1)




#=== END ===
$form.Topmost = $True

$result = $form.ShowDialog()