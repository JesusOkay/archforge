# Maintainer: Jesus <jesusaiyan@gmail.com>
pkgname=archforge
pkgver=1.0.0
pkgrel=1
pkgdesc="Servidor de compilación remoto para Arch Linux. Compila paquetes AUR en tu máquina potente via Docker+SSH."
arch=('any')
url="https://github.com/jesusaiyan/archforge"
license=('MIT')
depends=(
  'docker'
  'openssh'
  'rsync'
)
source=(
  'archforge'
  'archforge-remote'
  'archforge-makepkg'
  'Dockerfile'
)
sha256sums=('SKIP' 'SKIP' 'SKIP' 'SKIP')

package() {
  install -Dm755 "$srcdir/archforge" "$pkgdir/usr/local/bin/archforge"
  install -Dm755 "$srcdir/archforge-remote" "$pkgdir/usr/local/bin/archforge-remote"
  install -Dm755 "$srcdir/archforge-makepkg" "$pkgdir/usr/local/bin/archforge-makepkg"
  install -Dm644 "$srcdir/Dockerfile" "$pkgdir/usr/share/archforge/Dockerfile"
}
