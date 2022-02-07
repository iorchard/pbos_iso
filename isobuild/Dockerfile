FROM        rockylinux:8.5
ENV         MIRROR_DIR="/srv/pbos"
WORKDIR     /
COPY        build.sh    /
COPY        pbos.rpm_list   /
ADD         iso   /iso
RUN         dnf -y install createrepo_c modulemd-tools genisoimage findutils
VOLUME      ["${MIRROR_DIR}"]
ENTRYPOINT  ["/build.sh"]
