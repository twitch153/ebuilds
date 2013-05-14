# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit cmake-utils eutils flag-o-matic pax-utils

DESCRIPTION="Dolphin is a Gamecube and Wii game emulator"
HOMEPAGE="http://www.dolphin-emulator.com/"
SRC_URI="http://${PN}-emu.googlecode.com/files/${P}-src.zip"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE="alsa ao bluetooth docs ffmpeg lzo openal opengl portaudio pulseaudio"

RDEPEND=">=media-libs/glew-1.6
	>=media-libs/libsdl-1.2[joystick]
	<media-libs/libsfml-2.0
	sys-libs/readline
	>=x11-libs/wxGTK-2.9.3.1
	x11-libs/libXext
	x11-libs/libXrandr
	alsa? ( media-libs/alsa-lib )
	ao? ( media-libs/libao )
	bluetooth? ( net-wireless/bluez )
	ffmpeg? ( virtual/ffmpeg )
	lzo? ( dev-libs/lzo )
	openal? ( media-libs/openal )
	opengl? ( virtual/opengl )
	portaudio?  ( media-libs/portaudio )
	pulseaudio? ( media-sound/pulseaudio )
	"
DEPEND="${RDEPEND}
	app-arch/zip
    media-gfx/nvidia-cg-toolkit
	media-libs/freetype
	>=sys-devel/gcc-4.6.0
	sys-devel/gettext
	virtual/pkgconfig
	"

src_configure() {
	
	if $($(tc-getPKG_CONFIG) --exists nvidia-cg-toolkit); then
		append-flags "$($(tc-getPKG_CONFIG) --cflags nvidia-cg-toolkit)"
	else
		append-flags "-I/opt/nvidia-cg-toolkit/include"
	fi

	if $($(tc-getPKG_CONFIG) --exists nvidia-cg-toolkit); then
		append-ldflags "$($(tc-getPKG_CONFIG) --libs-only-L nvidia-cg-toolkit)"
	else
		if has_version ">=media-gfx/nvidia-cg-toolkit-3.1.0013"; then
			append-ldflags "-L/opt/nvidia-cg-toolkit/lib64"
		elif has_version "<=media-gfx/nvidia-cg-toolkit-2.1.0017-r1"; then
			append-ldflags "-L/opt/nvidia-cg-toolkit/lib"
		fi
	fi

	cmake-utils_src_configure
}

src_install() {

	cmake-utils_src_install

	dodoc Readme.txt
	if use docs; then
		doins -r docs
	fi

	doicon Source/Core/DolphinWX/resources/Dolphin.xpm
	make_desktop_entry "dolphin-emu" "Dolphin" "Dolphin" "Game;"
}

pkg_postinst() {
	# Add pax markings for hardened systems
	pax-mark -m "$EPREFIX}"/usr/bin/"${PN}"

	if !use portaudio; then
		ewarn "If you want microphone capabilities in dolphin-emu, rebuild with
		USE=\"portaudio\""
	fi
}
