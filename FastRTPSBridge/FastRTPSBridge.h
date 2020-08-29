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

typedef void (*decoderCallback)(void * _Nonnull payloadDecoder, uint64_t sequence, int payloadSize, uint8_t * _Nonnull payload);

#ifdef __cplusplus
extern "C" {
#endif

const void * _Nonnull createRTPSParticipantFilered(const char* _Nonnull name, const char* _Nullable localAddress, const char* _Nullable filterAddress);
const void * _Nonnull createRTPSParticipant(const char* _Nonnull name, const char* _Nullable localAddress);

#pragma clang assume_nonnull begin
void setRTPSLoglevel(enum FastRTPSLogLevel logLevel);
void setRTPSPartition(const void * participant, const char * partition);
void registerRTPSReader(const void * participant,
                        const char * topicName,
                        const char * typeName,
                        bool keyed,
                        bool transientLocal,
                        bool reliable,
                        const void * payloadDecoder,
                        decoderCallback callback);

const void * _Nullable removeRTPSReader(const void * participant,
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
