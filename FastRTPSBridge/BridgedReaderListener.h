/////
////  BridgedReaderListener.h
///   Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//

#pragma once

#include <stdio.h>
#include "fastrtps/rtps/rtps_fwd.h"
#include "fastrtps/rtps/reader/ReaderListener.h"
#include "FastRTPSBridge.h"

class BridgedReaderListener:public eprosima::fastrtps::rtps::ReaderListener
{
public:
    BridgedReaderListener(const char* topicName, DecoderCallback callback, const void * payloadDecoder);
    ~BridgedReaderListener();
    void onNewCacheChangeAdded(eprosima::fastrtps::rtps::RTPSReader* reader,
                               const eprosima::fastrtps::rtps::CacheChange_t* const change) override;
    void onReaderMatched(eprosima::fastrtps::rtps::RTPSReader*,
                         eprosima::fastrtps::rtps::MatchingInfo& info) override;
    void on_liveliness_changed(eprosima::fastrtps::rtps::RTPSReader *reader,
                               const eprosima::fastrtps::LivelinessChangedStatus &status) override;
    
    const void * payloadDecoder;
    DecoderCallback decoderCallback;
    uint32_t n_matched;
    std::string topicName;
};
