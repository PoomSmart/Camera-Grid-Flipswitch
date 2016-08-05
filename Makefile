DEBUG = 0
PACKAGE_VERSION = 0.0.2

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = CameraGrid
CameraGrid_FILES = Switch.xm
CameraGrid_LIBRARIES = flipswitch
CameraGrid_FRAMEWORKS = UIKit
CameraGrid_INSTALL_PATH = /Library/Switches

include $(THEOS_MAKE_PATH)/bundle.mk