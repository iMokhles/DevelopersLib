TARGET=iphone:clang:latest:6.0
THEOS_DEVICE_PORT=22
GO_EASY_ON_ME=1
export ARCHS = armv7 armv7s arm64

include theos/makefiles/common.mk

THEOS_BUILD_DIR = Packages

LIBRARY_NAME = libdeveloperslibfb
libdeveloperslibfb_LOGOSFLAGS = -c generator=internal
libdeveloperslibfb_FILES = DevLibClient.m
libdeveloperslibfb_CFLAGS = -I.
libdeveloperslibfb_LIBRARIES = rocketbootstrap
libdeveloperslibfb_PRIVATE_FRAMEWORKS = AppSupport
libdeveloperslibfb_INSTALL_PATH = /usr/lib

TOOL_NAME = developerslibfb
developerslibfb_FILES = DevLibServer.m DevLibDelegate.m
developerslibfb_FRAMEWORKS = Foundation CoreFoundation
developerslibfb_PRIVATE_FRAMEWORKS = AppSupport
developerslibfb_LIBRARIES = rocketbootstrap
developerslibfb_INSTALL_PATH = /usr/libexec

include $(THEOS_MAKE_PATH)/library.mk
include $(THEOS_MAKE_PATH)/tool.mk

before-package::
	sudo find _ -name "developerslibfb" -exec chown root:wheel {} \;
	sudo find _ -name "developerslibfb" -exec chmod 4777 {} \;
	sudo find _ -name "com.imokhles.developerslibfbdlaunch.plist" -exec chown root:wheel {} \;
	find _ -name "developerslibfbdlaunch" -exec chmod 755 {} \;
	sudo find $(THEOS_STAGING_DIR) -name "developerslibfb" -exec nahm8 {} \;
	sudo find $(THEOS_STAGING_DIR) -name "libdeveloperslibfb.dylib" -exec nahm8 {} \;
