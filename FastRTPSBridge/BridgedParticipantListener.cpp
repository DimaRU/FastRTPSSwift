/////
////  BridgedParticipantListener.cpp
///   Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//

#include <fastrtps/log/Log.h>
#include "BridgedParticipantListener.h"
#include <arpa/inet.h>
#include <fastrtps/rtps/common/Locator.h>
#include <fastrtps/utils/IPLocator.h>

using namespace eprosima::fastrtps;
using namespace eprosima::fastrtps::rtps;

void participantListenerCallback(int reason, const char *topicName, const char* typeName, const char* remoteLocators, const char* properties[] );

void BridgedParticipantListener::onReaderDiscovery(RTPSParticipant *participant, ReaderDiscoveryInfo &&info)
{
    (void)participant;
    auto topicName = info.info.topicName();
    auto typeName = info.info.typeName();

    switch(info.status) {
        case ReaderDiscoveryInfo::DISCOVERED_READER:
//            notificationDictionary[@(RTPSNotificationUserInfoReason)] = @(RTPSParticipantNotificationReasonDiscoveredReader);
//            notificationDictionary[@(RTPSNotificationUserInfoLocators)] = dumpLocators(info.info.remote_locators().unicast);
            participantListenerCallback(RTPSParticipantNotificationDiscoveredReader, topicName, typeName, nullptr, nullptr);
            break;
        case ReaderDiscoveryInfo::CHANGED_QOS_READER:
//            notificationDictionary[@(RTPSNotificationUserInfoReason)] = @(RTPSParticipantNotificationReasonChangedQosReader);
            participantListenerCallback(RTPSParticipantNotificationChangedQosReader, topicName, typeName, nullptr, nullptr);
            break;
        case ReaderDiscoveryInfo::REMOVED_READER:
//            notificationDictionary[@(RTPSNotificationUserInfoReason)] = @(RTPSParticipantNotificationReasonRemovedReader);
            participantListenerCallback(RTPSParticipantNotificationRemovedReader, topicName, typeName, nullptr, nullptr);
            break;
    }
}

void BridgedParticipantListener::onWriterDiscovery(RTPSParticipant *participant, WriterDiscoveryInfo &&info)
{
    (void)participant;
    auto topicName = info.info.topicName();
    auto typeName = info.info.typeName();

    switch(info.status) {
        case WriterDiscoveryInfo::DISCOVERED_WRITER:
//            notificationDictionary[@(RTPSNotificationUserInfoReason)] = @(RTPSParticipantNotificationReasonDiscoveredWriter);
//            notificationDictionary[@(RTPSNotificationUserInfoLocators)] = dumpLocators(info.info.remote_locators().unicast);
            participantListenerCallback(RTPSParticipantNotificationDiscoveredWriter, topicName, typeName, nullptr, nullptr);
            break;
        case WriterDiscoveryInfo::CHANGED_QOS_WRITER:
//            notificationDictionary[@(RTPSNotificationUserInfoReason)] = @(RTPSParticipantNotificationReasonChangedQosWriter);
            participantListenerCallback(RTPSParticipantNotificationChangedQosWriter, topicName, typeName, nullptr, nullptr);
            break;
        case WriterDiscoveryInfo::REMOVED_WRITER:
//            notificationDictionary[@(RTPSNotificationUserInfoReason)] = @(RTPSParticipantNotificationReasonRemovedWriter);
            participantListenerCallback(RTPSParticipantNotificationRemovedWriter, topicName, typeName, nullptr, nullptr);
            break;
    }
    
}

void BridgedParticipantListener::onParticipantDiscovery(RTPSParticipant *participant, ParticipantDiscoveryInfo&& info)
{
    (void)participant;
    auto properties = info.info.m_properties;
    auto count = properties.size();
    auto propDict = new const char*[count * 2 + 1];
    int i = 0;

    switch(info.status) {
        case ParticipantDiscoveryInfo::DISCOVERED_PARTICIPANT:
            propDict[count * 2] = nullptr;
            
            for (auto prop = properties.begin(); prop != properties.end(); prop++) {
                auto key = prop->first().c_str();
                auto value = prop->second().c_str();
                propDict[i++] = key;
                propDict[i++] = value;
            }
            participantListenerCallback(RTPSParticipantNotificationDiscoveredParticipant, info.info.m_participantName, nullptr, nullptr, propDict);
//            RTPSParticipantNotificationReason DiscoveredParticipant
            
//            notificationDictionary[@(RTPSNotificationUserInfoProperties)] = propDict;
//            notificationDictionary[@(RTPSNotificationUserInfoLocators)] = dumpLocators(info.info.default_locators.unicast);
//            notificationDictionary[@(RTPSNotificationUserInfoMetaLocators)] = dumpLocators(info.info.metatraffic_locators.unicast);
            break;
        case ParticipantDiscoveryInfo::DROPPED_PARTICIPANT:
//            RTPSParticipantNotificationReason DroppedParticipant
            participantListenerCallback(RTPSParticipantNotificationDroppedParticipant, info.info.m_participantName, nullptr, nullptr, nullptr);
            break;
        case ParticipantDiscoveryInfo::REMOVED_PARTICIPANT:
//            RTPSParticipantNotificationReason RemovedParticipant
            participantListenerCallback(RTPSParticipantNotificationRemovedParticipant, info.info.m_participantName, nullptr, nullptr, nullptr);
            break;
        case ParticipantDiscoveryInfo::CHANGED_QOS_PARTICIPANT:
//            RTPSParticipantNotificationReason ChangedQosParticipant
            participantListenerCallback(RTPSParticipantNotificationChangedQosParticipant, info.info.m_participantName, nullptr, nullptr, nullptr);
            break;
    }
    delete propDict[count * 2 + 1];

}

//NSSet* BridgedParticipantListener::dumpLocators(ResourceLimitedVector<eprosima::fastrtps::rtps::Locator_t> locators)
//{
//    NSMutableSet *set = [[NSMutableSet alloc] init];
//    for (auto locator = locators.cbegin(); locator != locators.cend(); locator++) {
//        [set addObject:[NSString stringWithFormat:@"%s:%d", IPLocator::ip_to_string(*locator).c_str(), locator->port]];
//    }
//    return set;
//}
