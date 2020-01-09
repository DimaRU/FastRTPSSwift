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

/// Create instance, set FastRTPS log level
/// @param logLevel FastRTPS log level:
// * error
// * warning
// * info
- (id)initWithLogLevel:(LogLevel)logLevel;

/// Create RTPS paticipant and start listening
/// @param name Participant name
/// @param peerIPv4 peer IPv4 address (initially multicast)
- (bool)createRTPSParticipantWithName:(NSString *)name
                        interfaceIPv4:(NSString* _Nullable) interfaceIPv4
                       networkAddress:(NSString* _Nullable) networkAddress;

/// Set partition name for readers and writers
/// @param name partition name (initially "*")
- (void)setPartition:(NSString *)name;

/// Rerister RTPS reader
/// @param topicName topic name
/// @param typeName DDS type name
/// @param keyed true if keyed
/// @param payloadDecoder called when sample arrived
- (bool)registerReaderWithTopicName:(NSString *)topicName typeName:(NSString*)typeName keyed:(bool) keyed payloadDecoder: (NSObject<PayloadDecoderInterface>*) payloadDecoder;

/// Remote registered RTPS reader
/// @param topicName topic name
- (bool)removeReaderWithTopicName:(NSString *)topicName;

/// Register RTPS writer
/// @param topicName topic name
/// @param typeName DDS type name
/// @param keyed true if keyed
- (bool)registerWriterWithTopicName:(NSString *)topicName typeName:(NSString*)typeName keyed:(bool) keyed;

/// Remote registered RTPS writer
/// @param topicName topic name
- (bool)removeWriterWithTopicName:(NSString *)topicName;

/// Send unkeyed change with RTPS writer
/// @param topicName writer topic name
/// @param data change data
- (bool)sendWithTopicName:(NSString *)topicName data:(NSData*) data key: (NSData*) key;

/// Send keyed change with RTPS writer
/// @param topicName writer topic name
/// @param data change data
/// @param key sample key
- (bool)sendWithTopicName:(NSString *)topicName data:(NSData*) data;

/// Remove all RTPS readers and writers, stop and delete participant
- (void)deleteParticipant;

/// Remove all RTPS readers and writers
- (void)resignAll;

/// Return all interfaces IPv4 addresses
- (NSSet*)getIP4Address;

@end

NS_ASSUME_NONNULL_END
