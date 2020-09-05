/////
////  BridgedParticipantListener.h
///   Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//

#pragma once

#include <fastrtps/fastrtps_fwd.h>
#include <fastrtps/subscriber/SampleInfo.h>
#include <fastrtps/rtps/participant/RTPSParticipantListener.h>
#include "FastRTPSBridge.h"

using namespace eprosima::fastrtps;
using namespace eprosima::fastrtps::rtps;
		
class BridgedParticipantListener: public eprosima::fastrtps::rtps::RTPSParticipantListener
{
    void onParticipantDiscovery(RTPSParticipant *participant, ParticipantDiscoveryInfo &&info) override;
    void onReaderDiscovery(RTPSParticipant *participant, ReaderDiscoveryInfo &&info) override;
    void onWriterDiscovery(RTPSParticipant *participant, WriterDiscoveryInfo &&info) override;
    const char** dumpLocators(ResourceLimitedVector<eprosima::fastrtps::rtps::Locator_t> locators);
    void releaseList(const char** locators);
    BridgeContainer container;
public:
    BridgedParticipantListener(BridgeContainer container)
    {
        BridgedParticipantListener::container = container;
    }
};
