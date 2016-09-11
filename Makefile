THEOS_DEVICE_IP = YouriphoneIp
ARCHS = armv7 arm64
TARGET = iphone:latest:8.0
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = WeChatBomb
WeChatBomb_FILES = Tweak.xm
WeChatBomb_FRAMEWORKS = UIKit
include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall WeChat”
