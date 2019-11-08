/////
////  BridgedReaderTopicListener.cpp
///   Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//

#include "BridgedReaderTopicListener.h"

#include <fastrtps/rtps/reader/RTPSReader.h>
#include <fastrtps/rtps/history/ReaderHistory.h>
#include <fastrtps/log/Log.h>

using namespace eprosima::fastrtps;
using namespace eprosima::fastrtps::rtps;

BridgedReaderTopicListener::BridgedReaderTopicListener(const char* topicName, NSObject<PayloadDecoderInterface>* payloadDecoder): n_matched(0)
{
    BridgedReaderTopicListener::topicName = std::string(topicName);
    BridgedReaderTopicListener::payloadDecoder = payloadDecoder;
}

BridgedReaderTopicListener::~BridgedReaderTopicListener()
{
}

void BridgedReaderTopicListener::onNewCacheChangeAdded(RTPSReader* reader, const CacheChange_t * const change)
{
    [payloadDecoder decodeWithSequence:change->sequenceNumber.to64long()
                           payloadSize:change->serializedPayload.length
                               payload:change->serializedPayload.data];
    reader->getHistory()->remove_change((CacheChange_t*)change);
}

void BridgedReaderTopicListener::on_liveliness_changed(RTPSReader *reader, const LivelinessChangedStatus &status)
{
    logWarning(READER_LISTENER, "Liveliness: " << status.alive_count_change)
}

void BridgedReaderTopicListener::onReaderMatched(RTPSReader* reader, MatchingInfo& info)
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
