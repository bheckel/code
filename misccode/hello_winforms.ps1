
[void][reflection.assembly]::LoadWithPartialName("System.Windows.Forms")

$toplvlfrm = New-Object Windows.Forms.Form

$toplvlfrm.Text = "My First Form"

$button = New-Object Windows.Forms.Button

$button.Text="Push Me!"
$button.Dock="fill"
#                     scriptblock
#                 ____________________
$button.add_click({$toplvlfrm.close()})

$toplvlfrm.controls.add($button)
$toplvlfrm.Add_Shown({$toplvlfrm.Activate()})
$toplvlfrm.ShowDialog()
