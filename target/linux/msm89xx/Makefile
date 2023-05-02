# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

BOARD:=msm89xx
BOARDNAME:=Boards based on Snapdragon 410 chipsets
FEATURES:=ext4 usb usbgadget gpio fpu rootfs-part boot-part squashfs
SUBTARGETS:=msm8916
ARCH:=aarch64

KERNEL_PATCHVER:=6.1

define Target/Description
	Build firmware images for various Snapdragon 410 based devices
endef

include $(INCLUDE_DIR)/target.mk

DEFAULT_PACKAGES += partx-utils e2fsprogs mkf2fs
DEFAULT_PACKAGES += kmod-usb-chipidea kmod-usb-gadget-eth
DEFAULT_PACKAGES += kmod-rpmsg-wwan-ctrl kmod-bam-dmux
DEFAULT_PACKAGES += kmod-qcom-remoteproc kmod-qcom-wcnss kmod-qcom-bluetooth kmod-wcn36xx

KERNELNAME:=Image

$(eval $(call BuildTarget))
