//
//  RovTopicListener.cpp
//  TestIntegration
//
//  Created by Dmitriy Borovikov on 21/08/2019.
//  Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//

#include "RovTopicListener.h"

#include <fastrtps/rtps/reader/RTPSReader.h>
#include <fastrtps/rtps/history/ReaderHistory.h>
#include <fastrtps/log/Log.h>

using namespace eprosima::fastrtps;
using namespace eprosima::fastrtps::rtps;

RovTopicListener::RovTopicListener(const char* topicName, NSObject<PayloadDecoderInterface>* payloadDecoder): n_matched(0)
{
    RovTopicListener::topicName = std::string(topicName);
    RovTopicListener::payloadDecoder = payloadDecoder;
}

RovTopicListener::~RovTopicListener()
{
}

void RovTopicListener::onNewCacheChangeAdded(RTPSReader* reader, const CacheChange_t * const change)
{
    [payloadDecoder decodeWithSequence:change->sequenceNumber.to64long()
                           payloadSize:change->serializedPayload.length
                               payload:change->serializedPayload.data];
    reader->getHistory()->remove_change((CacheChange_t*)change);
}

void RovTopicListener::on_liveliness_changed(RTPSReader *reader, const LivelinessChangedStatus &status)
{
    logWarning(READER_LISTENER, "Liveliness: " << status.alive_count_change)
}

void RovTopicListener::onReaderMatched(RTPSReader* reader, MatchingInfo& info)
{
    switch (info.status)
    {
        case MATCHED_MATCHING:
            n_matched++;
            logWarning(READER_LISTENER, "\tReader matched:" << topicName << " count: " << n_matched)
            break;
        case REMOVED_MATCHING:
            n_matched--;
            logWarning(READER_LISTENER, "\tReader remove matched:" << topicName << " count: " << n_matched)
            break;
    }
}
