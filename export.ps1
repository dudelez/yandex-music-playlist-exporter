# Create a directory for WebDriver binaries
New-Item -Path "C:\WebDriver\bin" -ItemType Directory -Force

# Check if geckodriver.exe already exists
if (-not (Test-Path "C:\WebDriver\bin\geckodriver.exe")) {
    # Navigate to the directory
    Set-Location -Path "C:\WebDriver\bin"

    # Download geckodriver for Firefox
    Invoke-WebRequest -Uri "https://github.com/mozilla/geckodriver/releases/download/v0.30.0/geckodriver-v0.30.0-win64.zip" -OutFile "geckodriver.zip"

    # Extract the downloaded file
    Expand-Archive -Path "geckodriver.zip" -DestinationPath "C:\WebDriver\bin"

    # Remove the zip file if it exists
    if (Test-Path "C:\WebDriver\bin\geckodriver.zip") {
        Remove-Item -Path "geckodriver.zip"
    }
} else {
    Write-Host "geckodriver.exe already exists. Skipping download and extraction."
}

# Add the directory to system's PATH
$env:Path += ";C:\WebDriver\bin"

# Check if Firefox is installed
if (-not (Test-Path "C:\Program Files\Mozilla Firefox\firefox.exe")) {
    Write-Host "Firefox not found. Installing now..."
    # Open Firefox download page for user to install
    Start-Process -FilePath "https://www.mozilla.org/en-US/firefox/download/thanks/"
    # Wait for the user to complete the Firefox installation
    Read-Host "Firefox installer has been downloaded for you. Please complete the Firefox installation and press Enter to continue..."
}

# Check if Python is installed
function Install-Python {
    # Downloading Python 3.10 installer
    Invoke-WebRequest -Uri "https://www.python.org/ftp/python/3.10.0/python-3.10.0-amd64.exe" -OutFile "python-3.10.0-amd64.exe"
    # Installing Python 3.10
    Start-Process -Wait -FilePath "python-3.10.0-amd64.exe" -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1"
    Remove-Item -Path "python-3.10.0-amd64.exe"
}

$python_installed = $true
$python_version = $null
try {
    $python_version = & { python --version 2>&1 }
} catch {
    $python_installed = $false
}

if ($python_installed) {
    # Extract major and minor version numbers
    $matches = $null
    $python_version -match "Python (\d+)\.(\d+)" | Out-Null
    $major_version = [int]$matches[1]
    $minor_version = [int]$matches[2]

    if ($major_version -eq 3 -and $minor_version -ge 10) {
        Write-Host "Python version 3.10 or newer detected. Skipping installation."
    } else {
        Write-Host "Different version of Python detected. Installing Python 3.10 now..."
        Install-Python
    }
} else {
    Write-Host "Python not found. Installing Python 3.10 now..."
    Install-Python
}

# Install Python dependencies
Write-Host "Installing Python dependencies..."

# Get the directory of the script
$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent

# Installing Python dependencies
Set-Location -Path $scriptDir
pip install -r requirements.txt

Write-Host "All dependencies installed successfully! Starting playlists export..."
python main.py

# Echo completion
Read-Host "The extraction is finished! All your playlists are in the current folder. You can close this window or press Enter..."
