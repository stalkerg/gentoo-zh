# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit linux-info go-module systemd

DESCRIPTION="A lightweight and high-performance transparent proxy solution based on eBPF"
HOMEPAGE="https://github.com/daeuniverse/dae"

LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="~amd64"
MINKV="5.8"
_I="378c3c576e0f4c785a3d5e71400b552725527f30"
SRC_URI="
	https://github.com/daeuniverse/dae/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/st0nie/gentoo-go-deps/releases/download/dae_bpf_headers/dae_bpf_headers-$_I.zip
	https://github.com/st0nie/gentoo-go-deps/releases/download/dae-${PV}/${P}-deps.tar.xz
"
DEPEND="
	dev-libs/v2ray-domain-list-community-bin
	dev-libs/v2ray-geoip-bin
"
RDEPEND="$DEPEND"
BDEPEND="sys-devel/clang"

pkg_pretend() {
	local CONFIG_CHECK="~DEBUG_INFO_BTF ~NET_CLS_ACT ~NET_SCH_INGRESS ~NET_INGRESS ~NET_EGRESS"

	if kernel_is -lt ${MINKV//./ }; then
		ewarn "Kernel version at least ${MINKV} required"
	fi

	check_extra_config
}

src_unpack() {
	go-module_src_unpack
	mv "${WORKDIR}"/dae_bpf_headers-$_I/* control/kern/headers || die
}

src_compile() {
	emake VERSION="${PV}" GOFLAGS="-buildvcs=false" CC=clang CFLAGS="$CFLAGS -fno-stack-protector"
}

src_install() {
	dobin dae
	systemd_dounit install/dae.service
	insinto /etc/dae
	newins example.dae config.dae.example
	dosym -r "/usr/share/v2ray/geosite.dat" /usr/share/dae/geosite.dat
	dosym -r "/usr/share/v2ray/geoip.dat" /usr/share/dae/geoip.dat
}
