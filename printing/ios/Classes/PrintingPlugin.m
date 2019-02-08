#import "PrintingPlugin.h"
#import <printing/printing-Swift.h>

@implementation PrintingPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPrintingPlugin registerWithRegistrar:registrar];
}
@end
