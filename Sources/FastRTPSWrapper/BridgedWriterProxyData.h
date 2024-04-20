/////
////  BridgedWriterProxyData.h
///   Copyright © 2024 Dmitriy Borovikov. All rights reserved.
//

#pragma once

#include <fastrtps/rtps/writer/WriterListener.h>
#include <fastrtps/rtps/participant/RTPSParticipantListener.h>
#include <swift/bridging>

using namespace eprosima::fastrtps::rtps;

class BridgedWriterProxyData {
    const WriterProxyData& info;
    
public:
    BridgedWriterProxyData(const WriterProxyData& data)
    : info(data)
    {
    }

    const char *topicName() { return info.topicName(); }
    const char *typeName() { return info.typeName(); }
    uint32_t reliability() { return info.m_qos.m_reliability.kind; }
    uint32_t durability() { return info.m_qos.m_durability.kind; }
    bool keyed() { return info.topicKind() == eprosima::fastrtps::rtps::WITH_KEY; }
    bool disable_positive_acks() { return info.m_qos.m_disablePositiveACKs.enabled; }
    std::string getUnicastLocators();
    std::string getMutlicastLocators();
};
