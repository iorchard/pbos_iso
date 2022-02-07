FROM        rockylinux:8.5
ENV         MIRROR_DIR="/srv/pbos"
WORKDIR     /
RUN         dnf -y install 'dnf-command(reposync)'
COPY        sync.sh    /
COPY        etc/yum.repos.d/*   /etc/yum.repos.d/
COPY        etc/pki/rpm-gpg/*   /etc/pki/rpm-gpg/
VOLUME      ["${MIRROR_DIR}"]
ENTRYPOINT  ["/sync.sh"]
