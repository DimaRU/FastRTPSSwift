/////
////  BridgedWriterListener.cpp
///   Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//

#include "BridgedWriterListener.h"
#include <fastrtps/log/Log.h>

using namespace eprosima::fastrtps;
using namespace eprosima::fastrtps::rtps;

void readerWriterListenerCallback(int reason, const char *topicName);

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
    readerWriterListenerCallback(RTPSNotificationWriterLivelinessLost, topicName.c_str());
}

void BridgedWriterListener::onWriterMatched(RTPSWriter* writer, MatchingInfo& info)
{
    switch (info.status)
    {
        case MATCHED_MATCHING:
            n_matched++;
            readerWriterListenerCallback(RTPSNotificationWriterMatchedMatching, topicName.c_str());
            break;
        case REMOVED_MATCHING:
            n_matched--;
            readerWriterListenerCallback(RTPSNotificationWriterRemovedMatching, topicName.c_str());
            break;
    }
}
