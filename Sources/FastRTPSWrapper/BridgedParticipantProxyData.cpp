/////
////  BridgedParticipantProxyData.cpp
///   Copyright © 2024 Dmitriy Borovikov. All rights reserved.
//

#include "BridgedParticipantProxyData.h"

using namespace eprosima::fastrtps;

void dumpLocators(ResourceLimitedVector<rtps::Locator_t> locators, std::ostringstream& stream);

std::string BridgedParticipantProxyData::getUnicastLocators() {
    std::ostringstream stream;
    
    dumpLocators(info.default_locators.unicast, stream);
    return stream.str();
}

std::string BridgedParticipantProxyData::getMutlicastLocators() {
    std::ostringstream stream;
    
    dumpLocators(info.default_locators.multicast, stream);
    return stream.str();
}

std::string BridgedParticipantProxyData::getGuid() {
    std::ostringstream stream;

    stream << info.m_guid;
    return stream.str();
}
