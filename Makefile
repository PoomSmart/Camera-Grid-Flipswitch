PACKAGE_VERSION = 1.0.0
TARGET = iphone:clang:latest:11.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = CameraGridFS
CameraGridFS_FILES = Switch.xm
CameraGridFS_LIBRARIES = flipswitch
CameraGridFS_FRAMEWORKS = UIKit
CameraGridFS_INSTALL_PATH = /Library/Switches

include $(THEOS_MAKE_PATH)/bundle.mk
