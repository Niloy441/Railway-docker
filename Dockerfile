FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV USER=admin
ENV PASS=Admin@1234
ENV HOME=/home/admin
ENV DISPLAY=:1

EXPOSE 8080

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        wget \
        git \
        sudo \
        dbus-x11 \
        xauth \
        x11-xserver-utils \
        xfce4 \
        xfce4-goodies \
        xfce4-terminal \
        tigervnc-standalone-server \
        tigervnc-common \
        novnc \
        websockify \
        fonts-noto \
        fonts-noto-core \
        fonts-noto-extra \
        fonts-noto-cjk \
        fonts-noto-color-emoji \
        gtk2-engines-murrine \
        gtk2-engines-pixbuf \
        gnome-themes-extra \
        hicolor-icon-theme \
        adwaita-icon-theme \
        libgtk-3-0 \
        libdbus-glib-1-2 \
        libasound2 \
        libx11-xcb1 \
        libxt6 \
        libxrender1 \
        libxcomposite1 \
        libxdamage1 \
        libxfixes3 \
        libxrandr2 \
        libxext6 \
        libxss1 \
        libnss3 \
        libatk-bridge2.0-0 \
        libatk1.0-0 \
        libcups2 \
        libdrm2 \
        libgbm1 \
        libxkbcommon0 && \
    update-ca-certificates && \
    mkdir -p /opt && \
    wget -qO /tmp/firefox.tar.xz "https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64&lang=en-US" && \
    tar -xJf /tmp/firefox.tar.xz -C /opt && \
    ln -sf /opt/firefox/firefox /usr/local/bin/firefox && \
    rm -f /tmp/firefox.tar.xz && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN useradd -m -s /bin/bash ${USER} && \
    echo "${USER}:${PASS}" | chpasswd && \
    usermod -aG sudo ${USER} && \
    echo "${USER} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USER} && \
    chmod 0440 /etc/sudoers.d/${USER}

RUN mkdir -p /tmp/fluent-build /usr/share/themes /usr/share/icons && \
    cd /tmp/fluent-build && \
    (GIT_TERMINAL_PROMPT=0 git clone --depth=1 https://github.com/vinceliuice/Fluent-gtk-theme.git Fluent-gtk-theme && \
    cd Fluent-gtk-theme && \
    (bash install.sh --dest /usr/share/themes --tweaks round solid || bash install.sh --dest /usr/share/themes || true)) || true && \
    cd /tmp/fluent-build && \
    (GIT_TERMINAL_PROMPT=0 git clone --depth=1 https://github.com/vinceliuice/Fluent-icon-theme.git Fluent-icon-theme && \
    cd Fluent-icon-theme && \
    (bash install.sh --dest /usr/share/icons || bash install.sh || true)) || true && \
    cd /tmp/fluent-build && \
    (GIT_TERMINAL_PROMPT=0 git clone --depth=1 https://github.com/vinceliuice/Fluent-cursors.git Fluent-cursors && \
    cd Fluent-cursors && \
    (bash install.sh || cp -r dist/* /usr/share/icons/ || true)) || true && \
    rm -rf /tmp/fluent-build

RUN mkdir -p \
        /home/${USER}/.vnc \
        /home/${USER}/.config/xfce4/xfconf/xfce-perchannel-xml \
        /home/${USER}/.config/xfce4/terminal && \
    printf '%s\n' \
        '#!/bin/sh' \
        'unset SESSION_MANAGER' \
        'unset DBUS_SESSION_BUS_ADDRESS' \
        'export XDG_SESSION_TYPE=x11' \
        'export XDG_CURRENT_DESKTOP=XFCE' \
        'export DESKTOP_SESSION=xfce' \
        'exec startxfce4' \
        > /home/${USER}/.vnc/xstartup && \
    chmod +x /home/${USER}/.vnc/xstartup && \
    echo "${PASS}" | vncpasswd -f > /home/${USER}/.vnc/passwd && \
    chmod 600 /home/${USER}/.vnc/passwd && \
    printf '%s\n' \
        '<?xml version="1.0" encoding="UTF-8"?>' \
        '<channel name="xsettings" version="1.0">' \
        '  <property name="Net" type="empty">' \
        '    <property name="ThemeName" type="string" value="Fluent"/>' \
        '    <property name="IconThemeName" type="string" value="Fluent"/>' \
        '    <property name="CursorThemeName" type="string" value="Fluent-cursors"/>' \
        '  </property>' \
        '  <property name="Gtk" type="empty">' \
        '    <property name="CursorThemeName" type="string" value="Fluent-cursors"/>' \
        '  </property>' \
        '</channel>' \
        > /home/${USER}/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml && \
    printf '%s\n' \
        '[Configuration]' \
        'FontName=Noto Sans Mono 10' \
        'MiscDefaultGeometry=120x30' \
        'MiscToolbarDefault=FALSE' \
        'MiscMenubarDefault=TRUE' \
        'MiscHighlightUrls=TRUE' \
        'ScrollingUnlimited=TRUE' \
        'ColorForeground=#f8f8f2' \
        'ColorBackground=#0c0c0c' \
        'ColorCursor=#ffffff' \
        'ColorPalette=#0c0c0c;#c50f1f;#13a10e;#c19c00;#0037da;#881798;#3a96dd;#cccccc;#767676;#e74856;#16c60c;#f9f1a5;#3b78ff;#b4009e;#61d6d6;#f2f2f2' \
        > /home/${USER}/.config/xfce4/terminal/terminalrc && \
    chown -R ${USER}:${USER} /home/${USER}

RUN printf '%s\n' \
        '#!/bin/bash' \
        'set -e' \
        'export USER=admin' \
        'export HOME=/home/admin' \
        'export DISPLAY=:1' \
        'rm -f /home/admin/.vnc/*.pid /home/admin/.vnc/*.log /tmp/.X1-lock /tmp/.X11-unix/X1' \
        'mkdir -p /tmp/.X11-unix' \
        'chmod 1777 /tmp/.X11-unix' \
        'chown -R admin:admin /home/admin' \
        'su - admin -c "vncserver -kill :1 >/dev/null 2>&1 || true"' \
        'su - admin -c "vncserver :1 -geometry 1280x720 -depth 24 -localhost no"' \
        'exec websockify --web=/usr/share/novnc/ 0.0.0.0:${PORT:-8080} localhost:5901' \
        > /start.sh && \
    chmod +x /start.sh

CMD ["/start.sh"]
