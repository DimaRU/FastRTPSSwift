/////
////  FastRTPSBridge.h
///   Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for FastRTPSBridge.
FOUNDATION_EXPORT double FastRTPSBridgeVersionNumber;

//! Project version string for FastRTPSBridge.
FOUNDATION_EXPORT const unsigned char FastRTPSBridgeVersionString[];

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const RTPSParticipantNotificationName;
FOUNDATION_EXPORT NSString *const RTPSReaderWriterNotificationName;

@protocol PayloadDecoderInterface;
@interface FastRTPSBridge : NSObject
typedef NS_CLOSED_ENUM(NSInteger, LogLevel) {
    error, warning, info
};

- (id)initWithLogLevel:(LogLevel)logLevel;
- (bool)registerReaderWithTopicName:(NSString *)topicName typeName:(NSString*)typeName keyed:(bool) keyed payloadDecoder: (NSObject<PayloadDecoderInterface>*) payloadDecoder;
- (bool)removeReaderWithTopicName:(NSString *)topicName;
- (bool)registerWriterWithTopicName:(NSString *)topicName typeName:(NSString*)typeName keyed:(bool) keyed;
- (bool)removeWriterWithTopicName:(NSString *)topicName;
- (bool)sendWithTopicName:(NSString *)topicName data:(NSData*) data key: (NSData*) key;
- (bool)sendWithTopicName:(NSString *)topicName data:(NSData*) data;
- (bool)createRTPSParticipantWithName:(NSString *)name ipv4:(NSString* _Nullable) ipv4;
- (void)setPartition:(NSString *)name;
- (void)stopRTPS;
- (void)resignAll;

@end

NS_ASSUME_NONNULL_END
