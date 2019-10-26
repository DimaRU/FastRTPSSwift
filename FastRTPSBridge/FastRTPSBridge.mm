//
//  FastRTPSBridge.mm
//  TridentVideoViewer
//
//  Created by Dmitriy Borovikov on 04/09/2019.
//  Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//

#import "FastRTPSBridge.h"
#import "RovParticipant.h"
#include <fastrtps/log/Log.h>
#include "CustomLogConsumer.h"

using namespace eprosima;
using namespace fastrtps;
using namespace rtps;
using namespace std;

@interface FastRTPSBridge()
{
    RovParticipant* participant;
}
@end

@implementation FastRTPSBridge

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
    
    participant = new RovParticipant();
    return self;
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

- (bool)startRTPS {
    return participant->startRTPS();
}

- (void)stopRTPS {
    participant->resignAll();
    delete participant;
}

- (void)resignAll {
    participant->resignAll();
}

@end
