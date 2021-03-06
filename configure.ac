AC_PREREQ([2.63])
AC_INIT([rkt], [0.10.0+git], [https://github.com/coreos/rkt/issues])

AC_DEFUN([RKT_CHECK_PROG],
         [AS_VAR_IF([$1], [],
                    [AC_CHECK_PROG($@)],[:])])

AC_DEFUN([RKT_REQ_PROG],
         [AS_VAR_IF([$1], [],
                    [AC_CHECK_PROG($@)
                     AS_VAR_IF([$1], [$3], [:], AC_MSG_ERROR([*** $2 not found]))],
                    [:])])

AC_DEFUN([RKT_REQ_ABS_PROG],
         [AS_VAR_IF([$1], [],
                    [AC_PATH_PROG($@)
                     AS_IF([test "x$]$1[" = 'x'], [AC_MSG_ERROR([*** $2 not found])])],
                    [:])])

dnl We assume having bash in lots of places, so check it in the
dnl beginning.
RKT_REQ_ABS_PROG([BASH_SHELL], [bash])

dnl if version ends with +git, append a short git-hash.
AS_IF([test `expr match 'AC_PACKAGE_VERSION' '.*+git$'` -gt 0],
      dnl version has +git suffix, ignore errors (not a git repo)
      [RKT_VERSION="AC_PACKAGE_VERSION`git rev-parse --short HEAD 2>/dev/null``git diff-index --quiet HEAD 2>/dev/null || echo -dirty`"],
      dnl version has no +git suffix
      [RKT_VERSION="AC_PACKAGE_VERSION"])

AC_CANONICAL_HOST
AC_CANONICAL_BUILD

#### FLAGS

## STAGE1 - detailed setup

AC_ARG_WITH(stage1-default-name,
            [AS_HELP_STRING([--with-stage1-default-name],
                            [default name of stage1, default: 'coreos.com/rkt/stage1-${flavor}'])],
            [RKT_STAGE1_DEFAULT_NAME="${withval}"],
            [RKT_STAGE1_DEFAULT_NAME=auto])

AC_ARG_WITH(stage1-default-version,
            [AS_HELP_STRING([--with-stage1-default-version],
                            [default version of stage1, default: same as rkt version])],
            [RKT_STAGE1_DEFAULT_VERSION="${withval}"],
            [RKT_STAGE1_DEFAULT_VERSION=auto])

## STAGE1 - flavor setup

AC_ARG_WITH([stage1-default-flavor],
            [AS_HELP_STRING([--with-stage1-default-flavor],
                            [stage1 flavor that will be loaded by default; has to be listed in --with-stage1-flavors, default: first from the stage1 flavors list])],
            [RKT_STAGE1_DEFAULT_FLAVOR="${withval}"],
            [RKT_STAGE1_DEFAULT_FLAVOR=auto])

## STAGE1 - common setup

AC_ARG_WITH([stage1-flavors],
            [AS_HELP_STRING([--with-stage1-flavors],
                            [comma-separated list of stage1 flavors; choose from 'src', 'coreos', 'host', 'kvm'; default: 'coreos,kvm'])],
            [RKT_STAGE1_FLAVORS="${withval}"],
            [RKT_STAGE1_FLAVORS=auto])

AC_ARG_WITH(stage1-default-location,
            [AS_HELP_STRING([--with-stage1-default-location],
                            [default location of stage1, default: none])],
            [RKT_STAGE1_DEFAULT_LOCATION="${withval}"],
            [RKT_STAGE1_DEFAULT_LOCATION=auto])

# STAGE1 - systemd src and version for src flavor

AC_ARG_WITH([stage1-systemd-src],
            [AS_HELP_STRING([--with-stage1-systemd-src],
                            [address to git repository of systemd, used in 'src' stage1 flavor (default: 'https://github.com/systemd/systemd.git')])],
            [RKT_STAGE1_SYSTEMD_SRC="${withval}"],
            [RKT_STAGE1_SYSTEMD_SRC='auto'])

AC_ARG_WITH([stage1-systemd-version],
            [AS_HELP_STRING([--with-stage1-systemd-version],
                            [systemd version to build, used in 'src' stage1 flavor (default: 'v222', should be in format 'v<number>', like v222)])],
            [RKT_STAGE1_SYSTEMD_VER="${withval}"],
            [RKT_STAGE1_SYSTEMD_VER='auto'])

## STAGE1 - path to coreos pxe and its systemd version for kvm and coreos flavors

AC_ARG_WITH([coreos-local-pxe-image-path],
            [AS_HELP_STRING([--with-coreos-local-pxe-image-path],
                            [path to local CoreOS PXE image, used in 'coreos' and 'kvm' stage1 flavors (default: empty) (the GPG signature of this file will not be checked!)])],
            [RKT_LOCAL_COREOS_PXE_IMAGE_PATH="${withval}"],
            [RKT_LOCAL_COREOS_PXE_IMAGE_PATH=""])

AC_ARG_WITH([coreos-local-pxe-image-systemd-version],
            [AS_HELP_STRING([--with-coreos-local-pxe-image-systemd-version],
                            [version of systemd in local CoreOS PXE image, used in 'coreos' and 'kvm' stage1 flavors (should be in format 'v<number>', like v222)])],
            [RKT_LOCAL_COREOS_PXE_IMAGE_SYSTEMD_VER="${withval}"],
            [RKT_LOCAL_COREOS_PXE_IMAGE_SYSTEMD_VER=])

## Functional tests

AC_ARG_ENABLE([functional-tests],
              [AS_HELP_STRING([--enable-functional-tests],
                              [enable functional tests on make check (linux only, uses sudo, default: 'no', use 'auto' to enable if possible, for host stage1 flavor systemd version 220 or higher on host is required)])],
              [RKT_RUN_FUNCTIONAL_TESTS="${enableval}"],
              [RKT_RUN_FUNCTIONAL_TESTS="no"])

#### CHECKING

## STAGE1 - initial verification and setup

dnl There are two kinds of setup - flavor and detailed. A flavor setup
dnl is when we specify a default flavor. A detailed setup is when we
dnl specify a default name and version instead.
AS_IF([test "x${RKT_STAGE1_DEFAULT_FLAVOR}" != 'xauto' -a '(' "x${RKT_STAGE1_DEFAULT_NAME}" != 'xauto' -o "x${RKT_STAGE1_DEFAULT_VERSION}" != 'xauto' ')'],
              dnl Passed both --with-stage1-default-flavor and
              dnl --with-stage1-default-{name,version} - bail out,
              dnl they are conflicting.
              [AC_MSG_ERROR([*** --with-stage1-default-flavor and --with-stage1-default-{name,version} flags are conflicting; use either default flavor or specific default name and version])],
      [test "x${RKT_STAGE1_DEFAULT_FLAVOR}" = 'xauto' -a "x${RKT_STAGE1_DEFAULT_NAME}" = 'xauto' -a "x${RKT_STAGE1_DEFAULT_VERSION}" = 'xauto'],
              dnl Passed neither --with-stage1-default-flavor nor
              dnl --with-stage1-default-{name,version} - default to
              dnl flavor setup.
              [RKT_STAGE1_SETUP_KIND=flavor],
      [test "x${RKT_STAGE1_DEFAULT_FLAVOR}" != 'xauto'],
              dnl Passed --with-stage1-default-flavor flag - default
              dnl to flavor setup.
              [RKT_STAGE1_SETUP_KIND=flavor],
      [test "x${RKT_STAGE1_DEFAULT_NAME}" != 'xauto' -o "x${RKT_STAGE1_DEFAULT_VERSION}" != 'xauto'],
              dnl Passed one or both from
              dnl --with-stage1-default-{name,version} - default to
              dnl detailed setup.
              [RKT_STAGE1_SETUP_KIND=detailed])

AS_CASE([${RKT_STAGE1_SETUP_KIND}],
        [detailed],
                  dnl Detailed setup - do not build any flavor unless
                  dnl explicitly asked for it and make sure that both
                  dnl name and version were passed.
                  [AS_VAR_IF([RKT_STAGE1_FLAVORS],[auto],
                             [RKT_STAGE1_FLAVORS=''])
                   RKT_STAGE1_DEFAULT_FLAVOR=''
                   AS_IF([test "x${RKT_STAGE1_DEFAULT_NAME}" = 'xauto' -o "x${RKT_STAGE1_DEFAULT_VERSION}" = 'xauto'],
                         [AC_MSG_ERROR([*** Both --with-stage1-default-name and --with-stage1-default-version must be specified])])],
        [flavor],
                  dnl The flavor setup - build coreos and kvm flavors
                  dnl and set the first flavor in the list as a
                  dnl default unless specified.
                  [AS_VAR_IF([RKT_STAGE1_FLAVORS],[auto],
                             [RKT_STAGE1_FLAVORS='coreos,kvm'])
                   AS_VAR_IF([RKT_STAGE1_DEFAULT_FLAVOR],[auto],
                             [RKT_STAGE1_DEFAULT_FLAVOR=`AS_ECHO([${RKT_STAGE1_FLAVORS}]) | cut -d, -f1`])
                   RKT_STAGE1_DEFAULT_NAME=''
                   RKT_STAGE1_DEFAULT_VERSION=''],
        [AC_MSG_ERROR([*** Unknown setup kind, should not happen])])

## Built stage1 flavors verification

dnl RKT_ITERATE_FLAVORS iterates all comma-separated flavors stored in
dnl $1 using an iterator variable $2 and executes body $3.
AC_DEFUN([RKT_ITERATE_FLAVORS],
         [for $2 in `AS_ECHO(["$1"]) | tr ',' ' '`
          do
              :
              $3
          done])

dnl RKT_IS_VALID_FLAVOR checks if $1 is a valid flavor, $2 is an
dnl additional string to an error message.
AC_DEFUN([RKT_IS_VALID_FLAVOR],
         [AS_CASE([$1],
                  dnl Correct flavor, nothing to do.
                  [coreos|kvm|host|src],
                          [],
                  dnl Bogus flavor, bail out.
                  [AC_MSG_ERROR([*** unknown stage1 flavor "$1" $2])])])

dnl RKT_IF_HAS_FLAVOR checks if the comma-separated list of flavors in
dnl $1 contains any flavor in the comma-separated list of flavors in
dnl $2; if yes, executes $3, otherwise - $4.
AC_DEFUN([RKT_IF_HAS_FLAVOR],
         [flavor_found=0
          RKT_ITERATE_FLAVORS([$2],[flavor],
                              [AS_IF([AS_ECHO([",$1,"]) | grep --silent ",${flavor},"],
                                     [flavor_found=1
                                      break])])
          AS_IF([test ${flavor_found} -eq 1],[:;$3],[:;$4])])

dnl Validate passed flavors to build - make sure that valid flavors
dnl were passed and each flavor was specified only once. Also, do some
dnl basic program checks for each requested flavor.
RKT_SPECIFIED_FLAVORS=''
RKT_ITERATE_FLAVORS([${RKT_STAGE1_FLAVORS}],[flavor],
                    [RKT_IS_VALID_FLAVOR([${flavor}],[in --with-stage1-flavors])
                     RKT_IF_HAS_FLAVOR([${RKT_SPECIFIED_FLAVORS}],[${flavor}],
                                       [AC_MSG_ERROR([*** "${flavor}" flavor specified twice in --with-stage1-flavors])])
                     RKT_SPECIFIED_FLAVORS="${RKT_SPECIFIED_FLAVORS},${flavor}"
                     AS_CASE([${flavor}],
                             [src],
                                     [RKT_REQ_PROG([INTLTOOLIZE],[intltoolize],[intltoolize])
                                      RKT_REQ_PROG([LIBTOOLIZE],[libtoolize],[libtoolize])],
                             [coreos],
                                     [RKT_REQ_PROG([WGET],[wget],[wget])
                                      RKT_REQ_PROG([MKTEMP],[mktemp],[mktemp])
                                      RKT_REQ_PROG([MD5SUM],[md5sum],[md5sum])
                                      RKT_REQ_PROG([CPIO],[cpio],[cpio])
                                      RKT_REQ_PROG([GZIP],[gzip],[gzip])
                                      RKT_REQ_PROG([UNSQUASHFS],[unsquashfs],[unsquashfs])
                                      RKT_REQ_PROG([SORT],[sort],[sort])],
                             [kvm],
                                     [AC_MSG_WARN([* kvm is an experimental stage1 implementation, some features are missing])],
                             [host],
                                     [],
                             [AC_MSG_ERROR([*** Unhandled flavor "${flavor}", should not happen])])])

dnl Validate passed default flavor, it should be one of the built
dnl stage1 flavors

AS_VAR_IF([RKT_STAGE1_SETUP_KIND],['flavor'],
          [RKT_IS_VALID_FLAVOR([${RKT_STAGE1_DEFAULT_FLAVOR}],[in --with-stage1-default-flavor])
           RKT_IF_HAS_FLAVOR([${RKT_STAGE1_FLAVORS}],[${RKT_STAGE1_DEFAULT_FLAVOR}],
                             dnl valid default flavor, alright
                             [],
                             dnl not a part of built flavors, bail out
                             [AC_MSG_ERROR([*** --with-stage1-default-flavor should use one of flavors from --with-stage1-flavors (${RKT_STAGE1_FLAVORS})])])])

## Options specific for src flavor

# Process systemd src repo and version for src flavor.
RKT_IF_HAS_FLAVOR([${RKT_STAGE1_FLAVORS}],[src],
                  dnl we are building src flavor
                  [AS_VAR_IF([RKT_STAGE1_SYSTEMD_SRC], [auto],
                             dnl systemd source not specified, use default
                             [RKT_STAGE1_SYSTEMD_SRC='https://github.com/systemd/systemd.git'],
                             dnl systemd source specified, use it
                             [:])
                   AS_VAR_IF([RKT_STAGE1_SYSTEMD_VER], [auto],
                             dnl systemd version not specified, use default
                             [RKT_STAGE1_SYSTEMD_VER='v222'],
                             dnl systemd version specified, use it
                             [:])],
                  dnl we are not building src flavor
                  [AS_VAR_IF([RKT_STAGE1_SYSTEMD_SRC], [auto],
                             dnl systemd source not specified, alright, zero the value just in case
                             [RKT_STAGE1_SYSTEMD_SRC=''],
                             dnl systemd source specified, warn about it being ignored
                             [AC_MSG_WARN([* --with-stage1-systemd-src is ignored, src flavor is not built])])
                   AS_VAR_IF([RKT_STAGE1_SYSTEMD_VER], [auto],
                             dnl systemd version not specified, alright, zero the value just in case
                             [RKT_STAGE1_SYSTEMD_VER=''],
                             dnl systemd version specified, warn about it being ignored
                             [AC_MSG_WARN([* --with-stage1-systemd-version is ignored, src flavor is not built])])])

dnl Warn if version is HEAD, just use master.
AS_VAR_IF([RKT_STAGE1_SYSTEMD_VER], [HEAD],
          [AC_MSG_WARN([* 'HEAD' is not a systemd version, setting it to 'master' instead])
           RKT_STAGE1_SYSTEMD_VER='master'])

## Options specific to coreos/kvm flavors

# Process local CoreOS PXE image path and its systemd version for
# coreos/kvm flavors.
RKT_IF_HAS_FLAVOR([${RKT_STAGE1_FLAVORS}],[coreos,kvm],
                  dnl for kvm and coreos check if both pxe image path and
                  dnl systemd version are specified or neither
                  [AS_VAR_IF([RKT_LOCAL_COREOS_PXE_IMAGE_PATH], [],
                             dnl no local coreos pxe image path specified
                             [AS_VAR_IF([RKT_LOCAL_COREOS_PXE_IMAGE_SYSTEMD_VER],[],
                                        dnl no version specified, alright, keep quiet
                                        [:],
                                        dnl version specified, warn about it being ignored
                                        [AC_MSG_WARN([* --with-coreos-local-pxe-image-systemd-version is ignored, because --with-coreos-local-pxe-image-path was not specified])
                                         RKT_LOCAL_COREOS_PXE_IMAGE_SYSTEMD_VER=''])
                              dnl gpg is required for signature
                              dnl verification
                              RKT_REQ_PROG([GPG],[gpg],[gpg])],
                             dnl local coreos pxe image path specified
                             [AS_VAR_IF([RKT_LOCAL_COREOS_PXE_IMAGE_SYSTEMD_VER],[],
                                        dnl no version specified, bail out, version is required
                                        [AC_MSG_ERROR([*** No systemd version for local CoreOS PXE image specified, use --with-coreos-local-pxe-image-systemd-version])],
                                        dnl version specified, alright, keep quiet
                                        [:])])],
                  dnl for other flavors just warn if either is specified
                  [AS_VAR_IF([RKT_LOCAL_COREOS_PXE_IMAGE_PATH], [],
                             dnl empty value, alright
                             [:],
                             dnl not empty, warn about it, zero it just in case
                             [AC_MSG_WARN([* --with-coreos-local-pxe-image-path is ignored by ${RKT_STAGE1_DEFAULT_FLAVOR} stage1 flavor])
                              RKT_LOCAL_COREOS_PXE_IMAGE_PATH=''])
                   AS_VAR_IF([RKT_LOCAL_COREOS_PXE_IMAGE_SYSTEMD_VER], [],
                             dnl empty value, alright
                             [:],
                             dnl not empty, warn about it, zero it just in case
                             [AC_MSG_WARN([* --with-coreos-local-pxe-image-systemd-version is ignored by ${RKT_STAGE1_DEFAULT_FLAVOR} stage1 flavor])
                              RKT_LOCAL_COREOS_PXE_IMAGE_SYSTEMD_VER=''])])

## Setup default name, version and location

AS_CASE([${RKT_STAGE1_SETUP_KIND}],
        [detailed],
                  dnl detailed setup - not much to do, default name
                  dnl and version are already specified, warn if
                  dnl default location was not specified
                  [AS_VAR_IF([RKT_STAGE1_DEFAULT_LOCATION],[auto],
                             [RKT_STAGE1_DEFAULT_LOCATION=''])
                   AC_MSG_WARN([* It may be necessary to pass --stage1-image flag to run rkt])],
        [flavor],
                  dnl flavor setup - set the default name and version,
                  dnl set the location if not specified
                  [AS_CASE([${RKT_STAGE1_DEFAULT_FLAVOR}],
                                   dnl for src flavor, we also append systemd version to stage1 name
                                   [src],
                                           [RKT_STAGE1_DEFAULT_NAME="coreos.com/rkt/stage1-${RKT_STAGE1_DEFAULT_FLAVOR}-${RKT_STAGE1_SYSTEMD_VER}"],
                                   dnl other flavors get only flavor name
                                   [RKT_STAGE1_DEFAULT_NAME="coreos.com/rkt/stage1-${RKT_STAGE1_DEFAULT_FLAVOR}"])
                   RKT_STAGE1_DEFAULT_VERSION="${RKT_VERSION}"
                   AS_VAR_IF([RKT_STAGE1_DEFAULT_LOCATION],[auto],
                             [RKT_STAGE1_DEFAULT_LOCATION="path/stage1-${RKT_STAGE1_DEFAULT_FLAVOR}.aci"])],
        [AC_MSG_ERROR([*** Unknown setup kind, should not happen])])

## Functional tests

dnl Check for gpg - required by functional tests. Note that this does
dnl not bail out here if it is not found.
RKT_CHECK_PROG([GPG],[gpg],[gpg])

AS_IF([test "x${RKT_RUN_FUNCTIONAL_TESTS}" = 'xyes' -o "x${RKT_RUN_FUNCTIONAL_TESTS}" = 'xauto'],
      [AC_MSG_CHECKING([whether functional tests can be run])
       rkt_functional_tests_msg=''
       AS_CASE([${host}],
               [*-*-linux*],
                       dnl we are on linux, checks can continue
                       [],
               dnl non-linux host
               [rkt_functional_tests_msg="functional tests are supported only under linux"])
      AS_VAR_IF([rkt_functional_tests_msg],[],
                dnl we are on linux host; check if we have default
                dnl flavor set
                [AS_VAR_IF([RKT_STAGE1_SETUP_KIND],[flavor],
                           dnl we have flavor setup, checks can
                           dnl continue
                           [:],
                           [rkt_functional_tests_msg='Currently functional tests cannot be run on 3rd party stage1 images'])])
      AS_VAR_IF([rkt_functional_tests_msg],[],
                dnl we have a default flavor, check some special
                dnl prerequisites for host flavor
                [AS_VAR_IF([RKT_STAGE1_DEFAULT_FLAVOR], [host],
                           dnl checking if we are running systemd as init, -.mount is a mount unit for /.
                           [AS_IF([systemctl 2>/dev/null | grep --silent -e '-\.mount'],
                                  dnl systemd runs as init
                                  [sdv=`systemctl --version | head -1 | sed -e 's/^systemd \(@<:@0-9@:>@*\)$/\1/'`
                                   AS_IF([test ${sdv} -lt 220],
                                         [rkt_functional_tests_msg="Cannot run functional tests with ${RKT_STAGE1_DEFAULT_FLAVOR} stage1 flavor - systemd version on host is lower than 220 (currently running ${sdv})"])],
                                  dnl systemd is not an init
                                  [rkt_functional_tests_msg="Cannot run functional tests with ${RKT_STAGE1_DEFAULT_FLAVOR} stage1 flavor - no systemd on host"])])])
      dnl gpg is required for functional tests
      AS_VAR_IF([GPG],[gpg],
                dnl gpg found, alright
                [:],
                dnl gpg not found, running functional tests is impossible
                [rkt_functional_tests_msg="Cannot run functional tests - no gpg found"])
      AS_VAR_IF([rkt_functional_tests_msg], [],
                 dnl no message, tests can be run
                 [RKT_RUN_FUNCTIONAL_TESTS=yes
                  AC_MSG_RESULT([yes])],
                 dnl message available, tests will not be run
                 [AC_MSG_RESULT([no])
                  AS_VAR_IF([RKT_RUN_FUNCTIONAL_TESTS], [auto],
                            dnl functional tests are optional, so only print an info
                            [RKT_RUN_FUNCTIONAL_TESTS=no
                             AC_MSG_NOTICE([${rkt_functional_tests_msg}])],
                            dnl functional tests are required, so bail out
                            [AC_MSG_ERROR([*** ${rkt_functional_tests_msg}])])])])


## Miscellaneous stuff

# cross_compiling is a standard autoconf variable.  See the autoconf manual for
# details.
AS_VAR_IF([cross_compiling], [no],
          dnl no crosscompilation
          [GOARCH_FOR_BUILD=${GOARCH_FOR_BUILD:-${GOARCH}}],
          dnl we do crosscompilation
          [AC_MSG_CHECKING([build golang arch])
           AS_VAR_IF([GOARCH_FOR_BUILD], [],
                     [AS_CASE([${build_cpu}],
                              [x86_64],
                                      [GOARCH_FOR_BUILD="amd64"],
                              [aarch64],
                                      [GOARCH_FOR_BUILD="arm64"],
                              [powerpc],
                                      [GOARCH_FOR_BUILD="ppc64"],
                              [AC_MSG_RESULT([unknown]); AC_MSG_ERROR([*** Unknown build cpu: ${build_cpu}.  Set GOARCH_FOR_BUILD variable.])])
                      AC_MSG_RESULT([${GOARCH_FOR_BUILD}])],
                     [AC_MSG_RESULT([user supplied ${GOARCH_FOR_BUILD}])])])

AC_PROG_CC

AC_LANG_PUSH([C])

# check for libc generally
AC_CHECK_LIB([c], [fork],
             dnl libc is there
             [:],
             dnl libc is not there
             [AC_MSG_ERROR([*** No libc found. Try to install glibc-devel or libc6-dev.])])

# check for static libc
SAVE_LDFLAGS="$LDFLAGS"
LDFLAGS="-static $LDFLAGS"
AC_CHECK_LIB([c], [printf],
             dnl static libc is there
             [:],
             dnl static libc is not there
             [AC_MSG_ERROR([*** No static libc found. Try to install glibc-static or libc6-dev.])])
LDFLAGS="$SAVE_LDFLAGS"

# check for setns syscall, drop it in 2020 (centos 6.7 support ends
# then).

AC_MSG_CHECKING([whether C library provides setns function])
AC_LINK_IFELSE([AC_LANG_PROGRAM([[
                                  #define _GNU_SOURCE
                                  #include <sched.h>
                                ]], [[(void)setns(0, 0);]])],
               [AC_MSG_RESULT([yes])],
               [AC_MSG_RESULT([no])
                AC_MSG_CHECKING([whether Linux kernel headers provide __NR_setns macro])
                AC_LINK_IFELSE([AC_LANG_PROGRAM([[
                                                  #include <linux/unistd.h>
                                                ]], [[(void)syscall(__NR_setns,0,0);]])],
                               [AC_MSG_RESULT([yes])
                                RKT_DEFINES_FOR_ENTER=-DNO_SETNS_AVAILABLE],
                               [AC_MSG_RESULT([no])
                                AC_MSG_ERROR([*** Neither setns function nor __NR_setns macro are available - either both glibc and kernel are too old or their development headers are not installed])])])

AC_SUBST(RKT_DEFINES_FOR_ENTER)

AC_LANG_POP([C])

AC_PROG_INSTALL
RKT_REQ_PROG([FILE],[file],[file])
RKT_REQ_PROG([GIT],[git],[git])
RKT_REQ_PROG([GOBINARY],[go],[go])
RKT_REQ_PROG([GOFMTBINARY],[gofmt],[gofmt])
RKT_REQ_ABS_PROG([ABS_GO], [go])

#### LINKER FLAGS

dnl Detect go version. Go 1.4 and earlier support only "-X variable
dnl 'value'" format of assigning values to variables via linker
dnl flags. Go 1.5 deprecates this format in favor of "-X
dnl 'variable=value'" format. Drop this ugliness when we drop support
dnl for Go older than 1.5.
GO_VERSION=`$ABS_GO version | grep -o 'go@<:@@<:@:digit:@:>@@:>@\+\.@<:@@<:@:digit:@:>@@:>@\+' | grep -o '@<:@@<:@:digit:@:>@@:>@\+\.@<:@@<:@:digit:@:>@@:>@\+'`
GO_MAJOR=`echo $GO_VERSION | grep -o '^@<:@@<:@:digit:@:>@@:>@\+'`
GO_MINOR=`echo $GO_VERSION | grep -o '@<:@@<:@:digit:@:>@@:>@\+$'`

AS_IF([test $GO_MAJOR -gt 1 -o $GO_MINOR -gt 4],
      dnl We have Go 1.5 or greater.
      [RKT_XF() {
           echo "-X '$1=$2'"
       }],
      dnl We have Go 1.4 or lesser.
      [RKT_XF() {
           echo "-X $1 '$2'"
       }])

RKT_STAGE1_DEFAULT_NAME_LDFLAGS=`RKT_XF main.defaultStage1Name "${RKT_STAGE1_DEFAULT_NAME}"`
RKT_STAGE1_DEFAULT_VERSION_LDFLAGS=`RKT_XF main.defaultStage1Version "${RKT_STAGE1_DEFAULT_VERSION}"`
RKT_STAGE1_DEFAULT_LOCATION_LDFLAGS=`RKT_XF main.defaultStage1Image "${RKT_STAGE1_DEFAULT_LOCATION}"`
RKT_VERSION_LDFLAGS=`RKT_XF github.com/coreos/rkt/version.Version "${RKT_VERSION}"`

#### SUBSTITUTIONS

AC_SUBST(RKT_VERSION)

AC_SUBST(RKT_STAGE1_DEFAULT_NAME)
AC_SUBST(RKT_STAGE1_DEFAULT_VERSION)

AC_SUBST(RKT_STAGE1_FLAVORS)
AC_SUBST(RKT_STAGE1_DEFAULT_FLAVOR)

AC_SUBST(RKT_STAGE1_DEFAULT_LOCATION)

AC_SUBST(RKT_STAGE1_SYSTEMD_SRC)
AC_SUBST(RKT_STAGE1_SYSTEMD_VER)

AC_SUBST(RKT_LOCAL_COREOS_PXE_IMAGE_PATH)
AC_SUBST(RKT_LOCAL_COREOS_PXE_IMAGE_SYSTEMD_VER)

AC_SUBST(RKT_RUN_FUNCTIONAL_TESTS)

AC_SUBST(GOARCH_FOR_BUILD)

AC_SUBST(RKT_STAGE1_DEFAULT_NAME_LDFLAGS)
AC_SUBST(RKT_STAGE1_DEFAULT_VERSION_LDFLAGS)
AC_SUBST(RKT_STAGE1_DEFAULT_LOCATION_LDFLAGS)
AC_SUBST(RKT_VERSION_LDFLAGS)

#### FILE GENERATION AND REPORTING

AC_CONFIG_FILES([makelib/variables.mk])
AC_OUTPUT

AC_MSG_RESULT([
        AC_PACKAGE_NAME ${RKT_VERSION}

        stage1 setup

        type:                                   '${RKT_STAGE1_SETUP_KIND}'
        default stage1 location:                '${RKT_STAGE1_DEFAULT_LOCATION}'])

AS_CASE([${RKT_STAGE1_SETUP_KIND}],
        [flavor],
                [AC_MSG_RESULT([
        built stage1 flavors:                   '${RKT_STAGE1_FLAVORS}'
        default stage1 flavor:                  '${RKT_STAGE1_DEFAULT_FLAVOR}'
        implied default stage1 name:            '${RKT_STAGE1_DEFAULT_NAME}'
        implied default stage1 version:         '${RKT_STAGE1_DEFAULT_VERSION}'])],
        [detailed],
                [AC_MSG_RESULT([
        default stage1 name:                    '${RKT_STAGE1_DEFAULT_NAME}'
        default stage1 version:                 '${RKT_STAGE1_DEFAULT_VERSION}'])],
        [AC_MSG_ERROR([*** Unknown setup kind, should not happen])])

RKT_IF_HAS_FLAVOR([${RKT_STAGE1_FLAVORS}], [coreos,kvm],
                  [AC_MSG_RESULT([
        coreos/kvm flavor specific build parameters

        local CoreOS PXE image path:            '${RKT_LOCAL_COREOS_PXE_IMAGE_PATH}'
        local CoreOS PXE image systemd version: '${RKT_LOCAL_COREOS_PXE_IMAGE_SYSTEMD_VER}'])])

RKT_IF_HAS_FLAVOR([${RKT_STAGE1_FLAVORS}], [src],
                  [AC_MSG_RESULT([
        src flavor specific build parameters

        systemd git repo:                       '${RKT_STAGE1_SYSTEMD_SRC}'
        systemd version:                        '${RKT_STAGE1_SYSTEMD_VER}'])])

AC_MSG_RESULT([
        other build parameters

        functional tests enabled:               '${RKT_RUN_FUNCTIONAL_TESTS}'
        go version:                             '${GO_VERSION}'])
