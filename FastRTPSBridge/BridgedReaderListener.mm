/////
////  BridgedReaderListener.cpp
///   Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//

#include "BridgedReaderListener.h"

#include <fastrtps/rtps/reader/RTPSReader.h>
#include <fastrtps/rtps/history/ReaderHistory.h>
#include <fastrtps/log/Log.h>
#import "FastRTPSBridge.h"

using namespace eprosima::fastrtps;
using namespace eprosima::fastrtps::rtps;

BridgedReaderListener::BridgedReaderListener(const char* topicName, NSObject<PayloadDecoderInterface>* payloadDecoder): n_matched(0)
{
    BridgedReaderListener::topicName = std::string(topicName);
    BridgedReaderListener::payloadDecoder = payloadDecoder;
}

BridgedReaderListener::~BridgedReaderListener()
{
}

void BridgedReaderListener::onNewCacheChangeAdded(RTPSReader* reader, const CacheChange_t * const change)
{
    [payloadDecoder decodeWithSequence:change->sequenceNumber.to64long()
                           payloadSize:change->serializedPayload.length
                               payload:change->serializedPayload.data];
    reader->getHistory()->remove_change((CacheChange_t*)change);
}

void BridgedReaderListener::on_liveliness_changed(RTPSReader *reader, const LivelinessChangedStatus &status)
{
    NSMutableDictionary *notificationDictionary = [[NSMutableDictionary alloc] init];
    notificationDictionary[@(RTPSNotificationUserInfoTopic)] = [[NSString alloc] initWithCString:topicName.c_str() encoding:NSUTF8StringEncoding];
    notificationDictionary[@(RTPSNotificationUserInfoReason)] = @(RTPSReaderWriterNotificationReasonReaderLivelinessLost);
    [NSNotificationCenter.defaultCenter postNotificationName:RTPSReaderWriterNotificationName object:NULL userInfo:notificationDictionary];
    logInfo(READER_LISTENER, "Liveliness: " << status.alive_count_change)
}

void BridgedReaderListener::onReaderMatched(RTPSReader* reader, MatchingInfo& info)
{
    NSMutableDictionary *notificationDictionary = [[NSMutableDictionary alloc] init];
    notificationDictionary[@(RTPSNotificationUserInfoTopic)] = [[NSString alloc] initWithCString:topicName.c_str() encoding:NSUTF8StringEncoding];
    switch (info.status)
    {
        case MATCHED_MATCHING:
            n_matched++;
            notificationDictionary[@(RTPSNotificationUserInfoReason)] = @(RTPSReaderWriterNotificationReasonReaderMatchedMatching);
            logInfo(READER_LISTENER, "\tReader matched:" << topicName << " count: " << n_matched)
            break;
        case REMOVED_MATCHING:
            n_matched--;
            notificationDictionary[@(RTPSNotificationUserInfoReason)] = @(RTPSReaderWriterNotificationReasonReaderRemovedMatching);
            logInfo(READER_LISTENER, "\tReader remove matched:" << topicName << " count: " << n_matched)
            break;
    }
    [NSNotificationCenter.defaultCenter postNotificationName:RTPSReaderWriterNotificationName object:NULL userInfo:notificationDictionary];
}
