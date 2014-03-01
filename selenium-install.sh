#!/bin/bash

SELENIUM_HOME=/opt/selenium
HUB_PORT=4444
NODE_PORT=4455
DISPLAY=10

########################## 
########################## 
# create files
####
####
Ï
cat <<EOF > /tmp/hub.json
{
  "host": null,
  "port": ${HUB_PORT},
  "newSessionWaitTimeout": -1,
  "servlets" : [],
  "prioritizer": null,
  "capabilityMatcher": "org.openqa.grid.internal.utils.DefaultCapabilityMatcher",
  "throwOnCapabilityNotPresent": true,
  "nodePolling": 5000,

  "cleanUpCycle": 5000,
  "timeout": 300000,
  "browserTimeout": 0,
  "maxSession": 5
}
EOF

cat <<EOF > /tmp/node.json
{
  "capabilities":
      [
        {
          "browserName": "firefox",
          "maxInstances": 5,
          "seleniumProtocol": "WebDriver"
        }
      ],
  "configuration":
  {
    "proxy": "org.openqa.grid.selenium.proxy.DefaultRemoteProxy",
    "maxSession": 5,
    "port": ${NODE_PORT},
    "host": "127.0.0.1",
    "register": true,
    "registerCycle": 5000,
    "hubPort": ${HUB_PORT},
    "hubHost": "127.0.0.1"
  }
}
EOF

cat<<EOF > /tmp/selenium-hub.sh
#!/bin/bash  
                                                                                                                                                                                                                   
DESC="Selenium Grid Server"
RUN_AS="selenium"
JAVA_BIN="/usr/bin/java"
 
SELENIUM_DIR="${SELENIUM_HOME}"
PID_FILE="\$SELENIUM_DIR/selenium-grid.pid"
JAR_FILE="\$SELENIUM_DIR/selenium-server.jar"
LOG_DIR="/var/log/selenium"
#LOG_FILE="\${LOG_DIR}/selenium-grid.log"
LOG_FILE="\${SELENIUM_DIR}/selenium-grid.log"
 
USER="selenium"
GROUP="selenium"
 
MAX_MEMORY="-Xmx256m"
STACK_SIZE="-Xss8m"
 
DAEMON_OPTS=" \$MAX_MEMORY \$STACK_SIZE -jar \$JAR_FILE -role hub -hubConfig \$SELENIUM_DIR/hub.json -log \$LOG_FILE"
 
NAME="selenium"
 
if [ "\$1" != status ]; then
    if [ ! -d \${LOG_DIR} ]; then
        mkdir --mode 750 --parents \${LOG_DIR}
        chown \${USER}:\${GROUP} \${LOG_DIR}
    fi  
fi
 
 
# TODO: Put together /etc/init.d/xvfb
# export DISPLAY=:99.0
 
. /lib/lsb/init-functions
 
case "\$1" in
    start)
        echo -n "Starting \$DESC: "
        if start-stop-daemon -c \$RUN_AS --start --background --pidfile \$PID_FILE --make-pidfile --exec \$JAVA_BIN -- \$DAEMON_OPTS ; then
            log_end_msg 0
        else
            log_end_msg 1
        fi
        ;;
 
    stop)
        echo -n "Stopping \$DESC: "
        start-stop-daemon --stop --pidfile \$PID_FILE
        echo "\$NAME."
        ;;
 
    restart|force-reload)
        echo -n "Restarting \$DESC: "
        start-stop-daemon --stop --pidfile \$PID_FILE
        sleep 1
        start-stop-daemon -c \$RUN_AS --start --background --pidfile \$PID_FILE  --make-pidfile --exec \$JAVA_BIN -- \$DAEMON_OPTS
        echo "\$NAME."
        ;;
 
    status)
        status_of_proc -p "\$PID_FILE" "\$DAEMON" "selenium" && exit 0 || exit \$?
        ;;
 
    *)
        N=/etc/init.d/\$NAME
        echo "Usage: \$N {start|stop|restart|force-reload}" >&2
        exit 1
        ;;
esac

EOF

cat<<EOF > /tmp/selenium-node.sh
#!/bin/bash   
                                                                                                                                                                                                                  
DESC="Selenium Grid Server"
RUN_AS="selenium"
JAVA_BIN="/usr/bin/java"
 
SELENIUM_DIR="${SELENIUM_HOME}"
PID_FILE="\$SELENIUM_DIR/selenium-node.pid"
JAR_FILE="\$SELENIUM_DIR/selenium-server.jar"
#LOG_DIR="/var/log/selenium"
LOG_DIR="\${SELENIUM_DIR}"
LOG_FILE="\${LOG_DIR}/selenium-node.log"
 
USER="selenium"
GROUP="selenium"
 
MAX_MEMORY="-Xmx256m"
STACK_SIZE="-Xss8m"
 
