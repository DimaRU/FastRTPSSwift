//
//  RovWriterListener.cpp
//  TridentVideoViewer
//
//  Created by Dmitriy Borovikov on 13.09.2019.
//  Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//

#include <fastrtps/log/Log.h>
#include "RovWriterListener.h"

using namespace eprosima::fastrtps;
using namespace eprosima::fastrtps::rtps;

RovWriterListener::RovWriterListener(const char* topicName)
{
    RovWriterListener::n_matched = 0;
    RovWriterListener::topicName = std::string(topicName);
}

RovWriterListener::~RovWriterListener()
{
}

void RovWriterListener::on_liveliness_lost(RTPSWriter* writer, const LivelinessLostStatus& status)
{
    logWarning(WRITER_LISTENER, "Writer liveliness lost:" << status.total_count);
}

void RovWriterListener::onWriterMatched(RTPSWriter* writer, MatchingInfo& info)
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
