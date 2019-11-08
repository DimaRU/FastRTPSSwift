/////
////  BridgedWriterListener.cpp
///   Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//

#include <fastrtps/log/Log.h>
#include "BridgedWriterListener.h"

using namespace eprosima::fastrtps;
using namespace eprosima::fastrtps::rtps;

BridgedWriterListener::BridgedWriterListener(const char* topicName)
{
    BridgedWriterListener::n_matched = 0;
    BridgedWriterListener::topicName = std::string(topicName);
}

BridgedWriterListener::~BridgedWriterListener()
{
}

void BridgedWriterListener::on_liveliness_lost(RTPSWriter* writer, const LivelinessLostStatus& status)
{
    logWarning(WRITER_LISTENER, "Writer liveliness lost:" << status.total_count);
}

void BridgedWriterListener::onWriterMatched(RTPSWriter* writer, MatchingInfo& info)
{
    switch (info.status)
    {
        case MATCHED_MATCHING:
            n_matched++;
            logWarning(WRITER_LISTENER, "\tWriter matched:" << topicName << " count: " << n_matched)
            break;
        case REMOVED_MATCHING:
            n_matched--;
            logWarning(WRITER_LISTENER, "\tWriter remove matched:" << topicName << " count: " << n_matched)
            break;
    }
}
