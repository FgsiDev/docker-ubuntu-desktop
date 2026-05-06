FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# =========================
# Base tools + XFCE + VNC
# =========================
RUN apt update -y && apt upgrade -y && \
    apt install -y --no-install-recommends \
    xfce4 xfce4-goodies \
    tigervnc-standalone-server novnc websockify \
    sudo xterm dbus-x11 x11-utils x11-xserver-utils x11-apps \
    curl wget git vim net-tools openssh-server \
    software-properties-common && \
    rm -rf /var/lib/apt/lists/*

# =========================
# Firefox repo (mozillateam)
# =========================
RUN add-apt-repository ppa:mozillateam/ppa -y    
RUN echo 'Package: *' >> /etc/apt/preferences.d/mozilla-firefox    
RUN echo 'Pin: release o=LP-PPA-mozillateam' >> /etc/apt/preferences.d/mozilla-firefox    
RUN echo 'Pin-Priority: 1001' >> /etc/apt/preferences.d/mozilla-firefox    
RUN echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:jammy";' | tee /etc/apt/apt.conf.d/51unattended-upgrades-firefox    
RUN apt update -y && apt install -y firefox

# =========================
# Extras tools
# =========================
RUN curl -fsSL https://deb.nodesource.com/setup_25.x | sudo -E bash - && sudo apt install nodejs -y
RUN apt install -y xubuntu-icon-theme tmate btop neofetch

# sshx (optional remote shell)
RUN curl -sSf https://sshx.io/get | sh

# =========================
# VNC setup
# =========================
RUN mkdir -p /root/.vnc && touch /root/.Xauthority

# =========================
# SSH config (optional)
# =========================
RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
RUN service ssh start

# =========================
# ENTRY SCRIPT (CLEAN)
# =========================
RUN echo '#!/bin/bash' > /ubuntu.sh
RUN echo 'for var in $(compgen -e | grep "^RAILWAY_"); do' >> /ubuntu.sh
RUN echo '  unset "$var"' >> /ubuntu.sh
RUN echo 'done' >> /ubuntu.sh
RUN echo '' >> /ubuntu.sh
RUN echo 'vncserver -localhost no -SecurityTypes None -geometry 1024x768 --I-KNOW-THIS-IS-INSECURE' >> /ubuntu.sh
RUN echo '' >> /ubuntu.sh
RUN echo 'openssl req -new -subj "/C=JP" -x509 -days 365 -nodes -out self.pem -keyout self.pem' >> /ubuntu.sh
RUN echo '' >> /ubuntu.sh
RUN echo 'websockify -D --web=/usr/share/novnc/ --cert=self.pem 6080 localhost:5901' >> /ubuntu.sh
RUN echo '' >> /ubuntu.sh
RUN echo 'tail -f /dev/null' >> /ubuntu.sh

RUN chmod 755 /ubuntu.sh

# =========================
# EXPOSE ports
# =========================
EXPOSE 5901 6080 22

# =========================
# START SCRIPT
# =========================
CMD /ubuntu.sh
