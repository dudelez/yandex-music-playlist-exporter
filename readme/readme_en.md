# Yandex Music Playlist Exporter
This script allows users to export their Yandex Music playlists to a simple text format. This can be useful for creating backups or for transferring playlists to other platforms.

## Prerequisites
- Windows Operating System (as the setup script is written for Windows only for now).
- You must be located in Russia or other country, which Yandex Music supports, or you must have a paid Yandex Plus subscription.

## Setup
### 1. Download the Repository
You can either clone the repo, or download it from Github as zip.
#### Clone
```bash
git clone https://gitlab.puzl.ee/yandex-music-playlist-exporter.git
cd yandex-music-playlist-exporter
```

#### Download
Download as zip archive and extract it.

### 2. Run the Script

#### Provide playlists
There is a file named `playlists.txt` inside the `yandex-music-playlist-exporter` folder. Add the list of URLs of your Yandex Music playlists to this file.

> ##### IMPORTANT 
> 
> First, ensure your playlists are public. Visit the settings of your Yandex Music account and make sure this option is enabled.

#### Run
Right-click on the `export.ps1` file and select "Run with PowerShell". This script will automatically:

- Create a directory for WebDriver binaries.
- Download the necessary geckodriver for Firefox.
- Check for Firefox and Python 3.10+ installations and guide you through the setup if they're not found.
- Extract all the provided playlists into `my_playlists` folder.

> ##### IMPORTANT 
> 
> You will see Firefox browser window opened by the script. Do not close or hide this window! Otherwise, the exporter may miss some songs.
