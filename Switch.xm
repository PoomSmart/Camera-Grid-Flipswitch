#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <Flipswitch/FSSwitchDataSource.h>
#import <Flipswitch/FSSwitchPanel.h>
#import <version.h>

NSString *const kGridKey = @"CAMUserPreferenceShowGridOverlay";
CFStringRef const CameraConfiguration = CFSTR("CameraConfiguration");
CFStringRef const Domain = CFSTR("com.apple.camera");
CFStringRef const kPostNotification = CFSTR("com.apple.mobileslideShow.PreferenceChanged");

@interface CameraGridSwitch : NSObject <FSSwitchDataSource>
@end

@implementation CameraGridSwitch

- (FSSwitchState)stateForSwitchIdentifier:(NSString *)switchIdentifier {
	CFPreferencesAppSynchronize(Domain);
	id value = [(id)CFPreferencesCopyAppValue((CFStringRef)kGridKey, Domain) autorelease];
	return [value boolValue] ? FSSwitchStateOn : FSSwitchStateOff;
}

- (void)applyState:(FSSwitchState)newState forSwitchIdentifier:(NSString *)switchIdentifier {
	if (newState == FSSwitchStateIndeterminate)
		return;
	CFPreferencesSetAppValue((CFStringRef)kGridKey, newState == FSSwitchStateOn ? kCFBooleanTrue : kCFBooleanFalse, Domain);
	CFPreferencesAppSynchronize(Domain);
	NSDictionary *cameraConfiguration = [(NSDictionary *)CFPreferencesCopyAppValue(CameraConfiguration, Domain) autorelease];
	NSMutableDictionary *mutableCameraConfiguration = [cameraConfiguration.mutableCopy autorelease];
	mutableCameraConfiguration[kGridKey] = @(newState == FSSwitchStateOn);
	NSDictionary *editedCameraConfiguration = [mutableCameraConfiguration.copy autorelease];
	CFPreferencesSetAppValue(CameraConfiguration, editedCameraConfiguration, Domain);
	CFPreferencesAppSynchronize(Domain);
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), kPostNotification, NULL, NULL, YES);
}

- (void)applyAlternateActionForSwitchIdentifier:(NSString *)switchIdentifier {
	NSURL *url = [NSURL URLWithString:@"prefs:root=CAMERA#CameraGridSwitch"];
	[[FSSwitchPanel sharedPanel] openURLAsAlternateAction:url];
}

@end