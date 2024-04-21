/////
////  BridgedParticipantProxyData.h
///   Copyright © 2024 Dmitriy Borovikov. All rights reserved.
//

#pragma once

#include <fastrtps/rtps/writer/WriterListener.h>
#include <fastrtps/rtps/participant/RTPSParticipantListener.h>
#include <swift/bridging>

using namespace eprosima::fastrtps::rtps;

class BridgedParticipantProxyData {
    const ParticipantProxyData& info;
    eprosima::fastrtps::ParameterPropertyList_t::const_iterator iterator;
    
public:
    BridgedParticipantProxyData(const ParticipantProxyData& data)
    : info(data), iterator(nullptr)
    {
    }

    const char* participantName() { return info.m_participantName.c_str(); }
    std::string getUnicastLocators();
    std::string getMutlicastLocators();
    void beginIteration() { iterator = info.m_properties.begin(); }
    void nextIteration() { iterator++; }
    const std::pair<const std::string, const std::string> pair() { return iterator->pair(); }
    uint16_t propertiesCount() { return info.m_properties.size(); }
};
