/////
////  RovParticipant.h
///   Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//

#pragma once

#include <fastrtps/rtps/rtps_fwd.h>
#include <fastrtps/rtps/common/Types.h>
#include <fastrtps/rtps/attributes/WriterAttributes.h>
#include <fastrtps/rtps/reader/RTPSReader.h>
#include "fastrtps/rtps/writer/RTPSWriter.h"
#include <fastrtps/rtps/history/ReaderHistory.h>
#include "fastrtps/rtps/history/WriterHistory.h"
#include <string>
#include <map>
#import "RovTopicListener.h"
#import "RovWriterListener.h"

class CustomParticipantListener;
class RovParticipant
{
    struct ReaderInfo {
        eprosima::fastrtps::rtps::RTPSReader* reader;
        eprosima::fastrtps::rtps::ReaderHistory* history;
        RovTopicListener* listener;
        ~ReaderInfo() {
            delete history;
            delete listener;
        }
    };

    struct WriterInfo {
        eprosima::fastrtps::rtps::RTPSWriter* writer;
        eprosima::fastrtps::rtps::WriterHistory* history;
        RovWriterListener* listener;
        ~WriterInfo() {
            delete history;
            delete listener;
        }
    };
public:
    RovParticipant();
    virtual ~RovParticipant();
    eprosima::fastrtps::rtps::RTPSParticipant* mp_participant;
    CustomParticipantListener* mp_listener;
    
    std::map<std::string, ReaderInfo*> readerList;
    std::map<std::string, WriterInfo*> writerList;

    bool startRTPS(); //Initialization
    bool addReader(const char* name,
                   const char* dataType,
                   const bool keyed,
                   NSObject<PayloadDecoderInterface>* payloadDecoder);
    bool removeReader(const char* name);
    
    bool addWriter(const char* name,
                   const char* dataType,
                   const bool keyed);
    bool removeWriter(const char* name);
    bool send(const char* name, const uint8_t* data, uint32_t length, const void* key, uint32_t keyLength);
    void resignAll();
};
