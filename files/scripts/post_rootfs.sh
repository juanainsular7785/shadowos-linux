#!/usr/bin/env bash
set -euo pipefail

IMAGE_VARIANT_ID=$(grep '^VARIANT_ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
IMAGE_REF="ghcr.io/shadowos-linux/$IMAGE_VARIANT_ID"
IMAGE_TAG="latest"

dnf install -y anaconda-live firefox libblockdev-btrfs libblockdev-lvm libblockdev-dm --setopt=disable_excludes=*
sed -i '/\[Desktop Entry\]/a NoDisplay=true' /usr/share/applications/org.mozilla.firefox.desktop

sed -i -e 's/Fedora/ShadowOS/g' /usr/share/anaconda/ui/anaconda.ui || true

mkdir -p /etc/anaconda/profile.d/
cat > /etc/anaconda/profile.d/shadowos.conf <<EOF
[Profile]
profile_id = shadowos

[Profile Detection]
os_id = shadowos

[Storage]
default_scheme = BTRFS
btrfs_compression = zstd:1

[Bootloader]
efi_dir = fedora

[User Interface]
custom_stylesheet = /usr/share/anaconda/pixmaps/fedora-silverblue.css
EOF

tee -a /usr/share/anaconda/interactive-defaults.ks <<EOF
ostreecontainer --url=$IMAGE_REF:$IMAGE_TAG --transport=containers-storage --no-signature-verification
EOF

mkdir -p /usr/share/anaconda/post-scripts/
tee /usr/share/anaconda/post-scripts/post-install-switch.ks <<EOF
%post --erroronfail
bootc switch --mutate-in-place --transport registry $IMAGE_REF:$IMAGE_TAG
%end
EOF

echo "%include /usr/share/anaconda/post-scripts/post-install-switch.ks" >> /usr/share/anaconda/interactive-defaults.ks
