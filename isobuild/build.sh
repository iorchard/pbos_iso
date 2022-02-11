#!/bin/bash

set -euo pipefail

OUTDIR="/srv/pbos/artifacts"
VER=${1:-8.5}
LABEL="PBOS-Rocky-8-5-x86_64-dvd"
arr=()

mkdir -p $OUTDIR
cp -af /srv/pbos/iso/* /iso/
# pip download
python3 -m pip download --dest /srv/pbos/pip --requirement pbos-pip.txt
# rpm copy
cp -af /srv/pbos/pip /iso/
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
    RPM=$(find /srv/pbos/baseos/ -name ${p}-[0-9B]*.${a}.rpm)
    if [[ "x$RPM" != "x" ]];then
      cp -af $RPM /iso/BaseOS/Packages/
    fi
    RPM=$(find /srv/pbos/$r/ -name ${p}-[0-9B]*.${a}.rpm)
    # sshpass is in epel repo but I want to copy it to baseos.
    [[ "$p" = "sshpass" ]] && cp -af $RPM /iso/BaseOS/Packages/ || cp -af $RPM /iso/pbos/Packages/
  else
    RPM=$(find /srv/pbos/$r/ -name ${p}-[0-9B]*.${a}.rpm)
    cp -af $RPM /iso/BaseOS/Packages/
  fi
done

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
