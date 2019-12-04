/////
////  BridgedParticipantListener.cpp
///   Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//

#include <fastrtps/log/Log.h>
#include "BridgedParticipantListener.h"
#include <arpa/inet.h>
#include <fastrtps/rtps/common/Locator.h>
#import "FastRTPSBridge/FastRTPSBridge-Swift.h"

using namespace eprosima::fastrtps;
using namespace eprosima::fastrtps::rtps;

void BridgedParticipantListener::onReaderDiscovery(RTPSParticipant *participant, ReaderDiscoveryInfo &&info)
{
    (void)participant;
    NSMutableDictionary *notificationDictionary = [[NSMutableDictionary alloc] init];
    notificationDictionary[@(RTPSNotificationUserInfoTopic)] = [[NSString alloc] initWithCString:info.info.topicName() encoding:NSUTF8StringEncoding];
    notificationDictionary[@(RTPSNotificationUserInfoTypeName)] = [[NSString alloc] initWithCString:info.info.typeName() encoding:NSUTF8StringEncoding];

    switch(info.status) {
        case ReaderDiscoveryInfo::DISCOVERED_READER:
            notificationDictionary[@(RTPSNotificationUserInfoReason)] = @(RTPSParticipantNotificationReasonDiscoveredReader);
            notificationDictionary[@(RTPSNotificationUserInfoLocators)] = DumpLocators(info.info.remote_locators().unicast);
            break;
        case ReaderDiscoveryInfo::CHANGED_QOS_READER:
            notificationDictionary[@(RTPSNotificationUserInfoReason)] = @(RTPSParticipantNotificationReasonChangedQosReader);
            break;
        case ReaderDiscoveryInfo::REMOVED_READER:
            notificationDictionary[@(RTPSNotificationUserInfoReason)] = @(RTPSParticipantNotificationReasonRemovedReader);
            break;
    }
    
    [NSNotificationCenter.defaultCenter postNotificationName:RTPSParticipantNotificationName object:NULL userInfo:notificationDictionary];
}

void BridgedParticipantListener::onWriterDiscovery(RTPSParticipant *participant, WriterDiscoveryInfo &&info)
{
    (void)participant;
    NSMutableDictionary *notificationDictionary = [[NSMutableDictionary alloc] init];
    notificationDictionary[@(RTPSNotificationUserInfoTopic)] = [[NSString alloc] initWithCString:info.info.topicName() encoding:NSUTF8StringEncoding];
    notificationDictionary[@(RTPSNotificationUserInfoTypeName)] = [[NSString alloc] initWithCString:info.info.typeName() encoding:NSUTF8StringEncoding];

    switch(info.status) {
        case WriterDiscoveryInfo::DISCOVERED_WRITER:
            notificationDictionary[@(RTPSNotificationUserInfoReason)] = @(RTPSParticipantNotificationReasonDiscoveredWriter);
            notificationDictionary[@(RTPSNotificationUserInfoLocators)] = DumpLocators(info.info.remote_locators().unicast);
            break;
        case WriterDiscoveryInfo::CHANGED_QOS_WRITER:
            notificationDictionary[@(RTPSNotificationUserInfoReason)] = @(RTPSParticipantNotificationReasonChangedQosWriter);
            break;
        case WriterDiscoveryInfo::REMOVED_WRITER:
            notificationDictionary[@(RTPSNotificationUserInfoReason)] = @(RTPSParticipantNotificationReasonRemovedWriter);
            break;
    }
    
    [NSNotificationCenter.defaultCenter postNotificationName:RTPSParticipantNotificationName object:NULL userInfo:notificationDictionary];
}

NSSet* BridgedParticipantListener::DumpLocators(ResourceLimitedVector<eprosima::fastrtps::rtps::Locator_t> locators)
{
    char addrString[INET6_ADDRSTRLEN+1];
    NSMutableSet *set = [[NSMutableSet alloc] init];
    NSString *locatorString;
    
    for (auto locator = locators.cbegin(); locator != locators.cend(); locator++) {
        switch (locator->kind) {
            case LOCATOR_KIND_UDPv4:
                locatorString = [NSString stringWithFormat:@"%s:%d", inet_ntop(AF_INET, locator->address+12, addrString, sizeof(addrString)), locator->port];
                [set addObject:locatorString];
                break;
            case LOCATOR_KIND_UDPv6:
                locatorString = [NSString stringWithFormat:@"%s:%d", inet_ntop(AF_INET, locator->address+12, addrString, sizeof(addrString)), locator->port];
                [set addObject:locatorString];
                break;
            default:
                break;
        }
    }
    return set;
}

void BridgedParticipantListener::onParticipantDiscovery(RTPSParticipant *participant, ParticipantDiscoveryInfo &&info)
{
    (void)participant;
    auto properties = info.info.m_properties.properties;
    NSMutableDictionary *notificationDictionary = [[NSMutableDictionary alloc] init];
    notificationDictionary[@(RTPSNotificationUserInfoParticipant)] = [[NSString alloc] initWithCString:info.info.m_participantName encoding:NSUTF8StringEncoding];
    NSString* key;
    NSString* value;
    NSMutableDictionary *propDict;

    switch(info.status) {
        case ParticipantDiscoveryInfo::DISCOVERED_PARTICIPANT:
            propDict = [[NSMutableDictionary alloc] init];
            for (auto prop = properties.cbegin(); prop != properties.cend(); prop++) {
                key = [[NSString alloc] initWithCString:prop->first.c_str() encoding:NSUTF8StringEncoding];
                value = [[NSString alloc] initWithCString:prop->second.c_str() encoding:NSUTF8StringEncoding];
                propDict[key] = value;
            }
            notificationDictionary[@(RTPSNotificationUserInfoProperties)] = propDict;
            notificationDictionary[@(RTPSNotificationUserInfoReason)] = @(RTPSParticipantNotificationReasonDiscoveredParticipant);
            notificationDictionary[@(RTPSNotificationUserInfoLocators)] = DumpLocators(info.info.default_locators.unicast);
            notificationDictionary[@(RTPSNotificationUserInfoMetaLocators)] = DumpLocators(info.info.metatraffic_locators.unicast);
            break;
        case ParticipantDiscoveryInfo::DROPPED_PARTICIPANT:
            notificationDictionary[@(RTPSNotificationUserInfoReason)] = @(RTPSParticipantNotificationReasonDroppedParticipant);
            break;
        case ParticipantDiscoveryInfo::REMOVED_PARTICIPANT:
            notificationDictionary[@(RTPSNotificationUserInfoReason)] = @(RTPSParticipantNotificationReasonRemovedParticipant);
            break;
        case ParticipantDiscoveryInfo::CHANGED_QOS_PARTICIPANT:
            notificationDictionary[@(RTPSNotificationUserInfoReason)] = @(RTPSParticipantNotificationReasonChangedQosParticipant);
            break;
    }
    
    [NSNotificationCenter.defaultCenter postNotificationName:RTPSParticipantNotificationName object:NULL userInfo:notificationDictionary];
}
