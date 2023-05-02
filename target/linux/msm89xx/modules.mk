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

define KernelPackage/qcom-modem
  SUBMENU:=$(OTHER_MENU)
  TITLE:=Qualcomm modem remoteproc support
  DEPENDS:=@TARGET_msm89xx +kmod-qcom-remoteproc
  KCONFIG:=\
         CONFIG_QCOM_Q6V5_COMMON \
         CONFIG_QCOM_Q6V5_MSS
  FILES:=\
         $(LINUX_DIR)/drivers/remoteproc/qcom_q6v5.ko \
         $(LINUX_DIR)/drivers/remoteproc/qcom_q6v5_mss.ko
  AUTOLOAD:=$(call AutoProbe,qcom_q6v5 qcom_q6v5_mss)
endef

define KernelPackage/qcom-modem/description
  Firmware loading and control for the modem remoteproc.
endef

$(eval $(call KernelPackage,qcom-modem))

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

# Note : 
# (1) need userspace daemon (q6voiced) when kmod-qcom-modem is selected.
# (2) apq8016 is also supported
#
define KernelPackage/sound-qcom-msm8916
  TITLE:=Qualcomm msm8916 built-in SoC sound support
  DEPENDS:=@TARGET_msm89xx +kmod-sound-soc-core +kmod-qcom-remoteproc
  KCONFIG:= \
         CONFIG_SND_SOC_QCOM \
         CONFIG_SND_SOC_STORM=n \
         CONFIG_SND_SOC_AW8738=n \
         CONFIG_SND_SOC_TFA989X=n \
         CONFIG_SND_SOC_MSM8996=n \
         CONFIG_SND_SOC_APQ8016_SBC \
         CONFIG_SND_SOC_QDSP6_Q6VOICE \
         CONFIG_SND_SOC_MSM8916_QDSP6 \
         CONFIG_SND_SOC_MAX98357A \
         CONFIG_SND_SOC_MSM8916_WCD_ANALOG \
         CONFIG_SND_SOC_MSM8916_WCD_DIGITAL \
         CONFIG_SND_SOC_SIMPLE_AMPLIFIER \
         CONFIG_QCOM_APR
  FILES:= \
         $(LINUX_DIR)/sound/soc/qcom/snd-soc-qcom-common.ko \
         $(LINUX_DIR)/drivers/soc/qcom/apr.ko \
         $(LINUX_DIR)/sound/soc/qcom/snd-soc-apq8016-sbc.ko \
         $(LINUX_DIR)/sound/soc/qcom/snd-soc-msm8916-qdsp6.ko \
         $(LINUX_DIR)/sound/soc/codecs/snd-soc-msm8916-analog.ko \
         $(LINUX_DIR)/sound/soc/codecs/snd-soc-msm8916-digital.ko \
         $(LINUX_DIR)/sound/soc/codecs/snd-soc-max98357a.ko \
         $(LINUX_DIR)/sound/soc/codecs/snd-soc-simple-amplifier.ko \
         $(LINUX_DIR)/sound/soc/qcom/qdsp6/q6voice.ko \
         $(LINUX_DIR)/sound/soc/qcom/qdsp6/q6adm.ko \
         $(LINUX_DIR)/sound/soc/qcom/qdsp6/q6afe-clocks.ko \
         $(LINUX_DIR)/sound/soc/qcom/qdsp6/q6afe-dai.ko \
         $(LINUX_DIR)/sound/soc/qcom/qdsp6/q6afe.ko \
         $(LINUX_DIR)/sound/soc/qcom/qdsp6/q6asm-dai.ko \
         $(LINUX_DIR)/sound/soc/qcom/qdsp6/q6asm.ko \
         $(LINUX_DIR)/sound/soc/qcom/qdsp6/q6core.ko \
         $(LINUX_DIR)/sound/soc/qcom/qdsp6/q6cvp.ko \
         $(LINUX_DIR)/sound/soc/qcom/qdsp6/q6cvs.ko \
         $(LINUX_DIR)/sound/soc/qcom/qdsp6/q6dsp-common.ko \
         $(LINUX_DIR)/sound/soc/qcom/qdsp6/q6mvm.ko \
         $(LINUX_DIR)/sound/soc/qcom/qdsp6/q6routing.ko \
         $(LINUX_DIR)/sound/soc/qcom/qdsp6/q6voice-common.ko \
         $(LINUX_DIR)/sound/soc/qcom/qdsp6/q6voice-dai.ko
  AUTOLOAD:=$(call AutoProbe,apr snd-soc-apq8016-sbc snd-soc-qcom-common snd-soc-msm8916-qdsp6 q6voice snd-soc-msm8916-analog snd-soc-msm8916-digital snd-soc-max98357a snd-soc-simple-amplifier)
  $(call AddDepends/sound)
endef

define KernelPackage/sound-qcom-msm8916/description
  Kernel support for Qualcomm msm8916 built-in SoC sound codec
endef

$(eval $(call KernelPackage,sound-qcom-msm8916))