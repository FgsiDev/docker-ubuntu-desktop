FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install minimal + SSH
RUN apt update && apt install -y \
    openssh-server sudo curl wget vim net-tools \
    xfce4 xfce4-goodies tigervnc-standalone-server novnc websockify \
    xterm dbus-x11 x11-utils x11-xserver-utils x11-apps \
    firefox xubuntu-icon-theme \
    tmate btop neofetch \
    && rm -rf /var/lib/apt/lists/*

# Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
    && apt install -y nodejs

# SSH setup
RUN mkdir -p /run/sshd

# Set root password
RUN echo "root:root" | chpasswd

# Fix SSH config (ANTI PAM ERROR)
RUN sed -i 's/#\?Port .*/Port 7850/' /etc/ssh/sshd_config && \
    sed -i 's/#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#\?UsePAM.*/UsePAM no/' /etc/ssh/sshd_config

# Hindari shell crash
RUN chsh -s /bin/sh root && \
    rm -f /root/.bashrc /root/.profile /root/.bash_logout

# VNC
RUN touch /root/.Xauthority

EXPOSE 5901
EXPOSE 6080
EXPOSE 7850

CMD bash -c "\
/usr/sbin/sshd && \
vncserver -localhost no -SecurityTypes None -geometry 1024x768 --I-KNOW-THIS-IS-INSECURE && \
openssl req -new -subj '/C=JP' -x509 -days 365 -nodes -out self.pem -keyout self.pem && \
websockify -D --web=/usr/share/novnc/ --cert=self.pem 6080 localhost:5901 && \
tail -f /dev/null"
