/////
////  BridgedWriterListener.cpp
///   Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//

#include "BridgedWriterListener.h"
#include <fastrtps/log/Log.h>
#import "FastRTPSBridge.h"

using namespace eprosima::fastrtps;
using namespace eprosima::fastrtps::rtps;

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
    NSMutableDictionary *notificationDictionary = [[NSMutableDictionary alloc] init];
    notificationDictionary[@(RTPSNotificationUserInfoTopic)] = [[NSString alloc] initWithCString:topicName.c_str() encoding:NSUTF8StringEncoding];
    notificationDictionary[@(RTPSNotificationUserInfoReason)] = @(RTPSReaderWriterNotificationReasonWriterLivelinessLost);
    [NSNotificationCenter.defaultCenter postNotificationName:RTPSReaderWriterNotificationName object:NULL userInfo:notificationDictionary];
    logInfo(WRITER_LISTENER, "Writer liveliness lost:" << status.total_count);
}

void BridgedWriterListener::onWriterMatched(RTPSWriter* writer, MatchingInfo& info)
{
    NSMutableDictionary *notificationDictionary = [[NSMutableDictionary alloc] init];
    notificationDictionary[@(RTPSNotificationUserInfoTopic)] = [[NSString alloc] initWithCString:topicName.c_str() encoding:NSUTF8StringEncoding];
    switch (info.status)
    {
        case MATCHED_MATCHING:
            n_matched++;
            notificationDictionary[@(RTPSNotificationUserInfoReason)] = @(RTPSReaderWriterNotificationReasonWriterMatchedMatching);
            logInfo(WRITER_LISTENER, "\tWriter matched:" << topicName << " count: " << n_matched)
            break;
        case REMOVED_MATCHING:
            n_matched--;
            notificationDictionary[@(RTPSNotificationUserInfoReason)] = @(RTPSReaderWriterNotificationReasonWriterRemovedMatching);
            logInfo(WRITER_LISTENER, "\tWriter remove matched:" << topicName << " count: " << n_matched)
            break;
    }
    [NSNotificationCenter.defaultCenter postNotificationName:RTPSReaderWriterNotificationName object:NULL userInfo:notificationDictionary];
}
