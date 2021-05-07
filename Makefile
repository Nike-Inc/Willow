
usage:
	@echo "Read the Makefile for targets to run!"

SOURCES = Source/Info.plist \
					Source/LogLevel.swift \
					Source/LogMessage.swift \
					Source/LogMessageContext.swift \
					Source/LogModifier.swift \
					Source/LogWriter.swift \
					Source/Logger.swift \
					Source/Willow.h

PROJECT = Willow.xcodeproj

DEPS = Makefile $(PROJECT) $(SOURCES)

Willow.xcframework:	archives/ios_devices.xcarchive archives/ios_simulator.xcarchive archives/macos.xcarchive archives/appletvos.xcarchive archives/appletvsimulator.xcarchive archives/watchos.xcarchive archives/watchsimulator.xcarchive
	@-rm -rf Willow.xcframework
	xcodebuild \
		-create-xcframework \
		-framework archives/ios_devices.xcarchive/Products/Library/Frameworks/Willow.framework \
		-framework archives/ios_simulator.xcarchive/Products/Library/Frameworks/Willow.framework \
		-framework archives/appletvos.xcarchive/Products/Library/Frameworks/Willow.framework \
		-framework archives/appletvsimulator.xcarchive/Products/Library/Frameworks/Willow.framework \
		-framework archives/watchos.xcarchive/Products/Library/Frameworks/Willow.framework \
		-framework archives/watchsimulator.xcarchive/Products/Library/Frameworks/Willow.framework \
		-framework archives/macos.xcarchive/Products/Library/Frameworks/Willow.framework \
		-output $@

archives/ios_devices.xcarchive:	$(DEPS)
	xcodebuild archive -project $(PROJECT) -scheme "Willow iOS" -sdk iphoneos -archivePath "$@" BUILD_LIBRARY_FOR_DISTRIBUTION=YES SKIP_INSTALL=NO

archives/ios_simulator.xcarchive:	$(DEPS)
	xcodebuild archive -scheme "Willow iOS" -sdk iphonesimulator -archivePath "$@" BUILD_LIBRARY_FOR_DISTRIBUTION=YES SKIP_INSTALL=NO

archives/macos.xcarchive:	$(DEPS)
	xcodebuild archive -scheme "Willow macOS" -archivePath "$@" BUILD_LIBRARY_FOR_DISTRIBUTION=YES SKIP_INSTALL=NO

archives/appletvos.xcarchive:	$(DEPS)
	xcodebuild archive -scheme "Willow tvOS" -sdk appletvos -archivePath "$@" BUILD_LIBRARY_FOR_DISTRIBUTION=YES SKIP_INSTALL=NO

archives/appletvsimulator.xcarchive:	$(DEPS)
	xcodebuild archive -scheme "Willow tvOS" -sdk appletvsimulator -archivePath "$@" BUILD_LIBRARY_FOR_DISTRIBUTION=YES SKIP_INSTALL=NO

archives/watchos.xcarchive:	$(DEPS)
	xcodebuild archive -scheme "Willow watchOS" -sdk watchos -archivePath "$@" BUILD_LIBRARY_FOR_DISTRIBUTION=YES SKIP_INSTALL=NO

archives/watchsimulator.xcarchive:	$(DEPS)
	xcodebuild archive -scheme "Willow watchOS" -sdk watchsimulator -archivePath "$@" BUILD_LIBRARY_FOR_DISTRIBUTION=YES SKIP_INSTALL=NO

