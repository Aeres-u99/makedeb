# Author: Hunter Wittenborn <git@hunterwittenborn.me>
# Maintainer: Hunter Wittenborn <git@hunterwittenborn.me>

pkgname=makedeb
pkgver=1.1.2.8
pkgrel=1
pkgdesc="Make PKGBUILDs work on Debian-based distros"
arch=('any')
depends=('makepkg')
license=('GPL3')
url="https://github.com/hwittenborn/makedeb"

source=("makedeb"
        "packages.db")
sha256sums=('SKIP'
	          'SKIP')

package() {
  mkdir -p "${pkgdir}/usr/bin/"
  cp "${srcdir}/makedeb" "${pkgdir}/usr/bin/"
  mkdir -p "${pkgdir}/etc/makedeb"
   cp "${srcdir}/packages.db" "${pkgdir}/etc/makedeb/"
}
