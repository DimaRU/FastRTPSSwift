//
//  CustomParticipantListener.cpp
//  TestFastRTPS
//
//  Created by Dmitriy Borovikov on 29/07/2019.
//  Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//

#include <fastrtps/log/Log.h>
#include "CustomParticipantListener.h"

using namespace eprosima::fastrtps;
using namespace eprosima::fastrtps::rtps;

void CustomParticipantListener::onReaderDiscovery(RTPSParticipant *participant, ReaderDiscoveryInfo &&info)
{
    (void)participant;
    switch(info.status) {
        case ReaderDiscoveryInfo::DISCOVERED_READER:
            logWarning(PARTICIPANT_LISTENER, "Reader for topic '" << info.info.topicName() << "' type '" << info.info.typeName() << "' discovered")
            break;
        case ReaderDiscoveryInfo::CHANGED_QOS_READER:
            break;
        case ReaderDiscoveryInfo::REMOVED_READER:
            logWarning(PARTICIPANT_LISTENER, "Reader for topic '" << info.info.topicName() << "' type '" << info.info.typeName() << "' left the domain.")
            break;
    }
}

void CustomParticipantListener::onWriterDiscovery(RTPSParticipant *participant, WriterDiscoveryInfo &&info)
{
    (void)participant;
    switch(info.status) {
        case WriterDiscoveryInfo::DISCOVERED_WRITER:
            logWarning(PARTICIPANT_LISTENER, "Writer for topic '" << info.info.topicName() << "' type '" << info.info.typeName() << "' discovered")
            break;
        case WriterDiscoveryInfo::CHANGED_QOS_WRITER:
            break;
        case WriterDiscoveryInfo::REMOVED_WRITER:
            logWarning(PARTICIPANT_LISTENER, "Writer for topic '" << info.info.topicName() << "' type '" << info.info.typeName() << "' left the domain.")
            break;
    }
}

void CustomParticipantListener::onParticipantDiscovery(RTPSParticipant *participant, ParticipantDiscoveryInfo &&info)
{
    (void)participant;
    switch(info.status) {
        case ParticipantDiscoveryInfo::DISCOVERED_PARTICIPANT:
            logWarning(PARTICIPANT_LISTENER, "Participant '" << info.info.m_participantName << "' discovered")
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
