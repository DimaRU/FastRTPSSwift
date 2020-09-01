/////
////  FastRTPSBridge.h
///   Copyright © 2020 Dmitriy Borovikov. All rights reserved.
//


#ifndef FastRTPSBridge_h
#define FastRTPSBridge_h

#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>

enum FastRTPSLogLevel {
    error=0, warning, info
};


typedef enum {
  RTPSNotificationReaderMatchedMatching = 0,
  RTPSNotificationReaderRemovedMatching = 1,
  RTPSNotificationReaderLivelinessLost = 2,
  RTPSNotificationWriterMatchedMatching = 3,
  RTPSNotificationWriterRemovedMatching = 4,
  RTPSNotificationWriterLivelinessLost = 5,
} RTPSNotification;

typedef enum {
  RTPSNotificationKeyParticipant = 0,
  RTPSNotificationKeyReason = 1,
  RTPSNotificationKeyTopic = 2,
  RTPSNotificationKeyLocators = 3,
  RTPSNotificationKeyMetaLocators = 4,
  RTPSNotificationKeyProperties = 5,
  RTPSNotificationKeyTypeName = 6,
} RTPSNotificationKey;

typedef enum {
  RTPSParticipantNotificationDiscoveredReader = 0,
  RTPSParticipantNotificationChangedQosReader = 1,
  RTPSParticipantNotificationRemovedReader = 2,
  RTPSParticipantNotificationDiscoveredWriter = 3,
  RTPSParticipantNotificationChangedQosWriter = 4,
  RTPSParticipantNotificationRemovedWriter = 5,
  RTPSParticipantNotificationDiscoveredParticipant = 6,
  RTPSParticipantNotificationChangedQosParticipant = 7,
  RTPSParticipantNotificationRemovedParticipant = 8,
  RTPSParticipantNotificationDroppedParticipant = 9,
} RTPSParticipantNotification;


typedef void (*DecoderCallback)(void * _Nonnull payloadDecoder, uint64_t sequence, int payloadSize, uint8_t * _Nonnull payload);
typedef void (*ReleaseCallback)(void * _Nonnull payloadDecoder);

#ifdef __cplusplus
extern "C" {
#endif


#pragma clang assume_nonnull begin
const void * _Nonnull makeBridgedParticipant(DecoderCallback decoderCallback, ReleaseCallback releaseCallback);
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
