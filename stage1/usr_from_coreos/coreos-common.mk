# Download or reuse the local image to get the squashfs file
# containing CoreOS. The path to the file is saved in CCN_SQUASHFS
# variable.

ifeq ($(_CCN_INCLUDED_),)

_CCN_INCLUDED_ := x

CCN_SYSTEMD_VERSION := "v222"
CCN_IMG_RELEASE := "794.1.0"
CCN_IMG_URL := "http://alpha.release.core-os.net/amd64-usr/$(CCN_IMG_RELEASE)/coreos_production_pxe_image.cpio.gz"

ifneq ($(RKT_LOCAL_COREOS_PXE_IMAGE_SYSTEMD_VER),)

CCN_SYSTEMD_VERSION := $(RKT_LOCAL_COREOS_PXE_IMAGE_SYSTEMD_VER)

endif

$(call setup-tmp-dir,CCN_TMPDIR)

CCN_SQUASHFS_BASE := usr.squashfs
CCN_SQUASHFS := $(CCN_TMPDIR)/$(CCN_SQUASHFS_BASE)
CCN_CACHE_SH := $(MK_SRCDIR)/cache.sh

ifneq ($(RKT_LOCAL_COREOS_PXE_IMAGE_PATH),)

# We are using local pxe.img

CCN_PXE := $(abspath $(RKT_LOCAL_COREOS_PXE_IMAGE_PATH))

else

# We are going to download pxe.img, so we need to clean it too.

CCN_PXE := $(CCN_TMPDIR)/pxe.img
CLEAN_FILES += \
	$(CCN_PXE) \
	$(CCN_PXE).$(firstword $(shell echo -n $(CCN_IMG_URL) | md5sum)).sig

endif

CLEAN_FILES += $(CCN_SQUASHFS)

$(call forward-vars,$(CCN_SQUASHFS), \
	CCN_TMPDIR CCN_PXE CCN_SQUASHFS_BASE)
$(CCN_SQUASHFS): $(CCN_PXE) | $(CCN_TMPDIR)
	$(VQ) \
	$(call vb,vt,EXTRACT,$(call vsp,$(CCN_PXE)) => $(call vsp,$@)) \
	cd "$(CCN_TMPDIR)" && gzip --to-stdout --decompress "$(CCN_PXE)" | cpio $(call vl3,--quiet )--unconditional --extract "$(CCN_SQUASHFS_BASE)"

ifeq ($(RKT_LOCAL_COREOS_PXE_IMAGE_PATH),)

$(call forward-vars,$(CCN_PXE), \
	CCN_TMPDIR CCN_IMG_URL BASH_SHELL CCN_CACHE_SH)
$(CCN_PXE): $(CCN_CACHE_SH) | $(CCN_TMPDIR)
	$(VQ) \
	ITMP="$(CCN_TMPDIR)" IMG_URL="$(CCN_IMG_URL)" V="$(V)" $(BASH_SHELL) $(CCN_CACHE_SH)

endif

# Excluding CCN_SQUASHFS because other will want to know where we
# placed the squashfs file, CCN_SYSTEMD_VERSION might be needed to
# create systemd-version file in ACI rootfs directory.
$(call undefine-namespaces,CCN,CCN_SQUASHFS CCN_SYSTEMD_VERSION)

endif
