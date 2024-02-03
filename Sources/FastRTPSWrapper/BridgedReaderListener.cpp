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

BridgedReaderListener::BridgedReaderListener(const char* topicName,
                                             const void * payloadDecoder,
                                             BridgeContainer container)
{
    BridgedReaderListener::n_matched = 0;
    BridgedReaderListener::topicName = std::string(topicName);
    BridgedReaderListener::payloadDecoder = payloadDecoder;
    BridgedReaderListener::container = container;
}

BridgedReaderListener::~BridgedReaderListener()
{
}

void BridgedReaderListener::onNewCacheChangeAdded(RTPSReader* reader, const CacheChange_t * const change)
{
    if (change->serializedPayload.length > 4) {
        container.decoderCallback(const_cast<void * _Nonnull>(payloadDecoder),
                                  change->sequenceNumber.to64long(),
                                  change->serializedPayload.length - 4,
                                  change->serializedPayload.data + 4);
    }
    reader->getHistory()->remove_change((CacheChange_t*)change);
}

void BridgedReaderListener::on_liveliness_changed(RTPSReader *reader, const LivelinessChangedStatus &status)
{
    container.readerWriterListenerCallback(container.listnerObject, RTPSStatusReaderLivelinessLost, topicName.c_str());
}

void BridgedReaderListener::onReaderMatched(RTPSReader* reader, MatchingInfo& info)
{
    switch (info.status)
    {
        case MATCHED_MATCHING:
            n_matched++;
            container.readerWriterListenerCallback(container.listnerObject, RTPSStatusReaderMatchedMatching, topicName.c_str());
            break;
        case REMOVED_MATCHING:
            n_matched--;
            container.readerWriterListenerCallback(container.listnerObject, RTPSStatusReaderRemovedMatching, topicName.c_str());
            break;
    }
}
