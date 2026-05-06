FROM debian
ARG NGROK_TOKEN
ARG REGION=ap
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt upgrade -y && apt install -y \
    ssh wget unzip vim curl python3

RUN mkdir -p /run/sshd \
    && echo "ls" >>/openssh.sh \
    && echo 'R3_REGISTRATION_CODE="ACB11C85-5611-56E0-A50B-B58250FF47DE" sh -c "$(curl -L https://downloads.remote.it/remoteit/install_agent.sh)"' >>/openssh.sh \
    && echo "sleep 5" >> /openssh.sh \
    && echo '/usr/sbin/sshd -D' >>/openssh.sh \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config  \
    && echo root:root|chpasswd \
    && chmod 755 /openssh.sh
EXPOSE 80 443 3306 4040 5432 5700 5701 5010 6800 6900 8080 8888 9000
CMD /openssh.sh
