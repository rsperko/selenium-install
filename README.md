selenium-install
================

This script performs the following

* Required
  * java
  * firefox - could install chrome too. Need to configure the node.json to handle that
  * xvfb - frame buffer X server for running headless
  * fluxbox simple window manager, without this we cannot maximize the browser window meaning that we may not get the browser big enough to move out of "mobile" view
  * selenium server jar
  * user to run as, these files expect selenium with a group of selenium
* Install apps
  * sudo apt-get install firefox
  * sudo apt-get install xvfb
  * sudo apt-get install fluxbox
* Install Selenium Server
  * add user
    * sudo useradd -M -s /bin/false -U selenium -d /opt/selenium
  * wget http://selenium-release.storage.googleapis.com/2.40/selenium-server-standalone-2.40.0.jar
  * sudo mv selenium-server-standalone-2.40.0.jar /opt/selenium/ && sudo ln -s /opt/selenium/selenium-server-standalone-2.40.0.jar /opt/selenium/selenium-server.jar
  * upload hub.json and node.json to /opt/selenium
  * upload selenium-node.sh and selenium-hub.sh to /etc/init.d
  * sudo chmod a+x /etc/init.d/selenium-hub.sh && sudo chmod a+x /etc/init.d/selenium-node.sh
  * sudo /etc/init.d/selenium-hub.sh start
  * sudo /etc/init.d/selenium-node.sh start
  * sudo update-rc.d selenium-hub.sh defaults
  * sudo update-rc.d selenium-node.sh defaults 25

### Troubleshooting
The above will run the node on display :10, you can capture a screenshot (after installing imagemagick) with:
$ import -display :10 -window root ~/image.png

You can also have your PageObject take a screenshot, but it will only be the browser. I found the browser was too small to render desktop mode for OE, that is why I needed the above.
