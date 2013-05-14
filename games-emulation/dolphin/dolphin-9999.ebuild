# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit cmake-utils

if [[ ${PV} == 9999* ]]
then
	EGIT_REPO_URI="https://code.google.com/p/dolphin-emu/"
	inherit git-2
	KEYWORKD=""
else
	SRC_URI="http://${PN}-emu.googlecode.com/files/${P}-src.zip"
	KEYWORDS="~amd"
fi

DESCRIPTION="Dolphin is a Gamecube and Wii game emulator"
HOMEPAGE="http://www.dolphin-emulator.com/"

LICENSE="GPL-2"
SLOT="0"
IUSE="alsa ao bluetooth docs ffmpeg lzo openal opengl openmp portaudio pulseaudio"

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
	portaudio? ( media-libs/portaudio )
	pulseaudio? ( media-sound/pulseaudio )
	"
DEPEND="${RDEPEND}
	app-arch/zip
	media-gfx/nvidia-cg-toolkit
	media-libs/freetype
	>=sys-devel/gcc-4.6.0
	"

src_prepare() {

	if has_version "=sys-devel/gcc-4.8.0"; then
		epatch "${FILESDIR}"/${PN}-emu-${PV}-gcc-4.8.patch
	fi

	# Remove automatic dependencies to prevent building without flags enabled.
	if use !alsa; then
		sed -i -e '^/include(FindALSA/d' CMakeLists.txt || die
	fi
	if use !ao; then
		sed -i -e '/^check_lib(AO/d' CMakeLists.txt || die
	fi
	if use !bluetooth; then 
		sed -i -e '/^check_lib(BLUEZ/d' CMakeLists.txt || die
	fi
	if use !openal; then
		sed -i -e '/^include(FindOpenAL/d' CMakeLists.txt || die
	fi
	if use !portaudio; then
		sed -i -e '/CMAKE_REQUIRED_LIBRARIES portaudio/d' CMakeLists.txt || die
	fi
	if use !pulseaudio; then
		sed -i -e '/^check_lib(PULSEAUDIO/d' CMakeLists.txt || die
	fi

	# Remove ALL the bundled libraries, aside from:
	# - SOIL: The sources are not public.
	# - Bochs-disasm: Don't know what it is.
	# - CLRun: Part of OpenCL
	mv Externals/SOIL . || die
	mv Externals/Bochs_disasm . || die
	mv Externals/CLRun . || die
	rm -r Externals/* || die 
	mv CLRun Externals || die
	mv Bochs_disasm Externals || die
	mv SOIL Externals || die

	local mycmakeargs=(
		"-DDOLPHIN_WC_REVISION=${PV}"
		"-DCMAKE_INSTALL_PREFIX=${GAMES_PREFIX}"
		"-Dprefix=${GAMES_PREFIX}"
		"-Ddatadir=${GAMES_DATADIR}/${PN}"
		"-Dplugindir-$(games_get_libdir)/${PN}"
		$(cmake-utils_use ffmpeg ENCODE_FRAMEDUMPS)
		$(cmake-utils_use openmp OPENMP )
	)

	cmake-utils_src_configure
}

src_install() {

	cmake-utils_src_install

	dodoc Readme.txt
	if use docs; then
		doins -r docs
	fi

	doicon "${S}/Installer/Dolphin.ico"
}

pkg_postinst() {
	# Add pax markings for hardened systems
	pax-mark -m "${EPREFIX}"/usr/games/bin/"${PN}"-emu

	if ! use portaudio; then
		ewarn "If you want microphone capabilities in dolphin-emu, rebuild with"
		ewarn "USE=\"portaudio\""
	fi
}
