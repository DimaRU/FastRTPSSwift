/////
////  FastRTPSWrapper.cpp
///   Copyright © 2020 Dmitriy Borovikov. All rights reserved.
//


#include "FastRTPSWrapper.h"
#include "BridgedParticipant.h"
#include <fastrtps/log/Log.h>
#include "CustomLogConsumer.h"
#include <fastrtps/utils/IPFinder.h>

using namespace eprosima;
using namespace fastrtps;
using namespace rtps;
using namespace std;

const char * _Nonnull fastDDSVersion(void)
{
    return FASTRTPS_VERSION_STR;
}

const void * _Nonnull makeBridgedParticipant(void)
{
    auto participant = new BridgedParticipant();
    return participant;
}

void setupRTPSBridgeContainer(const void * participant,
                             struct BridgeContainer container)
{
    auto p = (BridgedParticipant *)participant;
    p->setContainer(container);
}

bool createRTPSParticipant(const void * participant,
                           const uint32_t domain,
                           const char* name,
                           const struct RTPSParticipantProfile * _Nullable participantProfile,
                           const char* _Nullable localAddress)
{
    auto p = (BridgedParticipant *)participant;
    return p->createParticipant(name, domain, participantProfile, localAddress, nullptr);
}

void setRTPSLoglevel(enum FastRTPSLogLevel logLevel)
{
    Log::ClearConsumers();
    Log::RegisterConsumer(std::unique_ptr<LogConsumer>(new eprosima::fastdds::dds::CustomLogConsumer));
    switch (logLevel) {
        case FastRTPSLogLevelError:
            Log::SetVerbosity(Log::Kind::Error);
            break;
        case FastRTPSLogLevelWarning:
            Log::SetVerbosity(Log::Kind::Warning);
            break;
        case FastRTPSLogLevelInfo:
            Log::SetVerbosity(Log::Kind::Info);
            break;
    }
    Log::ReportFilenames(true);
}

bool registerRTPSReader(const void * participant,
                        const char * topicName,
                        const char * typeName,
                        const RTPSReaderProfile readerProfile,
                        const void * payloadDecoder,
                        const char * partition)
{
    auto p = (BridgedParticipant *)participant;
    return p->addReader(topicName, typeName, readerProfile, payloadDecoder, partition);
}

bool removeRTPSReader(const void * participant,
                      const char * topicName)
{
    auto p = (BridgedParticipant *)participant;
    return p->removeReader(topicName);
}

bool registerRTPSWriter(const void * participant,
                        const char * topicName,
                        const char * typeName,
                        const RTPSWriterProfile writerProfile,
                        const char * partition)
{
    auto p = (BridgedParticipant *)participant;
    return p->addWriter(topicName, typeName, writerProfile, partition);
}

bool removeRTPSWriter(const void * participant,
                      const char * topicName)
{
    auto p = (BridgedParticipant *)participant;
    return p->removeWriter(topicName);
}

bool sendDataWithKey(const void * participant,
                     const char * topicName,
                     const void * data,
                     uint32_t length,
                     const void * key,
                     uint32_t keyLength)
{
    auto p = (BridgedParticipant *)participant;
    return p->send(topicName, (uint8_t *)data, length, key, keyLength);
}

bool sendData(const void * participant,
              const char * topicName,
              const void * data,
              uint32_t length)
{
    auto p = (BridgedParticipant *)participant;
    return p->send(topicName, (uint8_t *)data, length, nullptr, 0);
}


void resignRTPSAll(const void * participant)
{
    auto p = (BridgedParticipant *)participant;
    p->resignAll();
}

void stopRTPSAll(const void * participant)
{
    auto p = (BridgedParticipant *)participant;
    p->stopAll();
}

void removeRTPSParticipant(const void * participant)
{
    auto p = (BridgedParticipant *)participant;
    p->resignAll();
    delete p;
}
