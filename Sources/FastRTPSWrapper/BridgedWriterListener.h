/////
////  BridgedWriterListener.h
///   Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//

#pragma once

#include "FastRTPSDefs.h"
#include <fastrtps/rtps/writer/RTPSWriter.h>
#include <fastrtps/rtps/writer/WriterListener.h>
#include <fastrtps/rtps/history/WriterHistory.h>

using namespace eprosima::fastrtps::rtps;

class BridgedWriterListener :public WriterListener
{
    void onWriterMatched(RTPSWriter*, MatchingInfo& info);
    void on_liveliness_lost(RTPSWriter* writer, const eprosima::fastrtps::LivelinessLostStatus& status);
public:
    BridgedWriterListener(const char* topicName, BridgeContainer container, WriterHistory* history);
    ~BridgedWriterListener();
    int n_matched;
    std::string topicName;
    BridgeContainer container;
    WriterHistory* history;
};
