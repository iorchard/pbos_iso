#!/bin/bash

set -eo pipefail

BASEDIR="/srv/pbos"
OUTDIR="$BASEDIR/artifacts"
VER=${1:-8.5}
TAG=${2:-1.0.0}
LABEL="PBOS-Rocky-8-5-x86_64-dvd"
declare arr=()

mkdir -p $OUTDIR
cp -af $BASEDIR/iso/* /iso/
# Put pbos-ansible tarball with pbos.* roles.
curl -sLo pbos-ansible-${TAG}.tar.gz \
    https://github.com/iorchard/pbos-ansible/archive/refs/tags/${TAG}.tar.gz
tar xzf pbos-ansible-${TAG}.tar.gz
ansible-galaxy role install --roles-path /pbos-ansible-${TAG}/roles \
    --role-file requirements.yml
cp requirements.yml pbos-ansible-${TAG}/
tar czf pbos-ansible-${TAG}.tar.gz pbos-ansible-${TAG}
cp -f pbos-ansible-${TAG}.tar.gz /iso/

# pip download
python3 -m pip download --dest $BASEDIR/pip --requirement pip-requirements.txt
cp -af $BASEDIR/pip /iso/

# rpm copy
mkdir -p /iso/{BaseOS,pbos}/Packages
cat pbos.rpm_list | while IFS= read -r line;do
  arr=($line)
  p=${arr[0]%.*}
  a=${arr[0]##*.}
  v=${arr[1]}
  r=${arr[2]#@}
  echo "Getting $p."

  # lshw version starts with B so I added B in name search.
  # first find the package in baseos if repo is not baseos.
  if [[ "$r" != "baseos" ]];then
    RPM=$(find $BASEDIR/baseos/ -name ${p}-[0-9B]*.${a}.rpm)
    if [[ "x$RPM" != "x" ]];then
      cp -af $RPM /iso/BaseOS/Packages/
    fi
    RPM=$(find $BASEDIR/$r/ -name ${p}-[0-9B]*.${a}.rpm)
    cp -af $RPM /iso/pbos/Packages/
  else
    RPM=$(find $BASEDIR/$r/ -name ${p}-[0-9B]*.${a}.rpm)
    cp -af $RPM /iso/BaseOS/Packages/
  fi
done

# get two custom rpm packages
cd /iso/pbos/Packages/
curl -sLO 192.168.151.110:8000/pbos/custom/cloudpc-libvirt-hooks-1.0.0-1.x86_64.rpm
curl -sLO 192.168.151.110:8000/pbos/custom/qemu-cloudpc-0.26.5.0-1.el8.x86_64.rpm

# create iso
cd /iso
createrepo -vg comps_base.xml BaseOS
createrepo -v pbos
repo2module --module-name pbos --module-stream stable pbos pbos/modules.yaml
createrepo_mod pbos

genisoimage -o $OUTDIR/pbos-${VER}.iso \
            -b isolinux/isolinux.bin \
            -c isolinux/boot.cat \
            --no-emul-boot \
            --boot-load-size 4 \
            --boot-info-table \
            --eltorito-alt-boot \
            -e images/efiboot.img \
            --no-emul-boot \
            -J -R -V "$LABEL" .

cd $OUTDIR
md5sum pbos-${VER}.iso > pbos-${VER}.md5sum
