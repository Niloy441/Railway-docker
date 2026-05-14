FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive 
    USER=admin 
    PASS=Admin@1234 
    PORT=8080

RUN apt-get update && 
    apt-get install -y --no-install-recommends 
        ca-certificates 
        curl 
        wget 
        git 
        sudo 
        xfce4 
        xfce4-goodies 
        xfce4-terminal 
        firefox 
        tigervnc-standalone-server 
        tigervnc-common 
        novnc 
        websockify 
        fonts-noto 
        fonts-noto-color-emoji 
        dbus-x11 
        x11vnc 
        net-tools 
        unzip 
        gnome-themes-extra 
        gtk2-engines-murrine 
        gtk2-engines-pixbuf 
        sassc 
        libglib2.0-dev-bin 
        apt-transport-https 
    && update-ca-certificates 
    && apt-get clean 
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash ${USER} && 
    echo "${USER}:${PASS}" | chpasswd && 
    adduser ${USER} sudo && 
    echo "${USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && 
    mkdir -p /home/${USER}/.vnc && 
    echo "${PASS}" | vncpasswd -f > /home/${USER}/.vnc/passwd && 
    chmod 600 /home/${USER}/.vnc/passwd && 
    chown -R ${USER}:${USER} /home/${USER}

RUN mkdir -p /usr/share/themes /usr/share/icons
RUN (export GIT_TERMINAL_PROMPT=0; git clone --depth=1 https://github.com/vinceliuice/Fluent-gtk-theme.git /tmp/fluent && cd /tmp/fluent && bash install.sh --tweaks round solid) || true
RUN (export GIT_TERMINAL_PROMPT=0; git clone --depth=1 https://github.com/vinceliuice/Fluent-icon-theme.git /tmp/fluent-icons && cd /tmp/fluent-icons && bash install.sh) || true
RUN (export GIT_TERMINAL_PROMPT=0; git clone --depth=1 https://github.com/vinceliuice/Fluent-cursors.git /tmp/fluent-cursor && cp -r /tmp/fluent-cursor/dist/* /usr/share/icons/ && rm -rf /tmp/fluent-cursor) || true
RUN rm -rf /tmp/fluent /tmp/fluent-icons /tmp/fluent-cursor || true

RUN mkdir -p /home/${USER}/.config/xfce4/xfconf/xfce-perchannel-xml 
             /home/${USER}/.config/xfce4/terminal && 
    cat > /home/${USER}/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml << 'EOF' && \

<?xml version="1.0" encoding="UTF-8"?>

<channel name="xsettings" version="1.0">
  <property name="Net" type="empty">
    <property name="ThemeName" type="string" value="Fluent-round"/>
    <property name="IconThemeName" type="string" value="Fluent"/>
  </property>
</channel>
EOF
    cat > /home/${USER}/.config/xfce4/terminal/terminalrc << 'EOF' && \
[Configuration]
FontName=Consolas 11
MiscDefaultGeometry=120x30
ColorForeground=#f8f8f2
ColorBackground=#0c0c0c
ColorCursor=#ffffff
ColorPalette=#0c0c0c;#c50f1f;#13a10e;#c19c00;#0037da;#881798;#3a96dd;#cccccc;#767676;#e74856;#16c60c;#f9f1a5;#3b78ff;#b4009e;#61d6d6;#f2f2f2
TabActivityColor=#e74856
MiscHighlightUrls=TRUE
ScrollingUnlimited=TRUE
EOF
    chown -R ${USER}:${USER} /home/${USER}

RUN cat > /home/${USER}/.vnc/xstartup << 'EOF' && 
#!/bin/bash
export XKL_XMODMAP_DISABLE=1
unset DBUS_SESSION_BUS_ADDRESS
startxfce4
EOF
chmod +x /home/${USER}/.vnc/xstartup && 
    chown ${USER}:${USER} /home/${USER}/.vnc/xstartup

RUN cat > /start.sh << 'EOF' && 
#!/bin/bash
set -e
rm -f /tmp/.X1-lock /tmp/.X11-unix/X1 /home/admin/.vnc/*.pid
vncserver -kill :1 2>/dev/null || true
vncserver :1 -geometry 1280x720 -depth 24 -localhost no
websockify --web=/usr/share/novnc/ 0.0.0.0:${PORT:-8080} localhost:5901
EOF
chmod +x /start.sh

EXPOSE 8080

CMD ["/start.sh"]
