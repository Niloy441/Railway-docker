FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive 
    LANG=en_US.UTF-8 
    LANGUAGE=en_US:en 
    LC_ALL=en_US.UTF-8

RUN apt-get update && 
    apt-get install -y --no-install-recommends 
        ca-certificates && 
    update-ca-certificates && 
    apt-get install -y --no-install-recommends 
        locales 
        sudo 
        xfce4 
        xfce4-terminal 
        firefox 
        tigervnc-standalone-server 
        tigervnc-common 
        novnc 
        fonts-noto 
        fonts-noto-cjk 
        fonts-noto-color-emoji 
        git 
        curl 
        gtk2-engines-murrine 
        gtk2-engines-pixbuf 
        gnome-themes-extra 
        sassc 
        optipng 
        xfconf 
        dbus-x11 
        x11-xserver-utils && 
    locale-gen en_US.UTF-8 && 
    update-locale LANG=en_US.UTF-8 && 
    apt-get clean && 
    rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash admin && 
    echo "admin:Admin@1234" | chpasswd && 
    usermod -aG sudo admin && 
    echo "admin ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/admin

RUN su - admin -c "mkdir -p ~/.vnc && printf '%s\n%s\nn\n' 'Admin@1234' 'Admin@1234' | vncpasswd"

RUN git clone --depth 1 https://github.com/vinceliuice/Fluent-gtk-theme.git /tmp/fluent-gtk && 
    cd /tmp/fluent-gtk && bash install.sh -t all || true && 
    rm -rf /tmp/fluent-gtk

RUN git clone --depth 1 https://github.com/vinceliuice/Fluent-icon-theme.git /tmp/fluent-icon && 
    cd /tmp/fluent-icon && bash install.sh -a || true && 
    rm -rf /tmp/fluent-icon

RUN git clone --depth 1 https://github.com/vinceliuice/Fluent-cursors.git /tmp/fluent-cursors && 
    cd /tmp/fluent-cursors && bash install.sh || true && 
    rm -rf /tmp/fluent-cursors

RUN mkdir -p /home/admin/.vnc && 
    echo '#!/bin/bash' > /home/admin/.vnc/xstartup && 
    echo 'xrdb $HOME/.Xresources' >> /home/admin/.vnc/xstartup && 
    echo 'startxfce4 &' >> /home/admin/.vnc/xstartup && 
    echo '' >> /home/admin/.vnc/xstartup && 
    echo '# Apply Fluent theme if present' >> /home/admin/.vnc/xstartup && 
    echo 'if [ -d /usr/share/themes/Fluent ]; then' >> /home/admin/.vnc/xstartup && 
    echo '  xfconf-query -c xsettings -p /Net/ThemeName -s "Fluent" 2>/dev/null || true' >> /home/admin/.vnc/xstartup && 
    echo 'fi' >> /home/admin/.vnc/xstartup && 
    echo 'if [ -d /usr/share/icons/Fluent ]; then' >> /home/admin/.vnc/xstartup && 
    echo '  xfconf-query -c xsettings -p /Net/IconThemeName -s "Fluent" 2>/dev/null || true' >> /home/admin/.vnc/xstartup && 
    echo 'fi' >> /home/admin/.vnc/xstartup && 
    echo 'if [ -d /usr/share/icons/Fluent-cursors ]; then' >> /home/admin/.vnc/xstartup && 
    echo '  xfconf-query -c xsettings -p /Gtk/CursorThemeName -s "Fluent-cursors" 2>/dev/null || true' >> /home/admin/.vnc/xstartup && 
    echo 'fi' >> /home/admin/.vnc/xstartup && 
    chmod +x /home/admin/.vnc/xstartup

RUN mkdir -p /home/admin/.config/xfce4/terminal && 
    echo '[Configuration]' > /home/admin/.config/xfce4/terminal/terminalrc && 
    echo 'ColorForeground=#FFFFFF' >> /home/admin/.config/xfce4/terminal/terminalrc && 
    echo 'ColorBackground=#000000' >> /home/admin/.config/xfce4/terminal/terminalrc && 
    echo 'ColorCursor=#FFFFFF' >> /home/admin/.config/xfce4/terminal/terminalrc && 
    echo 'ColorPalette=#000000;#AA0000;#00AA00;#AA5500;#0000AA;#AA00AA;#00AAAA;#AAAAAA;#555555;#FF5555;#55FF55;#FFFF55;#5555FF;#FF55FF;#55FFFF;#FFFFFF' >> /home/admin/.config/xfce4/terminal/terminalrc && 
    echo 'FontName=Monospace 10' >> /home/admin/.config/xfce4/terminal/terminalrc && 
    echo 'MiscSlimTabs=true' >> /home/admin/.config/xfce4/terminal/terminalrc && 
    echo 'MiscAlwaysShowTabs=false' >> /home/admin/.config/xfce4/terminal/terminalrc

RUN chown -R admin:admin /home/admin

RUN echo '#!/bin/bash' > /start.sh && 
    echo 'set -e' >> /start.sh && 
    echo '' >> /start.sh && 
    echo '# Clean up stale lock files' >> /start.sh && 
    echo 'rm -f /home/admin/.vnc/.pid /home/admin/.vnc/.log /tmp/.X1-lock /tmp/.X11-unix/X1 2>/dev/null || true' >> /start.sh && 
    echo '' >> /start.sh && 
    echo '# Start VNC server as admin' >> /start.sh && 
    echo 'su - admin -c "vncserver :1 -geometry 1280x720 -depth 24 -localhost no" &' >> /start.sh && 
    echo 'sleep 2' >> /start.sh && 
    echo '' >> /start.sh && 
    echo '# Start websockify' >> /start.sh && 
    echo 'exec websockify --web=/usr/share/novnc/ 0.0.0.0:${PORT:-8080} localhost:5901' >> /start.sh && 
    chmod +x /start.sh

EXPOSE 8080
CMD ["/start.sh"]
