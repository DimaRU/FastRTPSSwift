/////
////  FastRTPSDefs.h
///   Copyright © 2020 Dmitriy Borovikov. All rights reserved.
//

#pragma once

#include <stdint.h>
#include <stdbool.h>

#if __has_attribute(enum_extensibility)
# define CLOSED_ENUM_ATTR __attribute__((enum_extensibility(closed)))
# define OPEN_ENUM_ATTR __attribute__((enum_extensibility(open)))
#else
# define CLOSED_ENUM_ATTR
# define OPEN_ENUM_ATTR
#endif

#ifndef NS_ENUM
#define NS_ENUM(_type, _name) enum OPEN_ENUM_ATTR _name : _type _name; enum OPEN_ENUM_ATTR _name : _type
#endif
#ifndef NS_CLOSED_ENUM
#define NS_CLOSED_ENUM(_type, _name) enum CLOSED_ENUM_ATTR _name : _type _name; enum CLOSED_ENUM_ATTR _name : _type
#endif


#if __has_attribute(swift_name)
# define CF_SWIFT_NAME(_name) __attribute__((swift_name(#_name)))
#else
# define CF_SWIFT_NAME(_name)
#endif

typedef NS_CLOSED_ENUM(uint32_t, RTPSStatus) {
    RTPSStatusReaderMatchedMatching = 0,
    RTPSStatusReaderRemovedMatching,
    RTPSStatusReaderLivelinessLost,
    RTPSStatusWriterMatchedMatching,
    RTPSStatusWriterRemovedMatching,
    RTPSStatusWriterLivelinessLost,
};

typedef NS_CLOSED_ENUM(uint32_t, RTPSReaderStatus) {
    RTPSReaderStatusDiscoveredReader = 0,
    RTPSReaderStatusChangedQosReader,
    RTPSReaderStatusRemovedReader,
    RTPSReaderStatusIgnoredReader,
};

typedef NS_CLOSED_ENUM(uint32_t, RTPSWriterStatus) {
    RTPSWriterStatusDiscoveredWriter = 0,
    RTPSWriterStatusChangedQosWriter,
    RTPSWriterStatusRemovedWriter,
    RTPSWriterStatusIgnoredWriter,
};

typedef NS_CLOSED_ENUM(uint32_t, RTPSParticipantStatus) {
    RTPSParticipantStatusDiscoveredParticipant = 0,
    RTPSParticipantStatusChangedQosParticipant,
    RTPSParticipantStatusRemovedParticipant,
    RTPSParticipantStatusDroppedParticipant,
    RTPSParticipantStatusIgnoredParticipant,
};

typedef NS_CLOSED_ENUM(uint32_t, FastRTPSLogLevel) {
    FastRTPSLogLevelError=0,
    FastRTPSLogLevelWarning,
    FastRTPSLogLevelInfo
};

typedef NS_CLOSED_ENUM(uint32_t, Durability) {
    DurabilityVolatile = 0,
    DurabilityTransientLocal,
    DurabilityTransient,
    DurabilityPersistent,
};

typedef NS_CLOSED_ENUM(uint32_t, Reliability) {
    ReliabilityBestEffort = 1,
    ReliabilityReliable = 2,
};

typedef NS_CLOSED_ENUM(uint32_t, ParticipantFilter) {
    Disabled = 0,
    DifferentHost,
    DifferentProcess,
    SameProcess,
};

#pragma clang assume_nonnull begin

struct RTPSReaderProfile {
    bool keyed;
    Reliability reliability;
    Durability durability;
};

struct RTPSWriterProfile {
    bool keyed;
    Reliability reliability;
    Durability durability;
    bool disablePositiveACKs;
};

struct RTPSParticipantProfile {
    long double leaseDurationAnnouncementperiod;
    long double leaseDuration;
    ParticipantFilter participantFilter;
};

struct ReaderInfo {
    const char *topic;
    const char *ddstype;
    const char * _Nullable locators;
    struct RTPSReaderProfile readerProfile;
};

struct WriterInfo {
    const char *topic;
    const char *ddstype;
    const char * _Nullable locators;
    struct RTPSWriterProfile writerProfile;
};


typedef void (*DecoderCallback)(void * payloadDecoder, uint64_t sequence, int payloadSize, uint8_t * payload);
typedef void (*ReleaseCallback)(void * payloadDecoder);
typedef void (*ReaderWriterListenerCallback)(const void * listnerObject,
                                             RTPSStatus reason,
                                             const char* topicName);

typedef void (*DiscoveryParticipantCallback)(const void * listnerObject,
                                             RTPSParticipantStatus reason,
                                             const char * participantName,
                                             const char* const _Nullable unicastLocators,
                                             const char* const _Nullable properties[_Nullable]);

typedef void (*DiscoveryReaderCallback)(const void * listnerObject,
                                              RTPSReaderStatus reason,
                                              const struct ReaderInfo* readerInfo);

typedef void (*DiscoveryWriterCallback)(const void * listnerObject,
                                              RTPSWriterStatus reason,
                                              const struct WriterInfo* writerInfo);



struct BridgeContainer
{
    DecoderCallback decoderCallback;
    ReleaseCallback releaseCallback;
    ReaderWriterListenerCallback readerWriterListenerCallback;
    DiscoveryParticipantCallback discoveryParticipantCallback;
    DiscoveryReaderCallback discoveryReaderCallback;
    DiscoveryWriterCallback discoveryWriterCallback;
    const void *listnerObject;
};
#pragma clang assume_nonnull end
