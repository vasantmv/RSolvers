AC_INIT([RSolvers], [0.9-0])
AC_LANG(C++)
AC_PROG_CXX

# Check for pkg-config
AC_PATH_PROG([PKG_CONFIG], [pkg-config], [no])
if test "x$PKG_CONFIG" = "xno"; then
  AC_MSG_WARN([pkg-config not found, solver detection may fail])
fi

# Check for CBC
PKG_CHECK_MODULES([CBC], [cbc >= 2.10], [have_cbc=yes], [have_cbc=no])
if test "x$have_cbc" = "xyes"; then
  AC_DEFINE([HAVE_CBC], [1], [Define if CBC is available])
fi

# Check for HiGHS
PKG_CHECK_MODULES([HIGHS], [highs], [have_highs=yes], [have_highs=no])
if test "x$have_highs" = "xyes"; then
  AC_DEFINE([HAVE_HIGHS], [1], [Define if HiGHS is available])
fi

# Check for SCIP
PKG_CHECK_MODULES([SCIP], [scip], [have_scip=yes], [have_scip=no])
if test "x$have_scip" = "xyes"; then
  AC_DEFINE([HAVE_SCIP], [1], [Define if SCIP is available])
fi

# Check for Ipopt
PKG_CHECK_MODULES([IPOPT], [ipopt], [have_ipopt=yes], [have_ipopt=no])
if test "x$have_ipopt" = "xyes"; then
  AC_DEFINE([HAVE_IPOPT], [1], [Define if Ipopt is available])
fi

AC_SUBST(CBC_CFLAGS)
AC_SUBST(CBC_LIBS)
AC_SUBST(HIGHS_CFLAGS)
AC_SUBST(HIGHS_LIBS)
AC_SUBST(SCIP_CFLAGS)
AC_SUBST(SCIP_LIBS)
AC_SUBST(IPOPT_CFLAGS)
AC_SUBST(IPOPT_LIBS)

AC_CONFIG_FILES([src/Makevars])
AC_OUTPUT
