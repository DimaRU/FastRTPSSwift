/////
////  FastRTPSWrapper.cpp
///   Copyright © 2020 Dmitriy Borovikov. All rights reserved.
//


#include "FastRTPSDefs.h"
#include "BridgedParticipant.h"
#include <fastrtps/log/Log.h>
#include "CustomLogConsumer.h"

const char * _Nonnull fastDDSVersionString(void)
{
    return FASTRTPS_VERSION_STR;
}

using namespace eprosima::fastdds::dds;

void setRTPSLoglevel(enum FastRTPSLogLevel logLevel)
{
    Log::ClearConsumers();
    Log::RegisterConsumer(std::unique_ptr<LogConsumer>(new eprosima::fastdds::dds::CustomLogConsumer));
    switch (logLevel) {
        case FastRTPSLogLevelError:
            Log::SetVerbosity(Log::Kind::Error);
            break;
        case FastRTPSLogLevelWarning:
            Log::SetVerbosity(Log::Kind::Warning);
            break;
        case FastRTPSLogLevelInfo:
            Log::SetVerbosity(Log::Kind::Info);
            break;
    }
    Log::ReportFilenames(true);
}
