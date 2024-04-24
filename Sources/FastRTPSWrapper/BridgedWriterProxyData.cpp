/////
////  BridgedWriterProxyData.cpp
///   Copyright © 2024 Dmitriy Borovikov. All rights reserved.
//

#include "BridgedWriterProxyData.h"

using namespace eprosima::fastrtps;

void dumpLocators(ResourceLimitedVector<rtps::Locator_t> locators, std::ostringstream& stream);

std::string BridgedWriterProxyData::getUnicastLocators() {
    std::ostringstream stream;
    
    dumpLocators(info.remote_locators().unicast, stream);
    return stream.str();
}

std::string BridgedWriterProxyData::getMutlicastLocators() {
    std::ostringstream stream;
    
    dumpLocators(info.remote_locators().multicast, stream);
    return stream.str();
}

std::string BridgedWriterProxyData::getGuid() {
    std::ostringstream stream;

    stream << info.guid();
    return stream.str();
}
