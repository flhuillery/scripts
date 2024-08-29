Add-Type -AssemblyName System.Windows.Forms

# Création du formulaire
$form = New-Object System.Windows.Forms.Form
$form.Text = "Informations système"
$form.Size = New-Object System.Drawing.Size(400, 400)

# Création du bouton pour les services
$buttonServices = New-Object System.Windows.Forms.Button
$buttonServices.Text = "Lister les services auto"
$buttonService.AutoSize = $true
$buttonServices.Location = New-Object System.Drawing.Point(100, 50)

# Création du bouton pour les informations système
$buttonInfo = New-Object System.Windows.Forms.Button
$buttonInfo.Text = "Afficher les infos système"
$buttonInfo.AutoSize = $true
$buttonInfo.Location = New-Object System.Drawing.Point(100, 100)

# Création de la liste
$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Location = New-Object System.Drawing.Point(10, 150)
$listBox.Size = New-Object System.Drawing.Size(380, 150)

# Événement du bouton pour les services
$buttonServices.Add_Click({
    $services = Get-Service | Where-Object {$_.StartType -eq 'Automatic'} | Sort-Object -Property Name
    $listBox.Items.Clear()
    foreach ($service in $services) {
        [void]$listBox.Items.Add($service.DisplayName)
    }
})

# Événement du bouton pour les informations système
$buttonInfo.Add_Click({
    $systemInfo = Get-CimInstance Win32_ComputerSystem
    $cpuInfo = Get-CimInstance Win32_Processor
    $ramInfo = Get-CimInstance Win32_PhysicalMemory

    $info = "Marque : $($systemInfo.Manufacturer)" + "`n" +
            "Modèle : $($systemInfo.Model)" + "`n" +
            "Processeur : $($cpuInfo.Name)" + "`n" +
            "Fréquence : $($cpuInfo.MaxClockSpeed) MHz" + "`n" +
            "RAM : $($ramInfo | Measure-Object -Property Capacity -Sum).Sum MB"

    [System.Windows.Forms.MessageBox]::Show($info)
})

# Ajout des contrôles au formulaire
$form.Controls.Add($buttonServices)
$form.Controls.Add($buttonInfo)
$form.Controls.Add($listBox)

# Affichage du formulaire
[void]$form.ShowDialog()
