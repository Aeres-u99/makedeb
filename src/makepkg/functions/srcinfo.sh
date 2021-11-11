#!/usr/bin/bash
#
#   srcinfo.sh - functions for writing .SRCINFO files
#
#   Copyright (c) 2014-2021 Pacman Development Team <pacman-dev@archlinux.org>
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

[[ -n "$LIBMAKEPKG_SRCINFO_SH" ]] && return
LIBMAKEPKG_SRCINFO_SH=1

LIBRARY=${LIBRARY:-'/usr/share/makepkg'}

source "$LIBRARY/util/pkgbuild.sh"
source "$LIBRARY/util/schema.sh"

srcinfo_open_section() {
	printf '%s = %s\n' "$1" "$2"
}

srcinfo_separate_section() {
	echo
}

srcinfo_write_attr() {
	# $1: attr name
	# $2: attr values

	local attrname=$1 attrvalues=("${@:2}")

	# normalize whitespace, strip leading and trailing
	attrvalues=("${attrvalues[@]//+([[:space:]])/ }")
	attrvalues=("${attrvalues[@]#[[:space:]]}")
	attrvalues=("${attrvalues[@]%[[:space:]]}")

	printf "\t$attrname = %s\n" "${attrvalues[@]}"
}

pkgbuild_extract_to_srcinfo() {
	# $1: pkgname
	# $2: attr name
	# $3: multivalued

	local pkgname=$1 attrname=$2 isarray=$3 outvalue=

	if get_pkgbuild_attribute "$pkgname" "$attrname" "$isarray" 'outvalue'; then
		srcinfo_write_attr "$attrname" "${outvalue[@]}"
	fi
}

srcinfo_write_section_details() {
	local attr package_arch a
	local set_output="${2}"
	local multivalued_arch_attrs=(source provides conflicts depends replaces
	                              optdepends makedepends checkdepends
	                              "${known_hash_algos[@]/%/sums}")

	local multivalued_arch_attrs+=($(srcinfo_get_distro_variables "" "${set_output}"))

	for attr in "${singlevalued[@]}"; do
		pkgbuild_extract_to_srcinfo "$1" "$attr" 0
	done

	for attr in "${multivalued[@]}"; do
		pkgbuild_extract_to_srcinfo "$1" "$attr" 1
	done

	get_pkgbuild_attribute "$1" 'arch' 1 'package_arch'
	for a in "${package_arch[@]}"; do
		# 'any' is special. there's no support for, e.g. depends_any.
		[[ $a = any ]] && continue

		for attr in "${multivalued_arch_attrs[@]}"; do
			pkgbuild_extract_to_srcinfo "$1" "${attr}_$a" 1
		done
	done
}

srcinfo_write_global() {
	local set_output="${1}"
	
	local singlevalued=(pkgdesc pkgver pkgrel epoch url install changelog)
	local multivalued=(arch groups license checkdepends makedepends
	                   depends optdepends provides conflicts replaces
	                   noextract options backup
	                   source validpgpkeys "${known_hash_algos[@]/%/sums}")

	local multivalued+=($(srcinfo_get_distro_variables "" "${set_output}"))

	srcinfo_open_section 'pkgbase' "${pkgbase:-$pkgname}"
	srcinfo_write_section_details '' "${set_output}"
}

srcinfo_write_package() {
	local set_output="${2}"
	
	local singlevalued=(pkgdesc url install changelog)
	local multivalued=(arch groups license checkdepends depends optdepends
	                   provides conflicts replaces options backup)

	local multivalued+=($(srcinfo_get_distro_variables "" "${set_output}"))

	srcinfo_open_section 'pkgname' "$1"
	srcinfo_write_section_details "$1"
}

write_srcinfo_header() {
	printf "# Generated by makedeb-makepkg %s\n" "$makepkg_version"
	printf "# %s\n" "$(LC_ALL=C date -u)"
}

write_srcinfo_content() {
	local pkg
	local set_output="${1}"

	# write_srcinfo_content() is called directly in addition to write_srcinfo(), so we
	# need to handle the 'set_output' variable not being set.
	if ! [[ "${set_output}" ]]; then
		set_output="$(set)"
	fi

	srcinfo_open_section 'generated-by' 'makedeb-makepkg'
	srcinfo_separate_section

	srcinfo_write_global "${set_output}"

	for pkg in "${pkgname[@]}"; do
		srcinfo_separate_section
		srcinfo_write_package "$pkg" "${set_output}"
	done
}

write_srcinfo() {
	local set_output="$(set)"

	write_srcinfo_header
	write_srcinfo_content "${set_output}"
}

# Obtain a list of distro-specific variables.
srcinfo_get_distro_variables() {
	local package_arch
	local set_output="${2}"
	get_pkgbuild_attribute "$1" 'arch' 1 'package_arch'

	for i in source depends optdepends conflicts provides replaces makedepends "${known_hash_algos[@]/%/sums}"; do

		local distro_variables=""

		for j in "${package_arch}"; do
			local distro_variables+="$(echo "${set_output}" | grep -o "^[[:alnum:]]\+_${i}=" | sed 's|=$||g')"
			local distro_variables+="$(echo "${set_output}" | grep -o "^[[:alnum:]]\+_${i}_${j}=" | sed 's|=$||g')"
		done

		if [[ "${distro_variables}" != "" ]]; then
			echo "${distro_variables}"
		fi
	done
}
