FROM debian

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt upgrade -y && apt install -y \
    openssh-server wget unzip vim curl python3

# Setup SSH
RUN mkdir /run/sshd \
    && echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config \
    && echo 'root:craxid' | chpasswd

# Script startup
RUN echo '/usr/sbin/sshd -D' > /start.sh \
    && chmod +x /start.sh

EXPOSE 22

CMD ["/start.sh"]
