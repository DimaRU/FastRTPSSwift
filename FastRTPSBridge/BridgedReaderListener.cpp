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

BridgedReaderListener::BridgedReaderListener(const char* topicName, decoderCallback callback, const void * payloadDecoder): n_matched(0)
{
    BridgedReaderListener::topicName = std::string(topicName);
    BridgedReaderListener::callback = callback;
    BridgedReaderListener::payloadDecoder = payloadDecoder;
}

BridgedReaderListener::~BridgedReaderListener()
{
}

void BridgedReaderListener::onNewCacheChangeAdded(RTPSReader* reader, const CacheChange_t * const change)
{
    if (change->serializedPayload.length > 4) {
        (*callback)(const_cast<void * _Nonnull>(payloadDecoder),
                    change->sequenceNumber.to64long(),
                    change->serializedPayload.length - 4,
                    change->serializedPayload.data + 4);
    }
    reader->getHistory()->remove_change((CacheChange_t*)change);
}

void BridgedReaderListener::on_liveliness_changed(RTPSReader *reader, const LivelinessChangedStatus &status)
{
//    NSMutableDictionary *notificationDictionary = [[NSMutableDictionary alloc] init];
//    notificationDictionary[@(RTPSNotificationUserInfoTopic)] = [[NSString alloc] initWithCString:topicName.c_str() encoding:NSUTF8StringEncoding];
//    notificationDictionary[@(RTPSNotificationUserInfoReason)] = @(RTPSReaderWriterNotificationReasonReaderLivelinessLost);
//    [NSNotificationCenter.defaultCenter postNotificationName:RTPSReaderWriterNotificationName object:NULL userInfo:notificationDictionary];
}

void BridgedReaderListener::onReaderMatched(RTPSReader* reader, MatchingInfo& info)
{
//    NSMutableDictionary *notificationDictionary = [[NSMutableDictionary alloc] init];
//    notificationDictionary[@(RTPSNotificationUserInfoTopic)] = [[NSString alloc] initWithCString:topicName.c_str() encoding:NSUTF8StringEncoding];
    switch (info.status)
    {
        case MATCHED_MATCHING:
            n_matched++;
//            notificationDictionary[@(RTPSNotificationUserInfoReason)] = @(RTPSReaderWriterNotificationReasonReaderMatchedMatching);
            break;
        case REMOVED_MATCHING:
            n_matched--;
//            notificationDictionary[@(RTPSNotificationUserInfoReason)] = @(RTPSReaderWriterNotificationReasonReaderRemovedMatching);
            break;
    }
//    [NSNotificationCenter.defaultCenter postNotificationName:RTPSReaderWriterNotificationName object:NULL userInfo:notificationDictionary];
}
