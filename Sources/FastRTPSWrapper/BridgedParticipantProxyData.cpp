/////
////  BridgedParticipantProxyData.cpp
///   Copyright © 2024 Dmitriy Borovikov. All rights reserved.
//

#include "BridgedParticipantProxyData.h"

using namespace eprosima::fastrtps;

//std::ostringstream stream;
//const char** propDict;
//auto properties = info.info.m_properties;
//auto count = properties.size();
//int i = 0;
//
//switch(info.status) {
//    case ParticipantDiscoveryInfo::DISCOVERED_PARTICIPANT:
//        propDict = new const char*[count * 2 + 1];
//        
//        for (auto prop = properties.begin(); prop != properties.end(); prop++) {
//            propDict[i++] = strdup(prop->first().c_str());
//            propDict[i++] = strdup(prop->second().c_str());
//        }
//        propDict[i] = nullptr;
//        container.discoveryParticipantCallback(container.listnerObject, info.status, info.info.m_participantName, stream.str().c_str(), propDict);
//        do {
//            free((void *)propDict[i--]);
//        } while (i != 0);
//        delete [] propDict;
//        break;
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
