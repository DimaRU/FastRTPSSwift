/////
////  BridgedParticipantListener.cpp
///   Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//

#include <fastrtps/log/Log.h>
#include "BridgedParticipantListener.h"

using namespace eprosima::fastrtps;
using namespace eprosima::fastrtps::rtps;

void BridgedParticipantListener::onReaderDiscovery(RTPSParticipant *participant, ReaderDiscoveryInfo &&info)
{
    (void)participant;
    auto bridgedInfo = BridgedReaderProxyData{info.info};
    container.discoveryReaderCallback(container.listnerObject, info.status, bridgedInfo);
}

void BridgedParticipantListener::onWriterDiscovery(RTPSParticipant *participant, WriterDiscoveryInfo &&info)
{
    (void)participant;
    auto bridgedInfo = BridgedWriterProxyData{ info.info };
    container.discoveryWriterCallback(container.listnerObject, info.status, bridgedInfo);
}

void BridgedParticipantListener::onParticipantDiscovery(RTPSParticipant *participant, ParticipantDiscoveryInfo&& info)
{
    (void)participant;
    auto bridgedInfo = BridgedParticipantProxyData{info.info};
    container.discoveryParticipantCallback(container.listnerObject, info.status, bridgedInfo);
}
