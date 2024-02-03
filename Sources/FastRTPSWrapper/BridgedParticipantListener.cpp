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
#include "FastDDSVersion.h"

using namespace eprosima::fastrtps;
using namespace eprosima::fastrtps::rtps;

void BridgedParticipantListener::onReaderDiscovery(RTPSParticipant *participant, ReaderDiscoveryInfo &&info)
{
    (void)participant;
    std::ostringstream stream;
    struct ReaderInfo readerInfo;
    std::string str;
    
    readerInfo.locators = nullptr;
    readerInfo.topic = info.info.topicName().c_str();
    readerInfo.ddstype = info.info.typeName().c_str();
    readerInfo.readerProfile.reliability = static_cast<Reliability>(info.info.m_qos.m_reliability.kind);
    readerInfo.readerProfile.durability = static_cast<Durability>(info.info.m_qos.m_durability.kind);
    readerInfo.readerProfile.keyed = info.info.topicKind() == eprosima::fastrtps::rtps::WITH_KEY;

    switch(info.status) {
        case ReaderDiscoveryInfo::DISCOVERED_READER:
            dumpLocators(info.info.remote_locators().unicast, stream);
            str = stream.str();
            readerInfo.locators = str.c_str();
            container.discoveryReaderCallback(container.listnerObject, RTPSReaderStatusDiscoveredReader, &readerInfo);
            break;
        case ReaderDiscoveryInfo::CHANGED_QOS_READER:
            container.discoveryReaderCallback(container.listnerObject, RTPSReaderStatusChangedQosReader, &readerInfo);
            break;
        case ReaderDiscoveryInfo::REMOVED_READER:
            container.discoveryReaderCallback(container.listnerObject, RTPSReaderStatusRemovedReader, &readerInfo);
            break;
#if FASTDDS_VERSION >= 21000
        case ReaderDiscoveryInfo::IGNORED_READER:
            container.discoveryReaderCallback(container.listnerObject, RTPSReaderStatusIgnoredReader, &readerInfo);
            break;
#endif
    }
}

void BridgedParticipantListener::onWriterDiscovery(RTPSParticipant *participant, WriterDiscoveryInfo &&info)
{
    (void)participant;
    std::ostringstream stream;
    struct WriterInfo writerInfo;
    std::string str;

    writerInfo.locators = nullptr;
    writerInfo.topic = info.info.topicName().c_str();
    writerInfo.ddstype = info.info.typeName().c_str();
    writerInfo.writerProfile.reliability = static_cast<Reliability>(info.info.m_qos.m_reliability.kind);
    writerInfo.writerProfile.durability = static_cast<Durability>(info.info.m_qos.m_durability.kind);
    writerInfo.writerProfile.keyed = info.info.topicKind() == eprosima::fastrtps::rtps::WITH_KEY;
    writerInfo.writerProfile.disablePositiveACKs = info.info.m_qos.m_disablePositiveACKs.enabled;

    switch(info.status) {
        case WriterDiscoveryInfo::DISCOVERED_WRITER:
            dumpLocators(info.info.remote_locators().unicast, stream);
            str = stream.str();
            writerInfo.locators = str.c_str();
            container.discoveryWriterCallback(container.listnerObject, RTPSWriterStatusDiscoveredWriter, &writerInfo);
            break;
        case WriterDiscoveryInfo::CHANGED_QOS_WRITER:
            container.discoveryWriterCallback(container.listnerObject, RTPSWriterStatusChangedQosWriter, &writerInfo);
            break;
        case WriterDiscoveryInfo::REMOVED_WRITER:
            container.discoveryWriterCallback(container.listnerObject, RTPSWriterStatusRemovedWriter, &writerInfo);
            break;
#if FASTDDS_VERSION >= 21000
        case WriterDiscoveryInfo::IGNORED_WRITER:
            container.discoveryWriterCallback(container.listnerObject, RTPSWriterStatusIgnoredWriter, &writerInfo);
            break;
#endif
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
            container.discoveryParticipantCallback(container.listnerObject, RTPSParticipantStatusDiscoveredParticipant, info.info.m_participantName, stream.str().c_str(), propDict);
            do {
                free((void *)propDict[i--]);
            } while (i != 0);
            delete [] propDict;
            break;
        case ParticipantDiscoveryInfo::DROPPED_PARTICIPANT:
            container.discoveryParticipantCallback(container.listnerObject, RTPSParticipantStatusDroppedParticipant, info.info.m_participantName, nullptr, nullptr);
            break;
        case ParticipantDiscoveryInfo::REMOVED_PARTICIPANT:
            container.discoveryParticipantCallback(container.listnerObject, RTPSParticipantStatusRemovedParticipant, info.info.m_participantName, nullptr, nullptr);
            break;
        case ParticipantDiscoveryInfo::CHANGED_QOS_PARTICIPANT:
            container.discoveryParticipantCallback(container.listnerObject, RTPSParticipantStatusChangedQosParticipant, info.info.m_participantName, nullptr, nullptr);
            break;
#if FASTDDS_VERSION >= 21000
        case ParticipantDiscoveryInfo::IGNORED_PARTICIPANT:
            container.discoveryParticipantCallback(container.listnerObject, RTPSParticipantStatusIgnoredParticipant, info.info.m_participantName, nullptr, nullptr);
            break;
#endif
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
