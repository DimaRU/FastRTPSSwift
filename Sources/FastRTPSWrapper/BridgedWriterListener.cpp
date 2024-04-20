/////
////  BridgedWriterListener.cpp
///   Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//

#include "BridgedWriterListener.h"
#include <fastrtps/log/Log.h>

using namespace eprosima::fastrtps;
using namespace eprosima::fastrtps::rtps;

BridgedWriterListener::BridgedWriterListener(const char* topicName, BridgeContainer container, WriterHistory* history)
{
    BridgedWriterListener::n_matched = 0;
    BridgedWriterListener::topicName = std::string(topicName);
    BridgedWriterListener::container = container;
    BridgedWriterListener::history = history;
}

BridgedWriterListener::~BridgedWriterListener()
{
    delete history;
}

void BridgedWriterListener::on_liveliness_lost(RTPSWriter* writer, const LivelinessLostStatus& status)
{
    container.writerListenerCallback(container.listnerObject, RTPSWriterStatusLivelinessLost, topicName.c_str());
}

void BridgedWriterListener::onWriterMatched(RTPSWriter* writer, MatchingInfo& info)
{
    switch (info.status)
    {
        case MATCHED_MATCHING:
            n_matched++;
            container.writerListenerCallback(container.listnerObject, RTPSWriterStatusMatchedMatching, topicName.c_str());
            break;
        case REMOVED_MATCHING:
            n_matched--;
            container.writerListenerCallback(container.listnerObject, RTPSWriterStatusRemovedMatching, topicName.c_str());
            break;
    }
}