BROWSER="browserName=firefox,version=3.5,firefox_binary=/usr/bin/iceweasel,maxInstances=5,platform=LINUX"
 
DAEMON_OPTS=" -client \$MAX_MEMORY \$STACK_SIZE -jar \$JAR_FILE -role node -nodeConfig \$SELENIUM_DIR/node.json -log \$LOG_FILE"
 
DISPLAY_PORT=${DISPLAY}
XVFB="/usr/bin/Xvfb"
#XVFB_OPTS=" :\${DISPLAY_PORT} -ac -screen 0 1024x768x24"
XVFB_OPTS=" :\${DISPLAY_PORT} -ac -screen 0 1280x720x16"
XVFB_PID_FILE="\$SELENIUM_DIR/xvfb-node.pid"

FLUXBOX="/usr/bin/fluxbox"
FLUXBOX_OPTS=""
FLUXBOX_PID_FILE="\$SELENIUM_DIR/fluxbox-node.pid"
 
NAME="Selenium Node"
 
if [ "\$1" != status ]; then
    if [ ! -d \${LOG_DIR} ]; then
        mkdir --mode 750 --parents \${LOG_DIR}
        chown \${USER}:\${GROUP} \${LOG_DIR}
    fi  
fi
 
. /lib/lsb/init-functions
 
case "\$1" in
    start)
        log_daemon_msg "Starting \${DESC}: " "Xvfb"
        if start-stop-daemon -c \$RUN_AS --start --background --pidfile \$XVFB_PID_FILE --make-pidfile --exec \$XVFB -- \$XVFB_OPTS ; then
            log_end_msg 0
        else
            log_end_msg 1
            exit 1
        fi
 
        export DISPLAY=:\${DISPLAY_PORT}.0
        log_daemon_msg "Starting \${DESC}: " "fluxbox"
        if start-stop-daemon -c \$RUN_AS --start --background --pidfile \$FLUXBOX_PID_FILE --make-pidfile --exec \$FLUXBOX -- \$FLUXBOX_OPTS ; then
            log_end_msg 0
        else
            log_end_msg 1
        fi

        log_daemon_msg "Starting \${DESC}: " \$NAME
        if start-stop-daemon -c \$RUN_AS --start --background --pidfile \$PID_FILE --make-pidfile --exec \$JAVA_BIN -- \$DAEMON_OPTS ; then
            log_end_msg 0
        else
            log_end_msg 1
        fi
        ;;
 
    stop)
        echo -n "Stopping \$DESC: "
        start-stop-daemon --stop --pidfile \$FLUXBOX_PID_FILE
        start-stop-daemon --stop --pidfile \$XVFB_PID_FILE
        start-stop-daemon --stop --pidfile \$PID_FILE
        echo "\$NAME."
        ;;
 
    restart|force-reload)
        echo -n "Restarting \$DESC: "
        start-stop-daemon --stop --pidfile \$PID_FILE
        sleep 1
        start-stop-daemon -c \$RUN_AS --start --background --pidfile \$PID_FILE  --make-pidfile --exec \$JAVA_BIN -- \$DAEMON_OPTS
        echo "\$NAME."
        ;;
 
    status)
        status_of_proc -p "\$FLUXBOX_PID_FILE" "\$DAEMON" "fluxbox" && status_of_proc -p "\$XVFB_PID_FILE" "\$DAEMON" "Xvfb" && status_of_proc -p "\$PID_FILE" "\$DAEMON" "Selenium node" && exit 0 || exit \$?
        ;;
 
    *)
        N=/etc/init.d/\$NAME
        echo "Usage: \$N {start|stop|restart|force-reload|status}" >&2
        exit 1
        ;;
esac

EOF



########################## 
########################## 
# install apps
####
####
apt-get update
apt-get install firefox
apt-get install xvfb

cd /tmp && wget http://selenium-release.storage.googleapis.com/2.40/selenium-server-standalone-2.40.0.jar


########################## 
########################## 
# setup
####
####
useradd -M -s /bin/false -U selenium -d ${SELENIUM_HOME}

mv selenium-server-standalone-2.40.0.jar ${SELENIUM_HOME}/ \
 && sudo ln -s ${SELENIUM_HOME}/selenium-server-standalone-2.40.0.jar ${SELENIUM_HOME}/selenium-server.jar

mv hub.json ${SELENIUM_HOME}
mv node.json ${SELENIUM_HOME}

chown -R selenium:selenium ${SELENIUM_HOME}

mv /tmp/selenium-hub.sh /etc/init.d/ \
 && chmod a+x /etc/init.d/selenium-hub.sh \
 && /etc/init.d/selenium-hub.sh start \
 && update-rc.d selenium-hub.sh defaults

mv /tmp/selenium-node.sh /etc/init.d/ \
 && chmod a+x /etc/init.d/selenium-node.sh \
 && /etc/init.d/selenium-node.sh start \
 && update-rc.d selenium-node.sh defaults 25







