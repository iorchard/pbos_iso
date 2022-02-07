PBOS-ISO
=========

PBOS is Pure Baremetal OpenStack.

This is a guide about how to maintain PBOS repositories and create an iso file.

pre-requisite
-----------------

Install podman to build and run containers.::

    $ sudo dnf -y install podman

pbos-reposync
----------------

This is an image to build and update PBOS repos.

Build a container image.::

    $ podman build -t jijisa/pbos-reposync:8.5 .

Push the image.::

    $ podman login
    Username:
    Password:
    Login succeeded.
    $ podman push jijisa/pbos-reposync:8.5

Run pbos-reposync container to create/update PBOS repositories.::

    $ podman run --rm -v/srv/pbos:/srv/pbos jijisa/pbos-reposync:8.5


pbos-iso
-----------

This is an image to create pbos ISO file.

Copy rocky linux minimal iso to /srv/pbos/iso/.::

    $ curl -LO https://download.rockylinux.org/pub/rocky/8/isos/x86_64/Rocky-8.5-x86_64-minimal.iso
    $ sudo mount -o loop Rocky-8.5-x86_64-minimal.iso /mnt
    $ rsync -av --progress /mnt/ /srv/pbos/iso/ \
        --exclude BaseOS --exclude Minimal --exclude isolinux.cfg

Build a container image.::

    $ podman build -t jijisa/pbos-iso:8.5 .

Push the image.::

    $ podman login
    Username:
    Password:
    Login succeeded.
    $ podman push jijisa/pbos-iso:8.5

Run pbos-iso container to build iso file.::

    $ podman run --rm -v /srv/pbos:/srv/pbos jijisa/pbos-iso:8.5

The pbos-8.5.iso file will be created in /srv/pbos/ directory.

