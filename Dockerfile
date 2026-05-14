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
bash install.sh --tweaks round solid && \
rm -rf /tmp/fluent

# Windows 11 Icons
RUN mkdir -p /usr/share/icons && \
git clone --depth=1 https://github.com/vinceliuice/Fluent-icon-theme.git /tmp/fluent-icons && \
cd /tmp/fluent-icons && \
bash install.sh && \
rm -rf /tmp/fluent-icons

# Windows 11 Cursor
RUN git clone --depth=1 https://github.com/vinceliuice/Fluent-cursors.git /tmp/fluent-cursor && \
cp -r /tmp/fluent-cursor/dist/* /usr/share/icons/ && \
rm -rf /tmp/fluent-cursor

# XFCE Windows 11 কনফিগ
RUN mkdir -p /home/${USER}/.config/xfce4/xfconf/xfce-perchannel-xml

# Theme সেটিং
RUN cat > /home/${USER}/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml << 'EOF'
EOF

# Taskbar Windows 11 স্টাইল
RUN cat > /home/${USER}/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml << 'EOF'
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
