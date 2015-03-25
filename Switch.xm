#import "FSSwitchDataSource.h"
#import "FSSwitchPanel.h"

NSString *const kGridKey = @"EnableGridLines";
NSString *const kSwitchIdentifier = @"com.PS.CameraGrid";
CFStringRef const CameraConfiguration = CFSTR("CameraConfiguration");
CFStringRef const MobileSlideShow = CFSTR("com.apple.mobileslideshow");
CFStringRef const kPostNotification = CFSTR("com.apple.mobileslideshow.PreferenceChanged");

@interface CameraGridSwitch : NSObject <FSSwitchDataSource>
@end

@implementation CameraGridSwitch

- (FSSwitchState)stateForSwitchIdentifier:(NSString *)switchIdentifier
{
	CFPreferencesAppSynchronize(MobileSlideShow);
	NSDictionary *cameraConfiguration = [(NSDictionary *)CFPreferencesCopyAppValue(CameraConfiguration, MobileSlideShow) autorelease];
	id value = cameraConfiguration[kGridKey];
	return [value boolValue] ? FSSwitchStateOn : FSSwitchStateOff;
}

- (void)applyState:(FSSwitchState)newState forSwitchIdentifier:(NSString *)switchIdentifier
{
	if (newState == FSSwitchStateIndeterminate)
		return;
	NSDictionary *cameraConfiguration = [(NSDictionary *)CFPreferencesCopyAppValue(CameraConfiguration, MobileSlideShow) autorelease];
	NSMutableDictionary *mutableCameraConfiguration = [cameraConfiguration.mutableCopy autorelease];
	mutableCameraConfiguration[kGridKey] = @(newState == FSSwitchStateOn);
	NSDictionary *editedCameraConfiguration = [mutableCameraConfiguration.copy autorelease];
	CFPreferencesSetAppValue(CameraConfiguration, editedCameraConfiguration, MobileSlideShow);
	CFPreferencesAppSynchronize(MobileSlideShow);
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), kPostNotification, NULL, NULL, YES);
}

@end

static void PreferencesChanged()
{
	[[FSSwitchPanel sharedPanel] stateDidChangeForSwitchIdentifier:kSwitchIdentifier];
}

__attribute__((constructor)) static void init()
{
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)PreferencesChanged, kPostNotification, NULL, CFNotificationSuspensionBehaviorCoalesce);
}