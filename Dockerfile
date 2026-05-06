FROM kalilinux/kali-rolling

ENV DEBIAN_FRONTEND=noninteractive

# =========================
# Base tools + XFCE + VNC
# =========================
RUN apt update && apt upgrade -y && \
    apt install -y --no-install-recommends \
    xfce4 xfce4-goodies \
    tigervnc-standalone-server novnc websockify \
    sudo xterm dbus-x11 x11-utils x11-xserver-utils x11-apps \
    curl wget git vim net-tools tzdata locales openssh-server \
    software-properties-common && \
    rm -rf /var/lib/apt/lists/*

# =========================
# Firefox repo (mozillateam)
# =========================
RUN add-apt-repository ppa:mozillateam/ppa -y && \
    echo 'Package: *' > /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin: release o=LP-PPA-mozillateam' >> /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin-Priority: 1001' >> /etc/apt/preferences.d/mozilla-firefox && \
    apt update && apt install -y firefox

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
RUN echo '#!/bin/bash' > /kali.sh
RUN echo 'for var in $(compgen -e | grep "^RAILWAY_"); do' >> /kali.sh
RUN echo '  unset "$var"' >> /kali.sh
RUN echo 'done' >> /kali.sh
RUN echo '' >> /kali.sh
RUN echo 'vncserver -localhost no -SecurityTypes None -geometry 1024x768 --I-KNOW-THIS-IS-INSECURE' >> /kali.sh
RUN echo '' >> /kali.sh
RUN echo 'openssl req -new -subj "/C=JP" -x509 -days 365 -nodes -out self.pem -keyout self.pem' >> /kali.sh
RUN echo '' >> /kali.sh
RUN echo 'websockify -D --web=/usr/share/novnc/ --cert=self.pem 6080 localhost:5901' >> /kali.sh
RUN echo '' >> /kali.sh
RUN echo 'tail -f /dev/null' >> /kali.sh

RUN chmod 755 /kali.sh

# =========================
# EXPOSE ports
# =========================
EXPOSE 5901 6080 22

# =========================
# START SCRIPT
# =========================
CMD /kali.sh
