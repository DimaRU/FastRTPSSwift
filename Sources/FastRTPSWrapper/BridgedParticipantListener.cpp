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

void BridgedParticipantListener::onReaderDiscovery(RTPSParticipant *participant, ReaderDiscoveryInfo &&info)
{
    (void)participant;
    auto topicName = info.info.topicName();
    auto typeName = info.info.typeName();
    std::ostringstream stream;

    switch(info.status) {
        case ReaderDiscoveryInfo::DISCOVERED_READER:
            dumpLocators(info.info.remote_locators().unicast, stream);
            container.discoveryReaderWriterCallback(container.listnerObject, RTPSReaderWriterNotificationDiscoveredReader, topicName, typeName, stream.str().c_str());
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
    std::ostringstream stream;

    switch(info.status) {
        case WriterDiscoveryInfo::DISCOVERED_WRITER:
            dumpLocators(info.info.remote_locators().unicast, stream);
            container.discoveryReaderWriterCallback(container.listnerObject, RTPSReaderWriterNotificationDiscoveredWriter, topicName, typeName, stream.str().c_str());
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

    std::ostringstream stream;
    const char** propDict;
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
            dumpLocators(info.info.default_locators.unicast, stream);
            container.discoveryParticipantCallback(container.listnerObject, RTPSParticipantNotificationDiscoveredParticipant, info.info.m_participantName, stream.str().c_str(), propDict);
            do {
                free((void *)propDict[i--]);
            } while (i != 0);
            delete [] propDict;
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

void BridgedParticipantListener::dumpLocators(ResourceLimitedVector<eprosima::fastrtps::rtps::Locator_t> locators, std::ostringstream& stream)
{
    for (int i = 0; i < locators.size(); i++) {
        if (i != 0) {
            stream << ",";
        }
        stream << locators[i];
    }
}
