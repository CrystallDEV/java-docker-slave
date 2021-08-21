FROM ubuntu:21.10

LABEL maintainer="Marek Hasselder <m.hasselder@gmx.de>"
ENV DEBIAN_FRONTEND=noninteractive

# Make sure the package repository is up to date.
RUN apt-get update
RUN apt-get -qy upgrade

# Install git
RUN apt-get install -qy git

# Install a basic SSH server
RUN apt-get install -qy openssh-server
RUN sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd
RUN mkdir -p /var/run/sshd

# Install repository utility
RUN apt-get install -qy software-properties-common

# Install JDK
RUN apt-get install -qy openjdk-16-jdk

# Install maven
RUN apt-get install -qy maven

# Cleanup old packages
RUN apt-get -qy autoremove
# Add user jenkins to the image
RUN adduser jenkins --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password
RUN echo "jenkins:jenkins" | chpasswd

# Create .m2 folder / Maven related
RUN mkdir -p /home/jenkins/.m2
ADD settings.xml /home/jenkins/.m2/

# Copy authorized keys
COPY .ssh/authorized_keys /home/jenkins/.ssh/authorized_keys

RUN chown -R jenkins:jenkins /home/jenkins/.m2/ && \
    chown -R jenkins:jenkins /home/jenkins/.ssh/

# Standard SSH port
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
