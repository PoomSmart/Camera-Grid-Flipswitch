SDKVERSION = 7.0
ARCHS = armv7 arm64

include theos/makefiles/common.mk

BUNDLE_NAME = CameraGrid
CameraGrid_FILES = Switch.xm
CameraGrid_LIBRARIES = flipswitch
CameraGrid_FRAMEWORKS = UIKit
CameraGrid_INSTALL_PATH = /Library/Switches

include $(THEOS_MAKE_PATH)/bundle.mk
