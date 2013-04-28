# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit cmake-utils eutils flag-o-matic

DESCRIPTION="Dolphin is a Gamecube and Wii game emulator"
HOMEPAGE="http://www.dolphin-emulator.com/"
SRC_URI="http://${PN}-emu.googlecode.com/files/${P}-src.zip"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="alsa ao bluetooth ffmpeg openal pulseaudio"

DEPEND="app-arch/zip
	media-gfx/nvidia-cg-toolkit
	media-libs/freetype
	sys-libs/readline
	>=x11-libs/wxGTK-2.9.3.1
	x11-libs/libXext
	alsa? ( media-libs/alsa-lib )
	ao? ( media-libs/libao )
	bluetooth? ( net-wireless/bluez )
	ffmpeg? ( virtual/ffmpeg )
	openal? ( media-libs/openal )
	pulseaudio? ( media-sound/pulseaudio )
	"
RDEPEND="${DEPEND}"

src_configure() {
	append-ldflags -L/opt/nvidia-cg-toolkit/lib64
	append-cppflags -I/opt/nvidia-cg-toolkit/include
	cmake-utils_src_configure
}

src_compile() {
	append-ldflags -L/opt/nvidia-cg-toolkit/lib64
	append-cppflags -I/opt/nvidia-cg-toolkit/include
	cmake-utils_src_compile
}

src_install() {
	cmake-utils_src_install
	doicon Source/Core/DolphinWX/resources/Dolphin.xpm
	make_desktop_entry "${PN}" "Dolphin" "Dolphin" "Game;Emulator"
}

pkg_postinst() {
	ewarn "The desktop entry for dolphin-3.5 is not being created correctly."
	ewarn "You can access it through a terminal by running: \"dolphin-emu\"."
	ewarn "Or by creating your own desktop entry."
}
