/////
////  BridgedParticipantListener.h
///   Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//

#pragma once

#include "FastRTPSDefs.h"
#include <fastrtps/fastrtps_fwd.h>
#include <fastrtps/rtps/participant/RTPSParticipantListener.h>

using namespace eprosima::fastrtps;
using namespace eprosima::fastrtps::rtps;
		
class BridgedParticipantListener: public RTPSParticipantListener
{
    void onParticipantDiscovery(RTPSParticipant *participant, ParticipantDiscoveryInfo &&info) override;
    void onReaderDiscovery(RTPSParticipant *participant, ReaderDiscoveryInfo &&info) override;
    void onWriterDiscovery(RTPSParticipant *participant, WriterDiscoveryInfo &&info) override;
    BridgeContainer container;
public:
    BridgedParticipantListener(BridgeContainer container)
    {
        BridgedParticipantListener::container = container;
    }
};
