# Raspberry Pi
### Installation Steps

Although I used to love using Arch Linux on my Pi's, I've recently decided to take a more hands off approach as they have become servers rather than playgrounds. My requirements are as follows:
- Stable releases, with minimal intervention needed
- Automatic configuration (networking, hostname, package installation)
- Simple method of securing the OS for the purposes of the Pi (hardening of SSH, removal of any unneeded packages)

With all this in mind, I have decided to use [Hypriot](https://blog.hypriot.com) as my OS. With proper docker optimizations and cloud-init inherent, its a no-brainer. Let's step through how we'll set this up..

First, we'll grab their [flash tool](https://github.com/hypriot/flash) which simplifies this whole process even more:
```
# Check github for latest version and adjust as needed
curl -LO https://github.com/hypriot/flash/releases/download/2.7.1/flash
chmod +x flash
sudo mv flash /usr/local/bin/flash
```

This tool does have some dependencies, so be sure to install the below list of packages:
- `curl` - allows flashing directly from URL
- `awscli` - allows flashing directly from S3 bucket
- `pv` - progress bar during flash process
- `unzip` - extract zip files
- `hdparm` - required to run the program

#### Cloud-Init
TO-DO --- add user-data and metadata yaml files to repo, explain snippets within this document 


#### OS Setup (if using as desktop, typically I use as headless)
I'm an i3 fanboy, I despise using a mouse for w/e reason.. Below are the steps I've used to get i3 up and running on my Pi's

Install i3-wm (if you want up to date, build from source)
```
sudo apt install i3-wm
```
Edit the desktop config file located at `~/.config/lxsession/LXDE-pi/desktop.conf` and edit the window manager to match below:
```
[Session]
window_manager=i3wm-pi
```
Create new file and make it executable at `/usr/bin/i3wm-pi` with following contents:
```
#!/bin/bash
exec i3
```
Finally, edit `~/.config/lxsession/LXDE-pi/autostart` by commenting out the following lines:
```
# @lxpanel --profile LXDE-pi
# @pcmanfm --desktop --profile LXDE-pi
```
Now just edit i3 config to your liking
