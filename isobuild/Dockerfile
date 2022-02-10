FROM        rockylinux:8.5
ENV         MIRROR_DIR="/srv/pbos"
WORKDIR     /
COPY        build.sh    /
COPY        pbos.rpm_list   /
COPY        pbos-pip.txt   /
ADD         iso   /iso
RUN         dnf -y install createrepo_c modulemd-tools \
                genisoimage findutils python3 && \
            python3 -m pip install -U pip
VOLUME      ["${MIRROR_DIR}"]
ENTRYPOINT  ["/build.sh"]
