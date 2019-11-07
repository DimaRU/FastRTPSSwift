/////
////  RovWriterListener.h
///   Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//

#ifndef RovWriterListener_h
#define RovWriterListener_h

#include <fastrtps/rtps/writer/RTPSWriter.h>
#include <fastrtps/rtps/writer/WriterListener.h>
#include <fastrtps/rtps/history/WriterHistory.h>

class RovWriterListener :public eprosima::fastrtps::rtps::WriterListener
{
public:
    RovWriterListener(const char* topicName);
    ~RovWriterListener();
    void onWriterMatched(eprosima::fastrtps::rtps::RTPSWriter*, eprosima::fastrtps::rtps::MatchingInfo& info);
    void on_liveliness_lost(eprosima::fastrtps::rtps::RTPSWriter* writer, const eprosima::fastrtps::LivelinessLostStatus& status);
    int n_matched;
    std::string topicName;
};

#endif /* RovWriterListener_h */
