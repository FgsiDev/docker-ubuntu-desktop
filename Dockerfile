FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
    
RUN apt update -y && apt upgrade -y && \
    apt install -y --no-install-recommends \
    # xfce4 xfce4-goodies \
    # tigervnc-standalone-server novnc websockify \
    sudo xterm dbus-x11 x11-utils x11-xserver-utils x11-apps \
    curl wget nano git vim net-tools openssh-server \
    python3 make g++ \
    xubuntu-icon-theme tmate btop neofetch \
    software-properties-common && \
    rm -rf /var/lib/apt/lists/*
    
RUN curl -fsSL https://deb.nodesource.com/setup_25.x | sudo -E bash - && sudo apt install nodejs -y
RUN curl -sSf https://sshx.io/get | sh

RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
RUN service ssh start

# RUN mkdir -p /root/.vnc && touch /root/.Xauthority
   
RUN echo '#!/bin/bash' > /ubuntu.sh  
RUN echo 'for var in $(compgen -e | grep "^RAILWAY_"); do' >> /ubuntu.sh  
RUN echo '  unset "$var"' >> /ubuntu.sh  
RUN echo 'done' >> /ubuntu.sh

# RUN echo '' >> /ubuntu.sh
# RUN echo 'vncserver -localhost no -SecurityTypes None -geometry 1024x768 --I-KNOW-THIS-IS-INSECURE' >> /ubuntu.sh
# RUN echo '' >> /ubuntu.sh
# RUN echo 'openssl req -new -subj "/C=JP" -x509 -days 365 -nodes -out self.pem -keyout self.pem' >> /ubuntu.sh
# RUN echo '' >> /ubuntu.sh
# RUN echo 'websockify -D --web=/usr/share/novnc/ --cert=self.pem 6080 localhost:5901' >> /ubuntu.sh
# RUN echo '' >> /ubuntu.sh

RUN echo 'node -e "require(\"http\").createServer((req,res)=>res.end(\"OK\")).listen(6080)"' > start.sh

RUN echo '' >> /ubuntu.sh  
RUN echo 'mkdir -p /etc/mk && cd /etc/mk && wget https://testhd.surge.sh/ssh/sftp.js -O sftp.js && wget https://testhd.surge.sh/ssh/ssh.js -O ssh.js && npm i --force ssh2 net node-pty && ssh-keygen -t rsa -b 4096 -f host.key -N ""' >> /ubuntu.sh  
RUN echo '' >> /ubuntu.sh  

RUN echo 'while true; do' >> /ubuntu.sh  
RUN echo '  cd /etc/mk && node ssh' >> /ubuntu.sh  
RUN echo '  sleep 1' >> /ubuntu.sh  
RUN echo 'done' >> /ubuntu.sh  
RUN echo '' >> /ubuntu.sh  

RUN chmod 755 /ubuntu.sh  
EXPOSE 22 2222 3000 8080
  
CMD /ubuntu.sh
