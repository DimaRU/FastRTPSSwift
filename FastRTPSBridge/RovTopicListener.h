/////
////  RovTopicListener.h
///   Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//

#ifndef ORovTopicListener_h
#define ORovTopicListener_h

#include <stdio.h>
#include "fastrtps/rtps/rtps_fwd.h"
#include "fastrtps/rtps/reader/ReaderListener.h"
#import "FastRTPSBridge/FastRTPSBridge-Swift.h"


class RovTopicListener:public eprosima::fastrtps::rtps::ReaderListener
{
public:
    RovTopicListener(const char* topicName, NSObject<PayloadDecoderInterface>* payloadDecoder);
    ~RovTopicListener();
    void onNewCacheChangeAdded(eprosima::fastrtps::rtps::RTPSReader* reader,
                               const eprosima::fastrtps::rtps::CacheChange_t* const change) override;
    void onReaderMatched(eprosima::fastrtps::rtps::RTPSReader*,
                         eprosima::fastrtps::rtps::MatchingInfo& info) override;
    void on_liveliness_changed(eprosima::fastrtps::rtps::RTPSReader *reader,
                               const eprosima::fastrtps::LivelinessChangedStatus &status) override;
    
    NSObject<PayloadDecoderInterface>* payloadDecoder;
    uint32_t n_matched;
    std::string topicName;
};

#endif /* ORovTopicListener_h */
