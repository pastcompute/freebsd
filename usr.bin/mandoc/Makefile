# $FreeBSD$

MDOCMLDIR=	${.CURDIR}/../../contrib/mdocml
LIBMANDOC=	${.OBJDIR}/../../lib/libmandoc/libmandoc.a
.PATH: ${MDOCMLDIR}

PROG=	mandoc
FILES=	example.style.css style.css
FILESDIR=	${SHAREDIR}/mdocml
LINKS=	mdocml
MAN=	mandoc.1 eqn.7 mandoc_char.7 tbl.7 # man.7 mdoc.7 roff.7
MLINKS= mandoc.1 mdocml.1

HTML_SRCS=	eqn_html.c \
		html.c \
		man_html.c \
		mdoc_html.c \
		tbl_html.c
MAN_SRCS=	mdoc_man.c
TERM_SRCS=	eqn_term.c \
		man_term.c \
		mdoc_term.c \
		term.c \
		term_ascii.c \
		term_ps.c \
		tbl_term.c
SRCS=		${HTML_SRCS} \
		${MAN_SRCS} \
		${TERM_SRCS} \
		main.c \
		out.c \
		tree.c

WARNS?=	3
CFLAGS+= -DHAVE_CONFIG_H
DPADD=	${LIBMANDOC}
LDADD=	${LIBMANDOC}

.include <bsd.prog.mk>
