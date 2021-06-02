#import <Flipswitch/FSSwitchDataSource.h>
#import <Flipswitch/FSSwitchPanel.h>
#import "../PS.h"

NSString *const kGridKey = isiOS9Up ? @"CAMUserPreferenceShowGridOverlay" : @"EnableGridLines";
NSString *const kSwitchIdentifier = @"com.PS.CameraGrid";
CFStringRef const CameraConfiguration = CFSTR("CameraConfiguration");
CFStringRef const Domain = isiOS9Up ? CFSTR("com.apple.camera") : CFSTR("com.apple.mobileslideshow");
CFStringRef const kPostNotification = CFSTR("com.apple.mobileslideShow.PreferenceChanged");

@interface CameraGridSwitch : NSObject <FSSwitchDataSource>
@end

static void PreferencesChanged()
{
	[[FSSwitchPanel sharedPanel] stateDidChangeForSwitchIdentifier:kSwitchIdentifier];
}

@implementation CameraGridSwitch

- (id)init
{
    if (self == [super init] && !isiOS9Up)
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)PreferencesChanged, kPostNotification, NULL, CFNotificationSuspensionBehaviorCoalesce);
    return self;
}

- (void)dealloc
{
	if (!isiOS9Up)
		CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, kPostNotification, NULL);
	[super dealloc];
}

- (FSSwitchState)stateForSwitchIdentifier:(NSString *)switchIdentifier
{
	CFPreferencesAppSynchronize(Domain);
	id value;
	if (isiOS9Up)
		value = [(id)CFPreferencesCopyAppValue((CFStringRef)kGridKey, Domain) autorelease];
	else {
		NSDictionary *cameraConfiguration = [(NSDictionary *)CFPreferencesCopyAppValue(CameraConfiguration, Domain) autorelease];
		value = cameraConfiguration[kGridKey];
	}
	return [value boolValue] ? FSSwitchStateOn : FSSwitchStateOff;
}

- (void)applyState:(FSSwitchState)newState forSwitchIdentifier:(NSString *)switchIdentifier
{
	if (newState == FSSwitchStateIndeterminate)
		return;
	if (isiOS9Up) {
		CFPreferencesSetAppValue((CFStringRef)kGridKey, newState == FSSwitchStateOn ? kCFBooleanTrue : kCFBooleanFalse, Domain);
		CFPreferencesAppSynchronize(Domain);
	}
	NSDictionary *cameraConfiguration = [(NSDictionary *)CFPreferencesCopyAppValue(CameraConfiguration, Domain) autorelease];
	NSMutableDictionary *mutableCameraConfiguration = [cameraConfiguration.mutableCopy autorelease];
	mutableCameraConfiguration[kGridKey] = @(newState == FSSwitchStateOn);
	NSDictionary *editedCameraConfiguration = [mutableCameraConfiguration.copy autorelease];
	CFPreferencesSetAppValue(CameraConfiguration, editedCameraConfiguration, Domain);
	CFPreferencesAppSynchronize(Domain);
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), kPostNotification, NULL, NULL, YES);
}

- (void)applyAlternateActionForSwitchIdentifier:(NSString *)switchIdentifier
{
	NSURL *url = [NSURL URLWithString:(kCFCoreFoundationVersionNumber >= 1443.0f ? @"prefs:root=CAMERA#CameraGridSwitch" : @"prefs:root=Photos#CameraGridSwitch")];
	[[FSSwitchPanel sharedPanel] openURLAsAlternateAction:url];
}

@end