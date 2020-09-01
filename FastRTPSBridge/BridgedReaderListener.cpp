/////
////  BridgedReaderListener.cpp
///   Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//

#include "BridgedReaderListener.h"

#include <fastrtps/rtps/reader/RTPSReader.h>
#include <fastrtps/rtps/history/ReaderHistory.h>
#include <fastrtps/log/Log.h>

using namespace eprosima::fastrtps;
using namespace eprosima::fastrtps::rtps;

void readerWriterListenerCallback(int reason, const char *topicName);
BridgedReaderListener::BridgedReaderListener(const char* topicName, DecoderCallback callback, const void * payloadDecoder): n_matched(0)
{
    BridgedReaderListener::topicName = std::string(topicName);
    BridgedReaderListener::decoderCallback = callback;
    BridgedReaderListener::payloadDecoder = payloadDecoder;
}

BridgedReaderListener::~BridgedReaderListener()
{
}

void BridgedReaderListener::onNewCacheChangeAdded(RTPSReader* reader, const CacheChange_t * const change)
{
    if (change->serializedPayload.length > 4) {
        (*decoderCallback)(const_cast<void * _Nonnull>(payloadDecoder),
                    change->sequenceNumber.to64long(),
                    change->serializedPayload.length - 4,
                    change->serializedPayload.data + 4);
    }
    reader->getHistory()->remove_change((CacheChange_t*)change);
}

void BridgedReaderListener::on_liveliness_changed(RTPSReader *reader, const LivelinessChangedStatus &status)
{
    readerWriterListenerCallback(RTPSNotificationReaderLivelinessLost, topicName.c_str());
}

void BridgedReaderListener::onReaderMatched(RTPSReader* reader, MatchingInfo& info)
{
    switch (info.status)
    {
        case MATCHED_MATCHING:
            n_matched++;
            readerWriterListenerCallback(RTPSNotificationReaderMatchedMatching, topicName.c_str());
            break;
        case REMOVED_MATCHING:
            n_matched--;
            readerWriterListenerCallback(RTPSNotificationReaderRemovedMatching, topicName.c_str());
            break;
    }
}
