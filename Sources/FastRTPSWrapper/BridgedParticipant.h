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

#pragma clang assume_nonnull begin

class BridgedParticipant
{

    RTPSParticipant* mp_participant;
    BridgedParticipantListener* mp_listener;
    BridgeContainer container;
public:
    BridgedParticipant();
    virtual ~BridgedParticipant();
    void setContainer(BridgeContainer container);

    bool createParticipant(const char* name,
                           const uint32_t domain,
                           const RTPSParticipantProfile* _Nullable participantProfile,
                           const char * _Nullable interfaceIPv4);
    
    RTPSReader* _Nullable addReader(const char* name,
                                    const char* dataType,
                                    const RTPSReaderProfile readerProfile,
                                    const void * payloadDecoder,
                                    const char * _Nullable partition);
    
    bool removeReader(RTPSReader* reader);
    
    RTPSWriter* _Nullable addWriter(const char* name,
                                    const char* dataType,
                                    const RTPSWriterProfile writerProfile,
                                    const char * _Nullable partition);
    
    bool removeWriter(RTPSWriter* writer);
    bool send(RTPSWriter* writer, const uint8_t* data, uint32_t length, const void* _Nullable key, uint32_t keyLength);
    void stopAll();
    void removeRTPSParticipant();
};

#pragma clang assume_nonnull end
