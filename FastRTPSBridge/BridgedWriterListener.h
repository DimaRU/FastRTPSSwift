/////
////  BridgedWriterListener.h
///   Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//

#pragma once

#include <fastrtps/rtps/writer/RTPSWriter.h>
#include <fastrtps/rtps/writer/WriterListener.h>
#include <fastrtps/rtps/history/WriterHistory.h>
#include "FastRTPSBridge.h"

class BridgedWriterListener :public eprosima::fastrtps::rtps::WriterListener
{
    void onWriterMatched(eprosima::fastrtps::rtps::RTPSWriter*, eprosima::fastrtps::rtps::MatchingInfo& info);
    void on_liveliness_lost(eprosima::fastrtps::rtps::RTPSWriter* writer, const eprosima::fastrtps::LivelinessLostStatus& status);
    ReaderWriterListenerCallback readerWriterListenerCallback;
public:
    BridgedWriterListener(const char* topicName, BridgeContainer container);
    ~BridgedWriterListener();
    int n_matched;
    std::string topicName;
    BridgeContainer container;
};
