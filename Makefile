TARGET=iphone:clang:latest:6.0
THEOS_DEVICE_PORT=22
GO_EASY_ON_ME=1
#ADDITIONAL_CFLAGS = -fobjc-arc

THEOS_BUILD_DIR = debs

include theos/makefiles/common.mk

LIBRARY_NAME = libDevelopersLib
libDevelopersLib_LOGOSFLAGS = -c generator=internal
libDevelopersLib_FILES = DevelopersLib.m $(wildcard Vendors/*.m) $(wildcard filebrowser/*.mm) $(wildcard filebrowser/*.c) $(wildcard filebrowser/*.m) $(wildcard MyColorPicker/*/*.m) $(wildcard MyColorPicker/*.m)
libDevelopersLib_FRAMEWORKS = SystemConfiguration MobileCoreServices AudioToolbox UIKit QuartzCore Social Foundation CoreGraphics AVFoundation MediaPlayer MobileCoreServices MessageUI Accounts AdSupport CoreImage CoreMedia Accelerate WebKit AssetsLibrary
libDevelopersLib_LIBRARIES = rocketbootstrap MobileGestalt z developerslibfb
libDevelopersLib_PRIVATE_FRAMEWORKS = AppSupport Preferences
libDevelopersLib_INSTALL_PATH = /usr/lib
# libDevelopersLib_BUNDLE_RESOURCE_DIRS = Resources

SUBPROJECTS += fbDaemon

include $(THEOS_MAKE_PATH)/library.mk
include $(THEOS_MAKE_PATH)/tool.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

before-package::
	sudo find $(THEOS_STAGING_DIR) -name "libDevelopersLib.dylib" -exec nahm8 {} \;
	sudo find $(THEOS_STAGING_DIR) -name "developerslibfb" -exec chown root:wheel {} \;
	sudo find $(THEOS_STAGING_DIR) -name "developerslibfb" -exec chmod 4777 {} \;
	sudo find $(THEOS_STAGING_DIR) -name "com.imokhles.developerslibfbdlaunch.plist" -exec chown root:wheel {} \;
	find $(THEOS_STAGING_DIR) -name "developerslibfbdlaunch" -exec chmod 755 {} \;
	sudo find $(THEOS_STAGING_DIR) -name "developerslibfb" -exec nahm8 {} \;
	sudo find $(THEOS_STAGING_DIR) -name "libdeveloperslibfb.dylib" -exec nahm8 {} \;

	$(ECHO_NOTHING)echo " Installing Library"$(ECHO_END)
	$(ECHO_NOTHING)sudo cp  $(THEOS_STAGING_DIR)/usr/lib/libDevelopersLib.dylib $(THEOS)/lib$(ECHO_END)
#	$(ECHO_NOTHING)sudo cp  $(THEOS_STAGING_DIR)/usr/lib/libimofilebrowser.dylib $(THEOS)/lib$(ECHO_END)
	$(ECHO_NOTHING)sudo cp -f DevelopersLib.h $(THEOS_STAGING_DIR)/usr/include/developerlib/DevelopersLib.h $(ECHO_END)
	$(ECHO_NOTHING)sudo cp -f filebrowser/DevLibFileBrowserViewController.h $(THEOS_STAGING_DIR)/usr/include/developerlib/filebrowser/DevLibFileBrowserViewController.h $(ECHO_END)
	$(ECHO_NOTHING)sudo cp -r -f $(THEOS_STAGING_DIR)/usr/include/developerlib/ $(THEOS)/include/developerlib/ $(ECHO_END)
	$(ECHO_NOTHING)echo " Library Installed"$(ECHO_END)
