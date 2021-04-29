# Author: Hunter Wittenborn <git@hunterwittenborn.me>
# Maintainer: Hunter Wittenborn <git@hunterwittenborn.me>

pkgname=makedeb
pkgver=2.0.5
pkgrel=4
pkgdesc="Make PKGBUILDs work on Debian-based distros"
arch=('any')
depends=('makepkg' 'dpkg-dev' 'binutils' 'file')
conflicts=('makedeb-alpha')
license=('GPL3')
url="https://github.com/hwittenborn/makedeb"

source=("makedeb.sh"
        "packages.db")
sha256sums=('SKIP'
	          'SKIP')

package() {
  mkdir -p "${pkgdir}/usr/bin/"
  cp "${srcdir}/makedeb.sh" "${pkgdir}/usr/bin/makedeb"
  mkdir -p "${pkgdir}/etc/makedeb"
   cp "${srcdir}/packages.db" "${pkgdir}/etc/makedeb/"
}

# You shouldn't touch this unless you have an explicit reason to. This is
# normally used in the CI for deploying an alpha package if set.
if [[ "${release_type}" == "alpha" ]]; then
  conflicts=('makedeb')
fi
