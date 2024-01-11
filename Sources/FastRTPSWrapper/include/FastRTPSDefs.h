/////
////  FastRTPSDefs.h
///   Copyright © 2020 Dmitriy Borovikov. All rights reserved.
//

#ifndef FastRTPSDefs_h
#define FastRTPSDefs_h

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

typedef NS_CLOSED_ENUM(uint32_t, RTPSNotification) {
    RTPSNotificationReaderMatchedMatching = 0,
    RTPSNotificationReaderRemovedMatching,
    RTPSNotificationReaderLivelinessLost,
    RTPSNotificationWriterMatchedMatching,
    RTPSNotificationWriterRemovedMatching,
    RTPSNotificationWriterLivelinessLost,
};

typedef NS_CLOSED_ENUM(uint32_t, RTPSReaderWriterNotification) {
    RTPSReaderWriterNotificationDiscoveredReader = 0,
    RTPSReaderWriterNotificationChangedQosReader,
    RTPSReaderWriterNotificationRemovedReader,
    RTPSReaderWriterNotificationDiscoveredWriter,
    RTPSReaderWriterNotificationChangedQosWriter,
    RTPSReaderWriterNotificationRemovedWriter,
};
typedef NS_CLOSED_ENUM(uint32_t, RTPSParticipantNotification) {
    RTPSParticipantNotificationDiscoveredParticipant = 0,
    RTPSParticipantNotificationChangedQosParticipant,
    RTPSParticipantNotificationRemovedParticipant,
    RTPSParticipantNotificationDroppedParticipant,
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
    ReliabilityReliable = 0,
    ReliabilityBestEffort,
};

typedef NS_CLOSED_ENUM(uint32_t, ParticipantFilter) {
    Disabled = 0,
    DifferentHost,
    DifferentProcess,
    SameProcess,
};


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
    long double leaseDuration_announcementperiod;
    long double leaseDuration;
    ParticipantFilter participantFilter;
};

#endif /* FastRTPSDefs_h */
