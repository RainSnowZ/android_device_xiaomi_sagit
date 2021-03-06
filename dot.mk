$(call inherit-product, device/xiaomi/sagit/full_sagit.mk)

# Inherit some common Dot stuff.
$(call inherit-product, vendor/dot/config/common_full_phone.mk)

PRODUCT_NAME := dot_sagit
PRODUCT_DEVICE := sagit
PRODUCT_BRAND := Xiaomi
PRODUCT_MODEL := MI 6
PRODUCT_MANUFACTURER := Xiaomi

PRODUCT_GMS_CLIENTID_BASE := android-xiaomi

PRODUCT_BUILD_PROP_OVERRIDES += \
    BUILD_FINGERPRINT="Xiaomi/sagit/sagit:7.1.1/NMF26X/7.11.23:user/release-keys"

# DotExports

WITH_MAGISK := true
DOT_BUILDTYPE := UNOFFICIAL
