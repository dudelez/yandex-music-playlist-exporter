import os
import sys
import time
import re
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from bs4 import BeautifulSoup
from selenium.webdriver.firefox.firefox_profile import FirefoxProfile

# Default file name
file_name = "playlists.txt"

# Check if an argument was passed
if len(sys.argv) > 1:
    file_name = sys.argv[1]

# Check for file existence
if not os.path.exists(file_name):
    print(f"Error: File '{file_name}' not found.")
    exit(1)

# Read URLs from the file
with open(file_name, "r") as f:
    urls = f.readlines()

# Validate URLs
url_pattern = re.compile(r"https?://[^\s]+")
if not all(url_pattern.match(url) for url in urls):
    print("Error: Invalid content in the file. Ensure the file contains only URLs.")
    exit(1)

profile = FirefoxProfile()
driver = webdriver.Firefox(executable_path="C:\\WebDriver\\bin\\geckodriver.exe", firefox_profile=profile)

for idx, url in enumerate(urls, start=1):
    url = url.strip()
    driver.get(url)
    time.sleep(10)

    songs_artists_set = set()
    new_songs_artists_set = set()

    # Continue looping until no new songs are found for 3 consecutive iterations
    new_songs = True
    while new_songs:
        # Switch to the iframe containing the songs
        iframe = driver.find_element_by_tag_name('iframe')
        driver.switch_to.frame(iframe)
        driver.find_element_by_tag_name('body').send_keys(Keys.END)
        time.sleep(3)

        # Switch back to the main content
        driver.switch_to.default_content()

        # Parse the page content
        soup = BeautifulSoup(driver.page_source, 'html.parser')

        # Fetch current songs
        songs = soup.find_all("div", class_="d-track__name")
        all_anchors = soup.find_all("a")
        artist_anchors = [a for a in all_anchors if "artist" in a.get('href', '').lower()]

        for song, artist in zip(songs, artist_anchors):
            song_name = song.text.strip()
            artist_name = artist.text.strip()
            new_songs_artists_set.add((song_name, artist_name))

        if new_songs_artists_set.issubset(songs_artists_set):
            new_songs = False

        songs_artists_set.update(new_songs_artists_set)
        new_songs_artists_set.clear()

    # Get the username and playlist number
    match = re.search(r"/users/([^/]+)/playlists/(\d+)", url)
    if match:
        user_name, playlist_id = match.groups()
    else:
        user_name = "unknown_user"
        playlist_id = str(idx)

    # Create directory for the user if it doesn't exist
    user_dir = os.path.join("my_playlists", user_name)
    if not os.path.exists(user_dir):
        os.makedirs(user_dir)

    # Set the file path
    playlist_file_name = os.path.join(user_dir, f"{playlist_id}.txt")

    # Only save the playlist if songs were found
    if songs_artists_set:
        with open(playlist_file_name, "w", encoding="utf-8") as f:
            for song, artist in songs_artists_set:
                f.write(f"{song} - {artist}\n")

        print(f"{len(songs_artists_set)} songs from {url} have been exported to {playlist_file_name}.")
    else:
        print(f"Error: No songs found in playlist {url}. Continuing to next URL.")

driver.quit()
