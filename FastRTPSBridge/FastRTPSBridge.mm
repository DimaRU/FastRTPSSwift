/////
////  FastRTPSBridge.mm
///   Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//

#import "FastRTPSBridge.h"
#import "BridgedParticipant.h"
#include <fastrtps/log/Log.h>
#include "CustomLogConsumer.h"

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
    Log::ReportFilenames(false);
    
    participant = new BridgedParticipant();
    return self;
}

/// Create RTPS paticipant and start listening
/// @param name Participant name
/// @param peerIPv4 peer IPv4 address (initially multicast)
- (bool)createRTPSParticipantWithName:(NSString *)name peerLocator: (NSString *)peerIPv4 {
    return participant->createParticipant([name cStringUsingEncoding:NSUTF8StringEncoding],
                                          [peerIPv4 cStringUsingEncoding:NSUTF8StringEncoding]);
}

/// Set partition name for readers and writers
/// @param name partition name (initially "*")
- (void)setPartition:(NSString *) name {
    participant->setPartition([name cStringUsingEncoding:NSUTF8StringEncoding]);
}

/// Rerister RTPS reader
/// @param topicName topic name
/// @param typeName DDS type name
/// @param keyed true if keyed
/// @param payloadDecoder called when sample arrived
- (bool)registerReaderWithTopicName:(NSString *)topicName typeName:(NSString*)typeName keyed:(bool) keyed payloadDecoder: (NSObject<PayloadDecoderInterface>*) payloadDecoder {

    return participant->addReader([topicName cStringUsingEncoding:NSUTF8StringEncoding],
                                   [typeName cStringUsingEncoding:NSUTF8StringEncoding],
                                   keyed,
                                   payloadDecoder);
}

/// Remote registered RTPS reader
/// @param topicName topic name
- (bool)removeReaderWithTopicName:(NSString *)topicName {
    return participant->removeReader([topicName cStringUsingEncoding:NSUTF8StringEncoding]);
}

/// Register RTPS writer
/// @param topicName topic name
/// @param typeName DDS type name
/// @param keyed true if keyed
- (bool)registerWriterWithTopicName:(NSString *)topicName typeName:(NSString*)typeName keyed:(bool) keyed {
    return participant->addWriter([topicName cStringUsingEncoding:NSUTF8StringEncoding],
                                   [typeName cStringUsingEncoding:NSUTF8StringEncoding],
                                   keyed);
}

/// Remote registered RTPS writer
/// @param topicName topic name
- (bool)removeWriterWithTopicName:(NSString *)topicName {
    return participant->removeReader([topicName cStringUsingEncoding:NSUTF8StringEncoding]);
}

/// Send unkeyed sample with RTPS writer
/// @param topicName writer topic name
/// @param data sample data
- (bool)sendWithTopicName:(NSString *)topicName data:(NSData*) data {
    return participant->send([topicName cStringUsingEncoding:NSUTF8StringEncoding],
                             static_cast<const uint8_t *>(data.bytes),
                             static_cast<uint32_t>(data.length),
                             NULL, 0);
}

/// Send keyed sample with RTPS writer
/// @param topicName writer topic name
/// @param data sample data
/// @param key sample key
- (bool)sendWithTopicName:(NSString *)topicName data:(NSData*) data key: (NSData*) key {
    return participant->send([topicName cStringUsingEncoding:NSUTF8StringEncoding],
                             static_cast<const uint8_t *>(data.bytes),
                             static_cast<uint32_t>(data.length),
                             static_cast<const uint8_t *>(key.bytes),
                             static_cast<uint32_t>(key.length));
}

/// Remove all RTPS readers and writers, stop and delete participand
- (void)stopRTPS {
    participant->resignAll();
    delete participant;
}

/// Remove all RTPS readers and writers
- (void)resignAll {
    participant->resignAll();
}

@end
