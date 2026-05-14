FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV USER=admin
ENV PASS=Admin@1234

# Base packages
RUN apt-get update && apt-get install -y \
    xrdp xfce4 xfce4-goodies \
    xorgxrdp firefox sudo \
    dbus-x11 x11vnc net-tools \
    git wget curl unzip \
    xfce4-terminal \
    fonts-noto fonts-noto-color-emoji \
    gnome-themes-extra \
    gtk2-engines-murrine \
    gtk2-engines-pixbuf \
    sassc libglib2.0-dev-bin \
    apt-transport-https && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# User বানাও
RUN useradd -m -s /bin/bash ${USER} && \
    echo "${USER}:${PASS}" | chpasswd && \
    adduser ${USER} sudo && \
    echo "${USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Windows 11 Theme ইন্সটল
RUN mkdir -p /usr/share/themes && \
    git clone --depth=1 https://github.com/vinceliuice/Fluent-gtk-theme.git /tmp/fluent && \
    cd /tmp/fluent && \
    ./install.sh --tweaks round solid && \
    rm -rf /tmp/fluent

# Windows 11 Icons
RUN mkdir -p /usr/share/icons && \
    git clone --depth=1 https://github.com/vinceliuice/Fluent-icon-theme.git /tmp/fluent-icons && \
    cd /tmp/fluent-icons && \
    ./install.sh && \
    rm -rf /tmp/fluent-icons

# Windows 11 Cursor
RUN git clone --depth=1 https://github.com/vinceliuice/Fluent-cursors.git /tmp/fluent-cursor && \
    cp -r /tmp/fluent-cursor/dist/* /usr/share/icons/ && \
    rm -rf /tmp/fluent-cursor

# XFCE Windows 11 কনফিগ
RUN mkdir -p /home/${USER}/.config/xfce4/xfconf/xfce-perchannel-xml

# Theme সেটিং
RUN cat > /home/${USER}/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xsettings" version="1.0">
  <property name="Net" type="empty">
    <property name="ThemeName" type="string" value="Fluent-round-Light"/>
    <property name="IconThemeName" type="string" value="Fluent"/>
    <property name="CursorThemeName" type="string" value="Fluent-cursors"/>
  </property>
  <property name="Gtk" type="empty">
    <property name="FontName" type="string" value="Segoe UI 10"/>
    <property name="MonospaceFontName" type="string" value="Consolas 11"/>
  </property>
</channel>
EOF

# Taskbar Windows 11 স্টাইল
RUN cat > /home/${USER}/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-panel" version="1.0">
  <property name="panels" type="array">
    <value type="int" value="1"/>
    <property name="panel-1" type="empty">
      <property name="position" type="string" value="p=8;x=960;y=1060"/>
      <property name="length" type="uint" value="100"/>
      <property name="position-locked" type="bool" value="true"/>
      <property name="size" type="uint" value="48"/>
      <property name="plugin-ids" type="array">
        <value type="int" value="1"/>
        <value type="int" value="2"/>
        <value type="int" value="3"/>
        <value type="int" value="4"/>
        <value type="int" value="5"/>
      </property>
    </property>
  </property>
  <property name="plugins" type="empty">
    <property name="plugin-1" type="string" value="applicationsmenu"/>
    <property name="plugin-2" type="string" value="tasklist"/>
    <property name="plugin-3" type="string" value="separator">
      <property name="expand" type="bool" value="true"/>
    </property>
    <property name="plugin-4" type="string" value="systray"/>
    <property name="plugin-5" type="string" value="clock"/>
  </property>
</channel>
EOF

# Windows Terminal স্টাইল — xfce4-terminal
RUN mkdir -p /home/${USER}/.config/xfce4/terminal && \
    cat > /home/${USER}/.config/xfce4/terminal/terminalrc << 'EOF'
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

# Wallpaper Windows 11 style
RUN mkdir -p /home/${USER}/Pictures && \
    wget -q "https://raw.githubusercontent.com/nicehash/NiceHashQuickMiner/master/icons/NiceHashQuickMiner_256.png" \
    -O /home/${USER}/Pictures/wallpaper.png || true

# Desktop কনফিগ
RUN cat > /home/${USER}/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-desktop" version="1.0">
  <property name="backdrop" type="empty">
    <property name="screen0" type="empty">
      <property name="monitorVNC-0" type="empty">
        <property name="workspace0" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="rgba1" type="array">
            <value type="double" value="0.0"/>
            <value type="double" value="0.47"/>
            <value type="double" value="0.84"/>
            <value type="double" value="1.0"/>
          </property>
        </property>
      </property>
    </property>
  </property>
</channel>
EOF

# xsession
RUN echo "startxfce4" > /home/${USER}/.xsession && \
    chown -R ${USER}:${USER} /home/${USER}

RUN mkdir -p /var/run/dbus && \
    chmod 755 /var/run/dbus

EXPOSE 3389

CMD dbus-daemon --system --fork && \
    /usr/sbin/xrdp-sesman && \
    /usr/sbin/xrdp -nodaemon
