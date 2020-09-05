/////
////  FastRTPSBridge.h
///   Copyright © 2020 Dmitriy Borovikov. All rights reserved.
//


#ifndef FastRTPSBridge_h
#define FastRTPSBridge_h

#ifndef  __cplusplus
#import <Foundation/Foundation.h>

#else

#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>

#ifndef NS_ENUM
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#endif

#endif

typedef NS_ENUM(uint32_t, RTPSNotification) {
  RTPSNotificationReaderMatchedMatching = 0,
  RTPSNotificationReaderRemovedMatching,
  RTPSNotificationReaderLivelinessLost,
  RTPSNotificationWriterMatchedMatching,
  RTPSNotificationWriterRemovedMatching,
  RTPSNotificationWriterLivelinessLost,
};

typedef NS_ENUM(uint32_t, RTPSReaderWriterNotification) {
  RTPSReaderWriterNotificationDiscoveredReader = 0,
  RTPSReaderWriterNotificationChangedQosReader,
  RTPSReaderWriterNotificationRemovedReader,
  RTPSReaderWriterNotificationDiscoveredWriter,
  RTPSReaderWriterNotificationChangedQosWriter,
  RTPSReaderWriterNotificationRemovedWriter,
};
typedef NS_ENUM(uint32_t, RTPSParticipantNotification) {
  RTPSParticipantNotificationDiscoveredParticipant = 0,
  RTPSParticipantNotificationChangedQosParticipant,
  RTPSParticipantNotificationRemovedParticipant,
  RTPSParticipantNotificationDroppedParticipant,
};

typedef NS_ENUM(uint32_t, FastRTPSLogLevel) {
    FastRTPSLogLevelError=0,
    FastRTPSLogLevelWarning,
    FastRTPSLogLevelInfo
};

typedef void (*DecoderCallback)(void * _Nonnull payloadDecoder, uint64_t sequence, int payloadSize, uint8_t * _Nonnull payload);
typedef void (*ReleaseCallback)(void * _Nonnull payloadDecoder);
typedef void (*ReaderWriterListenerCallback)(const void * _Nonnull listnerObject,
                                             RTPSNotification reason,
                                             const char* _Nonnull topicName);

typedef void (*DiscoveryParticipantCallback)(const void * _Nonnull listnerObject,
                                             RTPSParticipantNotification reason,
                                             const char * _Nonnull participantName,
                                             const char* const _Nullable unicastLocators[_Nullable],
                                             const char* const _Nullable properties[_Nullable]);

typedef void (*DiscoveryReaderWriterCallback)(const void * _Nonnull listnerObject,
                                              RTPSReaderWriterNotification reason,
                                              const char* _Nonnull topicName,
                                              const char* _Nonnull typeName,
                                              const char* const _Nullable remoteLocators[_Nullable]);

#ifdef __cplusplus
extern "C" {
#endif
#pragma clang assume_nonnull begin
const void * _Nonnull makeBridgedParticipant(DecoderCallback decoderCallback,
                                             ReleaseCallback releaseCallback);

void setRTPSListenerCallback(const void * participant,
                             const void * listnerObject,
                             ReaderWriterListenerCallback readerWriterListenerCallback,
                             DiscoveryParticipantCallback discoveryParticipantCallback,
                             DiscoveryReaderWriterCallback discoveryReaderWriterCallback);

void createRTPSParticipantFilered(const void * participant,
                                  const uint32_t domain,
                                  const char* name,
                                  const char* _Nullable localAddress,
                                  const char* _Nullable filterAddress);

void createRTPSParticipant(const void * participant,
                           const uint32_t domain,
                           const char* name,
                           const char* _Nullable localAddress);

void setRTPSLoglevel(enum FastRTPSLogLevel logLevel);
void setRTPSPartition(const void * participant, const char * partition);
void registerRTPSReader(const void * participant,
                        const char * topicName,
                        const char * typeName,
                        bool keyed,
                        bool transientLocal,
                        bool reliable,
                        const void * payloadDecoder);

void removeRTPSReader(const void * participant,
                      const char * topicName);

void registerRTPSWriter(const void * participant,
                    const char * topicName,
                    const char * typeName,
                    bool keyed,
                    bool transientLocal,
                    bool reliable);

void removeRTPSWriter(const void * participant,
                      const char * topicName);

void sendDataWithKey(const void * participant,
                     const char * topicName,
                     const void * data,
                     uint32_t length,
                     const void * key,
                     uint32_t keyLength);

void sendData(const void * participant,
              const char * topicName,
              const void * data,
              uint32_t length);

void resignRTPSAll(const void * participant);

void removeRTPSParticipant(const void * participant);

#pragma clang assume_nonnull end
#ifdef __cplusplus
}
#endif

#endif /* FastRTPSBridge_h */
