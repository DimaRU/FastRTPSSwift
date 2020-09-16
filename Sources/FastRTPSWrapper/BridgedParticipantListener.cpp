/////
////  BridgedParticipantListener.cpp
///   Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//

#include <fastrtps/log/Log.h>
#include "BridgedParticipantListener.h"
#include <arpa/inet.h>
#include <fastrtps/rtps/common/Locator.h>
#include <fastrtps/utils/IPLocator.h>
#include <memory.h>

using namespace eprosima::fastrtps;
using namespace eprosima::fastrtps::rtps;

const int LocatorStringSize = 1000;

void BridgedParticipantListener::onReaderDiscovery(RTPSParticipant *participant, ReaderDiscoveryInfo &&info)
{
    (void)participant;
    auto topicName = info.info.topicName();
    auto typeName = info.info.typeName();
    char locatorString[LocatorStringSize];

    switch(info.status) {
        case ReaderDiscoveryInfo::DISCOVERED_READER:
            dumpLocators(info.info.remote_locators().unicast, locatorString);
            container.discoveryReaderWriterCallback(container.listnerObject, RTPSReaderWriterNotificationDiscoveredReader, topicName, typeName, locatorString);
            break;
        case ReaderDiscoveryInfo::CHANGED_QOS_READER:
            container.discoveryReaderWriterCallback(container.listnerObject, RTPSReaderWriterNotificationChangedQosReader, topicName, typeName, nullptr);
            break;
        case ReaderDiscoveryInfo::REMOVED_READER:
            container.discoveryReaderWriterCallback(container.listnerObject, RTPSReaderWriterNotificationRemovedReader, topicName, typeName, nullptr);
            break;
    }
}

void BridgedParticipantListener::onWriterDiscovery(RTPSParticipant *participant, WriterDiscoveryInfo &&info)
{
    (void)participant;
    auto topicName = info.info.topicName();
    auto typeName = info.info.typeName();
    char locatorString[LocatorStringSize];

    switch(info.status) {
        case WriterDiscoveryInfo::DISCOVERED_WRITER:
            dumpLocators(info.info.remote_locators().unicast, locatorString);
            container.discoveryReaderWriterCallback(container.listnerObject, RTPSReaderWriterNotificationDiscoveredWriter, topicName, typeName, locatorString);
            break;
        case WriterDiscoveryInfo::CHANGED_QOS_WRITER:
            container.discoveryReaderWriterCallback(container.listnerObject, RTPSReaderWriterNotificationChangedQosWriter, topicName, typeName, nullptr);
            break;
        case WriterDiscoveryInfo::REMOVED_WRITER:
            container.discoveryReaderWriterCallback(container.listnerObject, RTPSReaderWriterNotificationRemovedWriter, topicName, typeName, nullptr);
            break;
    }
    
}

void BridgedParticipantListener::onParticipantDiscovery(RTPSParticipant *participant, ParticipantDiscoveryInfo&& info)
{
    (void)participant;
    const char** propDict;
    char locatorString[LocatorStringSize];
    auto properties = info.info.m_properties;
    auto count = properties.size();
    int i = 0;

    switch(info.status) {
        case ParticipantDiscoveryInfo::DISCOVERED_PARTICIPANT:
            propDict = new const char*[count * 2 + 1];
            
            for (auto prop = properties.begin(); prop != properties.end(); prop++) {
                propDict[i++] = strdup(prop->first().c_str());
                propDict[i++] = strdup(prop->second().c_str());
            }
            propDict[i] = nullptr;
//          dumpLocators(info.info.metatraffic_locators.unicast);
            dumpLocators(info.info.default_locators.unicast, locatorString);
            container.discoveryParticipantCallback(container.listnerObject, RTPSParticipantNotificationDiscoveredParticipant, info.info.m_participantName, locatorString, propDict);
            releaseList(propDict);
            break;
        case ParticipantDiscoveryInfo::DROPPED_PARTICIPANT:
            container.discoveryParticipantCallback(container.listnerObject, RTPSParticipantNotificationDroppedParticipant, info.info.m_participantName, nullptr, nullptr);
            break;
        case ParticipantDiscoveryInfo::REMOVED_PARTICIPANT:
            container.discoveryParticipantCallback(container.listnerObject, RTPSParticipantNotificationRemovedParticipant, info.info.m_participantName, nullptr, nullptr);
            break;
        case ParticipantDiscoveryInfo::CHANGED_QOS_PARTICIPANT:
            container.discoveryParticipantCallback(container.listnerObject, RTPSParticipantNotificationChangedQosParticipant, info.info.m_participantName, nullptr, nullptr);
            break;
    }
}

void BridgedParticipantListener::dumpLocators(ResourceLimitedVector<eprosima::fastrtps::rtps::Locator_t> locators, char locatorsString[])
{
    locatorsString[0] = '\0';
    int count = 0;
    
    auto count = locators.size();
    for (int i = 0; i < count; i++) {
        auto str = IPLocator::ip_to_string(locators[i]) + ":" + std::to_string(locators[i].port);
        if (count + str.size() >= LocatorStringSize) {
            break;
        }
        memcpy(locatorsString+count, str.c_str(), str.size());
        count += str.size();
        locatorsString[count++] = ',';
    }
    if (count != 0) {
        locatorsString[--count] = '\0';
    }
}

void BridgedParticipantListener::releaseList(const char** list) {
    char** ptr = (char** )list;
    while(*ptr != nullptr) {
        free(*ptr++);
    }
    delete [] list;
}
