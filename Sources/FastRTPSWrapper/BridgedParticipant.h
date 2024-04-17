/////
////  BridgedParticipant.h
///   Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//

#pragma once

#include "FastRTPSDefs.h"
#include <fastrtps/rtps/RTPSDomain.h>
#include <fastrtps/rtps/participant/RTPSParticipant.h>
#include <fastrtps/rtps/reader/RTPSReader.h>
#include <fastrtps/rtps/writer/RTPSWriter.h>
#include <map>

using namespace eprosima::fastrtps::rtps;

class BridgedParticipantListener;

class BridgedParticipant
{

    RTPSParticipant* mp_participant;
    BridgedParticipantListener* mp_listener;
    BridgeContainer container;
    std::map<std::string, RTPSReader*> readerList;
    std::map<std::string, RTPSWriter*> writerList;
public:
    BridgedParticipant();
    virtual ~BridgedParticipant();
    void setContainer(BridgeContainer container);

    bool createParticipant(const char* name,
                           const uint32_t domain,
                           const RTPSParticipantProfile* participantProfile,
                           const char *interfaceIPv4);
    
    bool addReader(const char* name,
                   const char* dataType,
                   const RTPSReaderProfile readerProfile,
                   const void * payloadDecoder,
                   const char * partition);
    
    bool removeReader(const char* name);
    
    bool addWriter(const char* name,
                   const char* dataType,
                   const RTPSWriterProfile writerProfile,
                   const char * partition);
    
    bool removeWriter(const char* name);
    bool send(const char* name, const uint8_t* data, uint32_t length, const void* key, uint32_t keyLength);
    void resignAll();
    void stopAll();
    void removeRTPSParticipant();
};
