/////
////  FastRTPSBridge.mm
///   Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//

#import "FastRTPSBridge.h"
#import "BridgedParticipant.h"
#include <fastrtps/log/Log.h>
#include "CustomLogConsumer.h"
#include <fastrtps/utils/IPFinder.h>

using namespace eprosima;
using namespace fastrtps;
using namespace rtps;
using namespace std;

@interface FastRTPSBridge()
{
    BridgedParticipant* participant;
}
@end

@implementation FastRTPSBridge

/// Create instance, set FastRTPS log level
/// @param logLevel FastRTPS log level:
// * error
// * warning
// * info
- (id)initWithLogLevel:(LogLevel)logLevel {
    if (!(self = [super init])) {
        return nil;
    }
    
    Log::ClearConsumers();
    Log::RegisterConsumer(std::unique_ptr<LogConsumer>(new CustomLogConsumer));
    switch (logLevel) {
        case error:
            Log::SetVerbosity(Log::Kind::Error);
            break;
        case warning:
            Log::SetVerbosity(Log::Kind::Warning);
            break;
        case info:
            Log::SetVerbosity(Log::Kind::Info);
            break;
    }
    Log::ReportFilenames(true);
    
    participant = new BridgedParticipant();
    return self;
}

- (bool)createRTPSParticipantWithName:(NSString *)name
                        interfaceIPv4:(NSString* _Nullable) interfaceIPv4
                       networkAddress:(NSString* _Nullable) networkAddress {
    return participant->createParticipant([name cStringUsingEncoding:NSUTF8StringEncoding],
                                          [interfaceIPv4 cStringUsingEncoding:NSUTF8StringEncoding],
                                          [networkAddress cStringUsingEncoding:NSUTF8StringEncoding]);
}

- (void)setPartition:(NSString *) name {
    participant->setPartition([name cStringUsingEncoding:NSUTF8StringEncoding]);
}

- (bool)registerReaderWithTopicName:(NSString *)topicName typeName:(NSString*)typeName keyed:(bool) keyed payloadDecoder: (NSObject<PayloadDecoderInterface>*) payloadDecoder {

    return participant->addReader([topicName cStringUsingEncoding:NSUTF8StringEncoding],
                                   [typeName cStringUsingEncoding:NSUTF8StringEncoding],
                                   keyed,
                                   payloadDecoder);
}

- (bool)removeReaderWithTopicName:(NSString *)topicName {
    return participant->removeReader([topicName cStringUsingEncoding:NSUTF8StringEncoding]);
}

- (bool)registerWriterWithTopicName:(NSString *)topicName typeName:(NSString*)typeName keyed:(bool) keyed {
    return participant->addWriter([topicName cStringUsingEncoding:NSUTF8StringEncoding],
                                   [typeName cStringUsingEncoding:NSUTF8StringEncoding],
                                   keyed);
}

- (bool)removeWriterWithTopicName:(NSString *)topicName {
    return participant->removeReader([topicName cStringUsingEncoding:NSUTF8StringEncoding]);
}

- (bool)sendWithTopicName:(NSString *)topicName data:(NSData*) data {
    return participant->send([topicName cStringUsingEncoding:NSUTF8StringEncoding],
                             static_cast<const uint8_t *>(data.bytes),
                             static_cast<uint32_t>(data.length),
                             NULL, 0);
}

- (bool)sendWithTopicName:(NSString *)topicName data:(NSData*) data key: (NSData*) key {
    return participant->send([topicName cStringUsingEncoding:NSUTF8StringEncoding],
                             static_cast<const uint8_t *>(data.bytes),
                             static_cast<uint32_t>(data.length),
                             static_cast<const uint8_t *>(key.bytes),
                             static_cast<uint32_t>(key.length));
}

- (void)stopRTPS {
    participant->resignAll();
    delete participant;
}

- (void)resignAll {
    participant->resignAll();
}

- (NSSet*)getIP4Address {
    eprosima::fastrtps::rtps::LocatorList_t locators;
    eprosima::fastrtps::rtps::IPFinder::getIP4Address(&locators);
    NSMutableSet *set = [[NSMutableSet alloc] init];
    for (auto locator = locators.begin(); locator != locators.end(); locator++) {
        [set addObject:[NSString stringWithUTF8String:IPLocator::ip_to_string(*locator).c_str()]];
    }
    return set;
}
@end
