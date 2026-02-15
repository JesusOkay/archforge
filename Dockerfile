FROM archlinux:base-devel

# Habilitar multilib y repos de CachyOS (para lib32-* y paquetes CachyOS)
RUN echo -e "\n[cachyos]\nSigLevel = Never\nServer = https://mirror.cachyos.org/repo/x86_64/cachyos\n\n[multilib]\nInclude = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf

# Actualizar el sistema e instalar dependencias comunes
RUN pacman -Syu --noconfirm --needed git sudo

# Crear el usuario builder
RUN useradd -m builder && \
    echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Configurar el directorio de trabajo
WORKDIR /pkg

# Cambiar el propietario inicial
RUN chown builder:builder /pkg

# Comando por defecto para makepkg
USER builder
CMD ["makepkg", "-sf", "--noconfirm"]
