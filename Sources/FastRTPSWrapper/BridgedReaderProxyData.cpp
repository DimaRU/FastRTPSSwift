/////
////  BridgedReaderProxyData.cpp
///   Copyright © 2024 Dmitriy Borovikov. All rights reserved.
//

#include "BridgedReaderProxyData.h"

using namespace eprosima::fastrtps;

void dumpLocators(ResourceLimitedVector<rtps::Locator_t> locators, std::ostringstream& stream)
{
    for (int i = 0; i < locators.size(); i++) {
        if (i != 0) {
            stream << ",";
        }
        stream << locators[i];
    }
}

std::string BridgedReaderProxyData::getUnicastLocators() {
    std::ostringstream stream;
    
    dumpLocators(info.remote_locators().unicast, stream);
    return stream.str();
}

std::string BridgedReaderProxyData::getMutlicastLocators() {
    std::ostringstream stream;
    
    dumpLocators(info.remote_locators().multicast, stream);
    return stream.str();
}

std::string BridgedReaderProxyData::getGuid() {
    std::ostringstream stream;

    stream << info.guid();
    return stream.str();
}
