#!/bin/sh
# =============================================================================
#
# Onboard a dual-boot silverblue machine
#
# Copyright 2023 J. Cody Collins
#
# Last Modified:Fri 2023-03-31 14:44:23 (-0400)
#
# =============================================================================

DEFAULT_OS="Windows Boot Manager (on /dev/nvme0n1p1)"
FLATPAK_PACKAGES=(
    org.libreoffice.LibreOffice
    in.srev.guiscrcpy
    com.google.Chrome
    org.vim.Vim
)
RPM_OSTREE_PACKAGES=(
    gnome-kiosk
    gnome-kiosk-script-session
    gnome-kiosk-search-appliance
)

function main {
    set_grub_default
    update_os
    install_rpm_ostree_packages
    install_flatpak_packages
}

function set_grub_default {
    echo -n "Set Windows as default OS? (y/n): "
    read set_grub_default
    if [ "${set_grub_default}" == "y" ]; then
        grub2-set-default "${DEFAULT_OS}"
    fi
}

function update_os {
    sudo rpm-ostree cancel
    sudo rpm-ostree upgrade
    flatpak update
    flatpak uninstall --unused -y
}

function install_rpm_ostree_packages {
    echo "Install the following packages? (y/n)"
    echo ${RPM_OSTREE_PACKAGES[@]}
    read install_rpm_ostree_packages
    if [ "${install_rpm_ostree_packages}" == "y" ]; then
        sudo rpm-ostree install ${RPM_OSTREE_PACKAGES[@]}
    fi
}

function install_flatpak_packages {
    echo "Install the following packages (y/n)"
    echo ${FLATPAK_PACKAGES[@]}
    read install_flatpak_packages
    if [ "${install_flatpak_packages}" == "y" ]; then
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        for package in "${FLATPAK_PACKAGES[@]}"; do
            flatpak install "$package"
        done
        configure_aliases
    fi
}

function configure_aliases {
    sudo echo "alias vim='flatpak run org.vim.Vim'" > /etc/profile.d/flatpak_aliases.sh
}

main
