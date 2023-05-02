# SPDX-License-Identifier: GPL-2.0-only

define KernelPackage/qcom-bluetooth
    SUBMENU:=$(OTHER_MENU)
    TITLE:=Qualcomm SoC built-in bluetooth support
    DEPENDS:=@TARGET_msm89xx +kmod-bluetooth +kmod-qcom-wcnss
    KCONFIG:= \
         CONFIG_BT_QCOMSMD \
         CONFIG_BT_HCIUART_QCA=y \
         CONFIG_INPUT_PM8941_PWRKEY=n \
         CONFIG_INPUT_PM8XXX_VIBRATOR=n
    FILES:= $(LINUX_DIR)/drivers/bluetooth/btqcomsmd.ko
    AUTOLOAD:=$(call AutoLoad,50,btqcomsmd)
endef

define KernelPackage/qcom-bluetooth/description
 Support for the Qualcomm SoC's bluetooth
endef

$(eval $(call KernelPackage,qcom-bluetooth))

define KernelPackage/qcom-wcnss
  SUBMENU:=$(NETWORK_DEVICES_MENU)
  TITLE:=Qualcomm wireless connectivity subsystem support
  DEPENDS:=@TARGET_msm89xx +kmod-qcom-remoteproc
  KCONFIG:= \
         CONFIG_QCOM_WCNSS_PIL \
         CONFIG_QCOM_WCNSS_CTRL
  FILES:= \
         $(LINUX_DIR)/drivers/remoteproc/qcom_wcnss_pil.ko \
         $(LINUX_DIR)/drivers/soc/qcom/wcnss_ctrl.ko
  AUTOLOAD:=$(call AutoLoad,50,wcnss_ctrl qcom_wcnss_pil)
endef

$(eval $(call KernelPackage,qcom-wcnss))

define KernelPackage/qcom-remoteproc
  SUBMENU:=$(OTHER_MENU)
  TITLE:=Qualcomm remoteproc support
  DEPENDS:=@TARGET_msm89xx +kmod-dma-buf
  KCONFIG:= \
         CONFIG_QCOM_PIL_INFO \
         CONFIG_RPMSG_QCOM_GLINK \
         CONFIG_RPMSG_QCOM_GLINK_SMEM \
         CONFIG_QCOM_MEMSHARE_QMI_SERVICE \
         CONFIG_QCOM_SYSMON \
         CONFIG_QCOM_FASTRPC \
         CONFIG_QCOM_QMI_HELPERS \
         CONFIG_QCOM_PDR_HELPERS \
         CONFIG_QCOM_RPROC_COMMON \
         CONFIG_QCOM_MDT_LOADER \
         CONFIG_QRTR \
         CONFIG_QRTR_SMD \
         CONFIG_QRTR_TUN
  FILES:= \
         $(LINUX_DIR)/drivers/soc/qcom/mdt_loader.ko \
         $(LINUX_DIR)/drivers/soc/qcom/qmi_helpers.ko \
         $(LINUX_DIR)/drivers/remoteproc/qcom_common.ko \
         $(LINUX_DIR)/drivers/remoteproc/qcom_pil_info.ko \
         $(LINUX_DIR)/drivers/remoteproc/qcom_sysmon.ko \
         $(LINUX_DIR)/drivers/rpmsg/qcom_glink.ko \
         $(LINUX_DIR)/drivers/rpmsg/qcom_glink_smem.ko \
         $(LINUX_DIR)/drivers/misc/fastrpc.ko \
         $(LINUX_DIR)/net/qrtr/qrtr.ko \
         $(LINUX_DIR)/net/qrtr/ns.ko@lt6.0 \
         $(LINUX_DIR)/net/qrtr/qrtr-smd.ko \
         $(LINUX_DIR)/net/qrtr/qrtr-tun.ko
  AUTOLOAD:=$(call AutoLoad,20,qcom_common qcom_pil_info qcom_sysmon mdt_loader qcom_memshare qrtr ns qrtr-smd qrtr-tun fastrpc qcom_glink qcom_glink_smem qmi_helpers)
  ifneq ($(wildcard $(LINUX_DIR)/drivers/soc/qcom/pdr_interface.ko),)
         FILES += $(LINUX_DIR)/drivers/soc/qcom/pdr_interface.ko
         AUTOLOAD += $(call AutoLoad,20,pdr_interface)
  endif
endef

$(eval $(call KernelPackage,qcom-remoteproc))

