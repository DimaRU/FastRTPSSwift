/////
////  BridgedReaderListener.h
///   Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//

#pragma once

#include "FastRTPSDefs.h"
#include "fastrtps/rtps/rtps_fwd.h"
#include <fastrtps/rtps/reader/RTPSReader.h>
#include <fastrtps/rtps/reader/ReaderListener.h>
#include <fastrtps/rtps/history/ReaderHistory.h>

using namespace eprosima::fastrtps::rtps;

class BridgedReaderListener :public ReaderListener
{
    void onNewCacheChangeAdded(RTPSReader* reader,
                               const CacheChange_t* const change) override;
    void onReaderMatched(RTPSReader*,
                         MatchingInfo& info) override;
    void on_liveliness_changed(RTPSReader *reader,
                               const eprosima::fastdds::dds::LivelinessChangedStatus &status) override;
public:
    BridgedReaderListener(const char* topicName,
                          const void * payloadDecoder,
                          BridgeContainer container,
                          ReaderHistory* history);
    ~BridgedReaderListener();
    
    const void * payloadDecoder;
    uint32_t n_matched;
    std::string topicName;
    BridgeContainer container;
    ReaderHistory* history;
};
