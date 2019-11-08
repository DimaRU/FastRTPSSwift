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
            std::cout << "Reader for topic '" << info.info.topicName() << "' type '" << info.info.typeName() << "' discovered" << std::endl;
            notificationDictionary[@"type"] = @(RTPSParticipantNotificationTypeDiscoveredReader);
            notificationDictionary[@"locators"] = DumpLocators(info.info.remote_locators().unicast);
            break;
        case ReaderDiscoveryInfo::CHANGED_QOS_READER:
            notificationDictionary[@"type"] = @(RTPSParticipantNotificationTypeChangedQosReader);
            break;
        case ReaderDiscoveryInfo::REMOVED_READER:
            logWarning(PARTICIPANT_LISTENER, "Reader for topic '" << info.info.topicName() << "' type '" << info.info.typeName() << "' left the domain.")
            notificationDictionary[@"type"] = @(RTPSParticipantNotificationTypeRemovedReader);
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
            std::cout << "Writer for topic '" << info.info.topicName() << "' type '" << info.info.typeName() << "' discovered" << std::endl;
            notificationDictionary[@"type"] = @(RTPSParticipantNotificationTypeDiscoveredWriter);
            notificationDictionary[@"locators"] = DumpLocators(info.info.remote_locators().unicast);
            break;
        case WriterDiscoveryInfo::CHANGED_QOS_WRITER:
            notificationDictionary[@"type"] = @(RTPSParticipantNotificationTypeChangedQosWriter);
            break;
        case WriterDiscoveryInfo::REMOVED_WRITER:
            logWarning(PARTICIPANT_LISTENER, "Writer for topic '" << info.info.topicName() << "' type '" << info.info.typeName() << "' left the domain.")
            notificationDictionary[@"type"] = @(RTPSParticipantNotificationTypeRemovedWriter);
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
//                std::cout << inet_ntop(AF_INET, locator->address+12, addrString, sizeof(addrString)) << ":" << locator->port << std::endl;
                break;
            case LOCATOR_KIND_UDPv6:
                locatorString = [NSString stringWithFormat:@"%s:%d", inet_ntop(AF_INET, locator->address+12, addrString, sizeof(addrString)), locator->port];
                [set addObject:locatorString];
//                std::cout << inet_ntop(AF_INET6, locator->address, addrString, sizeof(addrString)) << ":" << locator->port << std::endl;
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
            logWarning(PARTICIPANT_LISTENER, "Participant '" << info.info.m_participantName << "' discovered")
            propDict = [[NSMutableDictionary alloc] init];
            for (auto prop = properties.cbegin(); prop != properties.cend(); prop++) {
                key = [[NSString alloc] initWithCString:prop->first.c_str() encoding:NSUTF8StringEncoding];
                value = [[NSString alloc] initWithCString:prop->second.c_str() encoding:NSUTF8StringEncoding];
                propDict[key] = value;
//                std::cout << prop->first << ":" << prop->second << std::endl;
            }
            notificationDictionary[@"properties"] = propDict;
            notificationDictionary[@"type"] = @(RTPSParticipantNotificationTypeDiscoveredParticipant);
            notificationDictionary[@"locators"] = DumpLocators(info.info.default_locators.unicast);
            break;
        case ParticipantDiscoveryInfo::DROPPED_PARTICIPANT:
            logWarning(PARTICIPANT_LISTENER, "Participant '" << info.info.m_participantName << "' dropped")
            notificationDictionary[@"type"] = @(RTPSParticipantNotificationTypeDroppedParticipant);
            break;
        case ParticipantDiscoveryInfo::REMOVED_PARTICIPANT:
            logWarning(PARTICIPANT_LISTENER, "Participant '" << info.info.m_participantName << "' removed")
            notificationDictionary[@"type"] = @(RTPSParticipantNotificationTypeRemovedParticipant);
            break;
        case ParticipantDiscoveryInfo::CHANGED_QOS_PARTICIPANT:
            notificationDictionary[@"type"] = @(RTPSParticipantNotificationTypeChangedQosParticipant);
            break;
    }
    
    [NSNotificationCenter.defaultCenter postNotificationName:RTPSParticipantNotificationName object:NULL userInfo:notificationDictionary];
}
