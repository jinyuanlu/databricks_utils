#!/bin/bash

# Install necessary packages
apt-get update
apt-get install -y chromium-browser wget unzip

# Install Python packages
pip install selenium
pip install --upgrade typing_extensions

# Get the installed Chromium version
CHROME_VERSION=$(chromium-browser --version | grep -oP 'Chromium \K[\d.]+')
echo "Detected Chrome version: $CHROME_VERSION"

# Parse out the major version of Chromium for downloading the matching Chromedriver
CHROME_MAJOR_VERSION=$(echo $CHROME_VERSION | cut -d'.' -f1)
echo "Detected Chrome major version: $CHROME_MAJOR_VERSION"

# Define the Chromedriver version to download
CHROMEDRIVER_VERSION="111.0.5563.64"  # Update this based on the compatible version for your Chrome
echo "Using Chromedriver version: $CHROMEDRIVER_VERSION"

# Create a temporary directory for downloading Chromedriver
mkdir temp
cd temp

# Download Chromedriver compatible with the installed Chromium version
wget "https://chromedriver.storage.googleapis.com/$CHROMEDRIVER_VERSION/chromedriver_linux64.zip"

# Unzip and set permissions for Chromedriver
unzip chromedriver_linux64.zip
chmod +x chromedriver

# Move Chromedriver to a system location
mv chromedriver /usr/local/bin/
chown root:root /usr/local/bin/chromedriver
chmod 0755 /usr/local/bin/chromedriver

# Clean up temporary directory
cd ..
rm -rf temp

# Python script as a heredoc
cat << EOF > init_selenium.py
from selenium import webdriver

def init_chrome_browser(chrome_driver_path):
   chrome_options = webdriver.ChromeOptions()
   chrome_options.add_argument("--headless")  # Ensure GUI is off
   chrome_options.add_argument("--no-sandbox")
   chrome_options.add_argument("--disable-dev-shm-usage")

   browser = webdriver.Chrome(executable_path=chrome_driver_path, options=chrome_options)
   return browser

browser = init_chrome_browser("/usr/local/bin/chromedriver")
browser.get('http://google.com')
print(browser.title)
browser.quit()
EOF

# Run the Python script
python init_selenium.py
