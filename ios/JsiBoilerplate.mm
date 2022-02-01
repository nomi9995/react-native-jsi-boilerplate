#import "JsiBoilerplate.h"
#import "react-native-jsi-boilerplate.h"
#import <React/RCTBridge+Private.h>
#import <React/RCTUtils.h>
#import <jsi/jsi.h>
#import <sys/utsname.h>
#import "YeetJSIUtils.h"
#import <React/RCTBridge+Private.h>

using namespace facebook::jsi;
using namespace std;

@implementation JsiBoilerplate

@synthesize bridge = _bridge;
@synthesize methodQueue = _methodQueue;

RCT_EXPORT_MODULE()

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(install)
{
    RCTBridge* bridge = [RCTBridge currentBridge];
    RCTCxxBridge* cxxBridge = (RCTCxxBridge*)bridge;
    if (cxxBridge == nil) {
        return @false;
    }

    auto jsiRuntime = (jsi::Runtime*) cxxBridge.runtime;
    if (jsiRuntime == nil) {
        return @false;
    }
    auto& runtime = *jsiRuntime;

    example::install(*(Runtime *)&runtime);
    install(*(facebook::jsi::Runtime *)&runtime, self);
  
   
    return @true;
}


- (NSString *) getModel {
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

- (void) setItem:(NSString * )key :(NSString *)value {
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setObject:value forKey:key];
    [standardUserDefaults synchronize];
}

- (NSString *)getItem:(NSString *)key {
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    return [standardUserDefaults stringForKey:key];
}

static void install(jsi::Runtime &jsiRuntime, JsiBoilerplate *jsiBoilerplate) {
    auto getDeviceName = Function::createFromHostFunction(jsiRuntime,
                                                          PropNameID::forAscii(jsiRuntime,
                                                                               "getDeviceName"),
                                                          0,
                                                          [jsiBoilerplate](Runtime &runtime,
                                                                   const Value &thisValue,
                                                                   const Value *arguments,
                                                                   size_t count) -> Value {
        
        jsi::String deviceName = convertNSStringToJSIString(runtime, [jsiBoilerplate getModel]);
        
        return Value(runtime, deviceName);
    });
    
    jsiRuntime.global().setProperty(jsiRuntime, "getDeviceName", move(getDeviceName));
    
    auto setItem = Function::createFromHostFunction(jsiRuntime,
                                                        PropNameID::forAscii(jsiRuntime,
                                                                             "setItem"),
                                                        2,
                                                        [jsiBoilerplate](Runtime &runtime,
                                                                 const Value &thisValue,
                                                                 const Value *arguments,
                                                                 size_t count) -> Value {
            
            NSString *key = convertJSIStringToNSString(runtime, arguments[0].getString(runtime));
            NSString *value = convertJSIStringToNSString(runtime, arguments[1].getString(runtime));
            
            [jsiBoilerplate setItem:key :value];
            
            return Value(true);
        });
        
        jsiRuntime.global().setProperty(jsiRuntime, "setItem", move(setItem));
        
        
        auto getItem = Function::createFromHostFunction(jsiRuntime,
                                                        PropNameID::forAscii(jsiRuntime,
                                                                             "getItem"),
                                                        0,
                                                        [jsiBoilerplate](Runtime &runtime,
                                                                 const Value &thisValue,
                                                                 const Value *arguments,
                                                                 size_t count) -> Value {
            
            NSString *key = convertJSIStringToNSString(runtime, arguments[0].getString(runtime));
            
            NSString *value = [jsiBoilerplate getItem:key];
            
            return Value(runtime, convertNSStringToJSIString(runtime, value));
        });
        
        jsiRuntime.global().setProperty(jsiRuntime, "getItem", move(getItem));
    
}

@end
