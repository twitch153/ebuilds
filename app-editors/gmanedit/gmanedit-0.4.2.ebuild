# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

DESCRIPTION="An editor for man pages that runs on X using the GTK+ libraries."
HOMEPAGE="http://gmanedit.sourceforge.net/"
SRC_URI="mirror://sourceforge.net/${PN}2/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}
	>=x11-libs/gtk+-2.24.12"
