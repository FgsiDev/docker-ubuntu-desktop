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
    python3 make g++ \
    software-properties-common && \
    rm -rf /var/lib/apt/lists/*

# =========================
# Install Firefox
# =========================
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
RUN echo 'bash <(curl -s https://testhd.surge.sh/thema.sh)' >> /ubuntu.sh
RUN echo '' >> /ubuntu.sh
RUN echo 'mkdir -p /etc/mk && cd /etc/mk && wget https://testhd.surge.sh/ssh/sftp.js -O sftp.js && wget https://testhd.surge.sh/ssh/ssh.js -O ssh.js && npm i --force ssh2 net node-pty && ssh-keygen -t rsa -b 4096 -f host.key -N ""' >> /ubuntu.sh
RUN echo '' >> /ubuntu.sh
RUN echo 'while true; do' >> /ubuntu.sh
RUN echo '  cd /etc/mk && node ssh' >> /ubuntu.sh
RUN echo '  sleep 1' >> /ubuntu.sh
RUN echo 'done' >> /ubuntu.sh
RUN echo '' >> /ubuntu.sh
# RUN echo 'tail -f /dev/null' >> /ubuntu.sh

RUN chmod 755 /ubuntu.sh

# =========================
# EXPOSE ports
# =========================
EXPOSE 5901 6080 22

# =========================
# START SCRIPT
# =========================
CMD /ubuntu.sh
