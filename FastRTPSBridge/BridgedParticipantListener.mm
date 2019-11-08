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
    notificationDictionary[@"topic"] = [[NSString alloc] initWithCString:info.info.topicName() encoding:NSUTF8StringEncoding];
    notificationDictionary[@"typeName"] = [[NSString alloc] initWithCString:info.info.typeName() encoding:NSUTF8StringEncoding];

    switch(info.status) {
        case ReaderDiscoveryInfo::DISCOVERED_READER:
            logInfo(PARTICIPANT_LISTENER, "Reader for topic '" << info.info.topicName() << "' type '" << info.info.typeName() << "' discovered");
            notificationDictionary[@"reason"] = @(RTPSParticipantNotificationReasonDiscoveredReader);
            notificationDictionary[@"locators"] = DumpLocators(info.info.remote_locators().unicast);
            break;
        case ReaderDiscoveryInfo::CHANGED_QOS_READER:
            notificationDictionary[@"reason"] = @(RTPSParticipantNotificationReasonChangedQosReader);
            break;
        case ReaderDiscoveryInfo::REMOVED_READER:
            logInfo(PARTICIPANT_LISTENER, "Reader for topic '" << info.info.topicName() << "' type '" << info.info.typeName() << "' left the domain.")
            notificationDictionary[@"reason"] = @(RTPSParticipantNotificationReasonRemovedReader);
            break;
    }
    
    [NSNotificationCenter.defaultCenter postNotificationName:RTPSParticipantNotificationName object:NULL userInfo:notificationDictionary];
}

void BridgedParticipantListener::onWriterDiscovery(RTPSParticipant *participant, WriterDiscoveryInfo &&info)
{
    (void)participant;
    NSMutableDictionary *notificationDictionary = [[NSMutableDictionary alloc] init];
    notificationDictionary[@"topic"] = [[NSString alloc] initWithCString:info.info.topicName() encoding:NSUTF8StringEncoding];
    notificationDictionary[@"typeName"] = [[NSString alloc] initWithCString:info.info.typeName() encoding:NSUTF8StringEncoding];

    switch(info.status) {
        case WriterDiscoveryInfo::DISCOVERED_WRITER:
            logInfo(PARTICIPANT_LISTENER, "Writer for topic '" << info.info.topicName() << "' type '" << info.info.typeName() << "' discovered");
            notificationDictionary[@"reason"] = @(RTPSParticipantNotificationReasonDiscoveredWriter);
            notificationDictionary[@"locators"] = DumpLocators(info.info.remote_locators().unicast);
            break;
        case WriterDiscoveryInfo::CHANGED_QOS_WRITER:
            notificationDictionary[@"reason"] = @(RTPSParticipantNotificationReasonChangedQosWriter);
            break;
        case WriterDiscoveryInfo::REMOVED_WRITER:
            logInfo(PARTICIPANT_LISTENER, "Writer for topic '" << info.info.topicName() << "' type '" << info.info.typeName() << "' left the domain.")
            notificationDictionary[@"reason"] = @(RTPSParticipantNotificationReasonRemovedWriter);
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
                logInfo(PARTICIPANT_LISTENER, inet_ntop(AF_INET, locator->address+12, addrString, sizeof(addrString)) << ":" << locator->port);
                break;
            case LOCATOR_KIND_UDPv6:
                locatorString = [NSString stringWithFormat:@"%s:%d", inet_ntop(AF_INET, locator->address+12, addrString, sizeof(addrString)), locator->port];
                [set addObject:locatorString];
                logInfo(PARTICIPANT_LISTENER, inet_ntop(AF_INET6, locator->address, addrString, sizeof(addrString)) << ":" << locator->port);
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
    notificationDictionary[@"participant"] = [[NSString alloc] initWithCString:info.info.m_participantName encoding:NSUTF8StringEncoding];
    NSString* key;
    NSString* value;
    NSMutableDictionary *propDict;

    switch(info.status) {
        case ParticipantDiscoveryInfo::DISCOVERED_PARTICIPANT:
            logInfo(PARTICIPANT_LISTENER, "Participant '" << info.info.m_participantName << "' discovered")
            propDict = [[NSMutableDictionary alloc] init];
            for (auto prop = properties.cbegin(); prop != properties.cend(); prop++) {
                key = [[NSString alloc] initWithCString:prop->first.c_str() encoding:NSUTF8StringEncoding];
                value = [[NSString alloc] initWithCString:prop->second.c_str() encoding:NSUTF8StringEncoding];
                propDict[key] = value;
                logInfo(PARTICIPANT_LISTENER, prop->first << ":" << prop->second);
            }
            notificationDictionary[@"properties"] = propDict;
            notificationDictionary[@"reason"] = @(RTPSParticipantNotificationReasonDiscoveredParticipant);
            notificationDictionary[@"locators"] = DumpLocators(info.info.default_locators.unicast);
            break;
        case ParticipantDiscoveryInfo::DROPPED_PARTICIPANT:
            logInfo(PARTICIPANT_LISTENER, "Participant '" << info.info.m_participantName << "' dropped")
            notificationDictionary[@"reason"] = @(RTPSParticipantNotificationReasonDroppedParticipant);
            break;
        case ParticipantDiscoveryInfo::REMOVED_PARTICIPANT:
            logInfo(PARTICIPANT_LISTENER, "Participant '" << info.info.m_participantName << "' removed")
            notificationDictionary[@"reason"] = @(RTPSParticipantNotificationReasonRemovedParticipant);
            break;
        case ParticipantDiscoveryInfo::CHANGED_QOS_PARTICIPANT:
            notificationDictionary[@"reason"] = @(RTPSParticipantNotificationReasonChangedQosParticipant);
            break;
    }
    
    [NSNotificationCenter.defaultCenter postNotificationName:RTPSParticipantNotificationName object:NULL userInfo:notificationDictionary];
}
