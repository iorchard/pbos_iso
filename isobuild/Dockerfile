FROM        rockylinux:8.5
ENV         MIRROR_DIR="/srv/pbos"
WORKDIR     /
COPY        build.sh    /
COPY        pbos.rpm_list   /
COPY        pip-requirements.txt   /
COPY        requirements.yml /
ADD         iso   /iso
RUN         dnf -y install createrepo_c modulemd-tools \
                genisoimage findutils python3 git && \
            python3 -m pip install -U pip && \
            python3 -m pip install ansible==4.10.0
VOLUME      ["${MIRROR_DIR}"]
ENTRYPOINT  ["/build.sh"]
