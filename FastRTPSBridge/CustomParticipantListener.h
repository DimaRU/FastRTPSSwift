//
//  CustomParticipantListener.h
//  TestFastRTPS
//
//  Created by Dmitriy Borovikov on 29/07/2019.
//  Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//

#ifndef CustomParticipantListener_h
#define CustomParticipantListener_h

#include <fastrtps/fastrtps_fwd.h>
#include <fastrtps/subscriber/SampleInfo.h>
#include <fastrtps/rtps/participant/RTPSParticipantListener.h>

using namespace eprosima::fastrtps;
using namespace eprosima::fastrtps::rtps;
		
class CustomParticipantListener: public eprosima::fastrtps::rtps::RTPSParticipantListener
{
    void onParticipantDiscovery(RTPSParticipant *participant, ParticipantDiscoveryInfo &&info) override;
    void onReaderDiscovery(RTPSParticipant *participant, ReaderDiscoveryInfo &&info) override;
    void onWriterDiscovery(RTPSParticipant *participant, WriterDiscoveryInfo &&info) override;
    void DumpLocators(ResourceLimitedVector<eprosima::fastrtps::rtps::Locator_t> locators);
};

#endif /* CustomParticipantListener_h */
