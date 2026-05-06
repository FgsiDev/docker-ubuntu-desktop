FROM debian

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt upgrade -y && apt install -y \
    openssh-server wget unzip vim curl python3

# Setup SSH di port 7850
RUN mkdir /run/sshd \
    && echo 'Port 7850' >> /etc/ssh/sshd_config \
    && echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config \
    && echo 'root:root' | chpasswd

# Script startup
RUN echo '/usr/sbin/sshd -D' > /start.sh \
    && chmod +x /start.sh

EXPOSE 7850

CMD ["/start.sh"]
