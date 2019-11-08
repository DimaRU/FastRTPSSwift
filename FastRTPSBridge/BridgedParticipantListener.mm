/////
////  BridgedParticipantListener.cpp
///   Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//

#include <fastrtps/log/Log.h>
#include "BridgedParticipantListener.h"
#include <arpa/inet.h>
#include <fastrtps/rtps/common/Locator.h>

using namespace eprosima::fastrtps;
using namespace eprosima::fastrtps::rtps;

void BridgedParticipantListener::onReaderDiscovery(RTPSParticipant *participant, ReaderDiscoveryInfo &&info)
{
    (void)participant;
    switch(info.status) {
        case ReaderDiscoveryInfo::DISCOVERED_READER:
            std::cout << "Reader for topic '" << info.info.topicName() << "' type '" << info.info.typeName() << "' discovered" << std::endl;
            DumpLocators(info.info.remote_locators().unicast);
            break;
        case ReaderDiscoveryInfo::CHANGED_QOS_READER:
            break;
        case ReaderDiscoveryInfo::REMOVED_READER:
            logWarning(PARTICIPANT_LISTENER, "Reader for topic '" << info.info.topicName() << "' type '" << info.info.typeName() << "' left the domain.")
            break;
    }
}

void BridgedParticipantListener::onWriterDiscovery(RTPSParticipant *participant, WriterDiscoveryInfo &&info)
{
    (void)participant;
    switch(info.status) {
        case WriterDiscoveryInfo::DISCOVERED_WRITER:
            std::cout << "Writer for topic '" << info.info.topicName() << "' type '" << info.info.typeName() << "' discovered" << std::endl;
            DumpLocators(info.info.remote_locators().unicast);
            break;
        case WriterDiscoveryInfo::CHANGED_QOS_WRITER:
            break;
        case WriterDiscoveryInfo::REMOVED_WRITER:
            logWarning(PARTICIPANT_LISTENER, "Writer for topic '" << info.info.topicName() << "' type '" << info.info.typeName() << "' left the domain.")
            break;
    }
}

void BridgedParticipantListener::DumpLocators(ResourceLimitedVector<eprosima::fastrtps::rtps::Locator_t> locators)
{
    char addrString[INET6_ADDRSTRLEN+1];

    for (auto locator = locators.cbegin(); locator != locators.cend(); locator++) {
        switch (locator->kind) {
            case LOCATOR_KIND_UDPv4:
                std::cout << inet_ntop(AF_INET, locator->address+12, addrString, sizeof(addrString)) << ":" << locator->port << std::endl;
                break;
            case LOCATOR_KIND_UDPv6:
                std::cout << inet_ntop(AF_INET6, locator->address, addrString, sizeof(addrString)) << ":" << locator->port << std::endl;
                break;
            default:
                break;
        }
    }
}

void BridgedParticipantListener::onParticipantDiscovery(RTPSParticipant *participant, ParticipantDiscoveryInfo &&info)
{
    (void)participant;
    auto properties = info.info.m_properties.properties;
    switch(info.status) {
        case ParticipantDiscoveryInfo::DISCOVERED_PARTICIPANT:
            logWarning(PARTICIPANT_LISTENER, "Participant '" << info.info.m_participantName << "' discovered")
            for (auto prop = properties.cbegin(); prop != properties.cend(); prop++) {
                std::cout << prop->first << ":" << prop->second << std::endl;
            }
            DumpLocators(info.info.default_locators.unicast);
            break;
        case ParticipantDiscoveryInfo::DROPPED_PARTICIPANT:
            logWarning(PARTICIPANT_LISTENER, "Participant '" << info.info.m_participantName << "' dropped")
            break;
        case ParticipantDiscoveryInfo::REMOVED_PARTICIPANT:
            logWarning(PARTICIPANT_LISTENER, "Participant '" << info.info.m_participantName << "' removed")
            break;
        case ParticipantDiscoveryInfo::CHANGED_QOS_PARTICIPANT:
            break;
    }
}
