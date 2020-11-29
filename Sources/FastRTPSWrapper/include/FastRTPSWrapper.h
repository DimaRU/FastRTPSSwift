/////
////  FastRTPSWrapper.h
///   Copyright © 2020 Dmitriy Borovikov. All rights reserved.
//


#ifndef FastRTPSWrapper_h
#define FastRTPSWrapper_h

#include <stdint.h>
#include <stdbool.h>
#include "FastRTPSDefs.h"

typedef void (*DecoderCallback)(void * _Nonnull payloadDecoder, uint64_t sequence, int payloadSize, uint8_t * _Nonnull payload);
typedef void (*ReleaseCallback)(void * _Nonnull payloadDecoder);
typedef void (*ReaderWriterListenerCallback)(const void * _Nonnull listnerObject,
                                             RTPSNotification reason,
                                             const char* _Nonnull topicName);

typedef void (*DiscoveryParticipantCallback)(const void * _Nonnull listnerObject,
                                             RTPSParticipantNotification reason,
                                             const char * _Nonnull participantName,
                                             const char* const _Nullable unicastLocators,
                                             const char* const _Nullable properties[_Nullable]);

typedef void (*DiscoveryReaderWriterCallback)(const void * _Nonnull listnerObject,
                                              RTPSReaderWriterNotification reason,
                                              const char* _Nonnull topicName,
                                              const char* _Nonnull typeName,
                                              const char* const _Nullable remoteLocators);

#pragma clang assume_nonnull begin

struct BridgeContainer
{
    DecoderCallback decoderCallback;
    ReleaseCallback releaseCallback;
    ReaderWriterListenerCallback readerWriterListenerCallback;
    DiscoveryParticipantCallback discoveryParticipantCallback;
    DiscoveryReaderWriterCallback discoveryReaderWriterCallback;
    const void *listnerObject;
};

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
    const void * participant;
} FastRTPSWrapper;

const void * _Nonnull makeBridgedParticipant(void) CF_SWIFT_NAME(FastRTPSWrapper.init());

const char * _Nonnull fastDDSVersion(void) CF_SWIFT_NAME(FastRTPSWrapper.fastDDSVersion());

void setupRTPSBridgeContainer(const void * participant,
                              struct BridgeContainer container) CF_SWIFT_NAME(FastRTPSWrapper.setupBridgeContainer(self:container:));
#ifdef FASTRTPS_WHITELIST
bool createRTPSParticipantFiltered(const void * participant,
                                   const uint32_t domain,
                                   const char* name,
                                   const char* _Nullable localAddress,
                                   const char* _Nullable remoteWhitelistAddress) CF_SWIFT_NAME(FastRTPSWrapper.createParticipantFiltered(self:domain:name:localAddress:remoteWhitelistAddress:));
#endif
bool createRTPSParticipant(const void * participant,
                           const uint32_t domain,
                           const char* name,
                           const char* _Nullable localAddress) CF_SWIFT_NAME(FastRTPSWrapper.createParticipant(self:domain:name:localAddress:));

void setRTPSLoglevel(enum FastRTPSLogLevel logLevel) CF_SWIFT_NAME(FastRTPSWrapper.logLevel(level:));
void setRTPSPartition(const void * participant, const char * partition) CF_SWIFT_NAME(FastRTPSWrapper.setPartition(self:partition:));

bool registerRTPSReader(const void * participant,
                        const char * topicName,
                        const char * typeName,
                        const struct RTPSReaderProfile readerProfile,
                        const void * payloadDecoder,
                        const char * _Nullable ipv4Locator) CF_SWIFT_NAME(FastRTPSWrapper.registerReader(self:topicName:typeName:readerProfile:payloadDecoder:ipv4Locator:));

bool removeRTPSReader(const void * participant,
                      const char * topicName) CF_SWIFT_NAME(FastRTPSWrapper.removeReader(self:topicName:));

bool registerRTPSWriter(const void * participant,
                        const char * topicName,
                        const char * typeName,
                        const struct RTPSWriterProfile writerProfile,
                        const char * _Nullable ipv4Locator) CF_SWIFT_NAME(FastRTPSWrapper.registerWriter(self:topicName:typeName:writerProfile:ipv4Locator:));

bool removeRTPSWriter(const void * participant,
                      const char * topicName) CF_SWIFT_NAME(FastRTPSWrapper.removeWriter(self:topicName:));

bool sendDataWithKey(const void * participant,
                     const char * topicName,
                     const void * data,
                     uint32_t length,
                     const void * key,
                     uint32_t keyLength) CF_SWIFT_NAME(FastRTPSWrapper.sendDataWithKey(self:topicName:data:length:key:keyLength:));

bool sendData(const void * participant,
              const char * topicName,
              const void * data,
              uint32_t length) CF_SWIFT_NAME(FastRTPSWrapper.sendData(self:topicName:data:length:));

void resignRTPSAll(const void * participant) CF_SWIFT_NAME(FastRTPSWrapper.resignAll(self:));

void stopRTPSAll(const void * participant) CF_SWIFT_NAME(FastRTPSWrapper.stopAll(self:));

void removeRTPSParticipant(const void * participant) CF_SWIFT_NAME(FastRTPSWrapper.removeParticipant(self:));

#pragma clang assume_nonnull end
#ifdef __cplusplus
}
#endif

#endif /* FastRTPSWrapper_h */
