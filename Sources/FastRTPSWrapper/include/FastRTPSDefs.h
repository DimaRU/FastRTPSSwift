/////
////  FastRTPSDefs.h
///   Copyright © 2020 Dmitriy Borovikov. All rights reserved.
//

#pragma once

#include "../BridgedReaderProxyData.h"
#include "../BridgedWriterProxyData.h"
#include "../BridgedParticipantProxyData.h"

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


typedef NS_CLOSED_ENUM(uint32_t, RTPSReaderStatus) {
    RTPSReaderStatusMatchedMatching = 0,
    RTPSReaderStatusRemovedMatching,
    RTPSReaderStatusLivelinessLost,
};

typedef NS_CLOSED_ENUM(uint32_t, RTPSWriterStatus) {
    RTPSWriterStatusMatchedMatching = 0,
    RTPSWriterStatusRemovedMatching,
    RTPSWriterStatusLivelinessLost,
};

typedef NS_CLOSED_ENUM(uint32_t, FastRTPSLogLevel) {
    FastRTPSLogLevelError=0,
    FastRTPSLogLevelWarning,
    FastRTPSLogLevelInfo
};

#pragma clang assume_nonnull begin

struct RTPSReaderProfile {
    bool keyed;
    eprosima::fastdds::dds::ReliabilityQosPolicyKind reliability;
    eprosima::fastdds::dds::DurabilityQosPolicyKind_t durability;
};

struct RTPSWriterProfile {
    bool keyed;
    eprosima::fastdds::dds::ReliabilityQosPolicyKind reliability;
    eprosima::fastdds::dds::DurabilityQosPolicyKind_t durability;
    bool disablePositiveACKs;
};

struct RTPSParticipantProfile {
    double leaseDurationAnnouncementperiod;
    double leaseDuration;
    uint32_t participantFilter;
};

typedef void (*DecoderCallback)(const void * payloadDecoder, uint64_t sequence, int payloadSize, uint8_t * payload);
typedef void (*ReleaseCallback)(const void * payloadDecoder);

typedef void (*ReaderListenerCallback)(const void * listnerObject,
                                       uint32_t reason,
                                       const char* topicName);

typedef void (*WriterListenerCallback)(const void * listnerObject,
                                       uint32_t reason,
                                       const char* topicName);

typedef void (*DiscoveryParticipantCallback)(const void * listnerObject,
                                             uint32_t reason,
                                             BridgedParticipantProxyData& info);

typedef void (*DiscoveryReaderCallback)(const void * listnerObject,
                                        uint32_t reason,
                                        BridgedReaderProxyData& info);

typedef void (*DiscoveryWriterCallback)(const void * listnerObject,
                                        uint32_t reason,
                                        BridgedWriterProxyData& info);



struct BridgeContainer
{
    DecoderCallback decoderCallback;
    ReleaseCallback releaseCallback;
    ReaderListenerCallback readerListenerCallback;
    WriterListenerCallback writerListenerCallback;
    DiscoveryParticipantCallback discoveryParticipantCallback;
    DiscoveryReaderCallback discoveryReaderCallback;
    DiscoveryWriterCallback discoveryWriterCallback;
    const void *listnerObject;
};
#pragma clang assume_nonnull end
