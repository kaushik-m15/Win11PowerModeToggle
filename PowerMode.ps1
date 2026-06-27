Add-Type -AssemblyName PresentationFramework

$code = @'
using System;
using System.Runtime.InteropServices;

public static class PowerApi
{
    [DllImport("powrprof.dll", EntryPoint="PowerSetActiveOverlayScheme")]
    public static extern int PowerSetActiveOverlayScheme(Guid scheme);

    [DllImport("powrprof.dll", EntryPoint="PowerGetEffectiveOverlayScheme")]
    public static extern int PowerGetEffectiveOverlayScheme(out Guid scheme);
}
'@

Add-Type $code

$Balanced   = [Guid]"00000000-0000-0000-0000-000000000000"
$BestPerf   = [Guid]"ded574b5-45a0-4f42-8737-46345c09c238"

$current = [Guid]::Empty
$ret = [PowerApi]::PowerGetEffectiveOverlayScheme([ref]$current)

if ($ret -ne 0) {
    throw "Unable to read current power mode. Error code: $ret"
}

if ($current -eq $Balanced) {
    [PowerApi]::PowerSetActiveOverlayScheme($BestPerf) | Out-Null
    $text = "Best Performance"
}
else {
    [PowerApi]::PowerSetActiveOverlayScheme($Balanced) | Out-Null
    $text = "Balanced"
}

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        WindowStyle="None"
        AllowsTransparency="True"
        Background="Transparent"
        ShowInTaskbar="False"
        Topmost="True"
        ShowActivated="False"
        SizeToContent="WidthAndHeight">
        <Border Background="#DD202020"
                CornerRadius="12"
                Padding="18">
            <TextBlock Name="txt"
                       FontSize="16"
                       FontWeight="Medium"
                       Foreground="White"
                       HorizontalAlignment="Center"
                       TextAlignment="Center"/>
        </Border>
</Window>
"@

$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [Windows.Markup.XamlReader]::Load($reader)
$window.FindName("txt").Text = $text

$timer = New-Object Windows.Threading.DispatcherTimer
$timer.Interval = [TimeSpan]::FromSeconds(2)
$timer.Add_Tick({
    $timer.Stop()
    $window.Close()
})

$timer.Start()

$window.WindowStartupLocation = "Manual"

$window.add_Loaded({
    $workArea = [System.Windows.SystemParameters]::WorkArea
    
    # FIXED: Re-measure runtime sizes explicitly to drop any ghost padding
    $window.Measure([System.Windows.Size]::new([double]::PositiveInfinity, [double]::PositiveInfinity))

    $window.Left = $workArea.Left + (($workArea.Width - $window.DesiredSize.Width) / 2)
    $window.Top = $workArea.Bottom - $window.DesiredSize.Height - 80
})

$window.ShowDialog() | Out-Null