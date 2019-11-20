/////
////  BridgedParticipant.mm
///   Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//

#include "BridgedParticipant.h"
#include "BridgedReaderListener.h"
#include "BridgedWriterListener.h"
#include "BridgedParticipantListener.h"

#include <fastrtps/rtps/RTPSDomain.h>
#include <fastrtps/rtps/participant/RTPSParticipant.h>

#include <fastrtps/rtps/attributes/RTPSParticipantAttributes.h>
#include <fastrtps/rtps/attributes/ReaderAttributes.h>
#include <fastrtps/rtps/attributes/WriterAttributes.h>
#include <fastrtps/rtps/attributes/HistoryAttributes.h>

#include <fastrtps/attributes/TopicAttributes.h>
#include <fastrtps/qos/ReaderQos.h>
#include <fastrtps/qos/WriterQos.h>
#include <fastrtps/log/Log.h>

using namespace eprosima::fastrtps;
using namespace eprosima::fastrtps::rtps;

BridgedParticipant::BridgedParticipant():
mp_participant(nullptr),
mp_listener(nullptr),
partitionName("*")
{
}

BridgedParticipant::~BridgedParticipant()
{
    logInfo(ROV_PARTICIPANT, "Delete participant")
    mp_participant->stopRTPSParticipantAnnouncement();
    resignAll();
    RTPSDomain::removeRTPSParticipant(mp_participant);
    delete mp_listener;
//    RTPSDomain::stopAll();
}

void BridgedParticipant::resignAll() {
    for(auto it = readerList.begin(); it != readerList.end(); it++)
    {
        logInfo(ROV_PARTICIPANT, "Remove reader: " << it->first)
        auto readerInfo = it->second;
        RTPSDomain::removeRTPSReader(readerInfo->reader);
        delete readerInfo;
    }
    readerList.clear();

    for(auto it = writerList.begin(); it != writerList.end(); it++)
    {
        logInfo(ROV_PARTICIPANT, "Remove writer: " << it->first)
        auto writerInfo = it->second;
        RTPSDomain::removeRTPSWriter(writerInfo->writer);
        delete writerInfo;
    }
    writerList.clear();
}

bool BridgedParticipant::createParticipant(const char* name, const char *peerIPv4)
{
    RTPSParticipantAttributes PParam;
    PParam.builtin.use_WriterLivelinessProtocol = true;
    PParam.builtin.discovery_config.discoveryProtocol = eprosima::fastrtps::rtps::DiscoveryProtocol::SIMPLE;
    PParam.builtin.discovery_config.leaseDuration_announcementperiod.seconds = 1;
    PParam.builtin.discovery_config.leaseDuration.seconds = 20;
    PParam.builtin.readerHistoryMemoryPolicy = PREALLOCATED_WITH_REALLOC_MEMORY_MODE;
    PParam.builtin.writerHistoryMemoryPolicy = PREALLOCATED_WITH_REALLOC_MEMORY_MODE;
    PParam.builtin.domainId = 0;
    PParam.setName(name);

    if (peerIPv4 != nullptr) {
        Locator_t locator;
        IPLocator::setIPv4(locator, peerIPv4);
        PParam.builtin.initialPeersList.push_back(locator);
    }

    mp_listener = new BridgedParticipantListener();
    mp_participant = RTPSDomain::createParticipant(PParam, mp_listener);
    if (mp_participant == nullptr)
        return false;

    return true;
}

bool BridgedParticipant::addReader(const char* name,
                               const char* dataType,
                               const bool keyed,
                               NSObject<PayloadDecoderInterface>* payloadDecoder)
{
    auto topicName = std::string(name);
    auto tKind = keyed ? eprosima::fastrtps::rtps::WITH_KEY : eprosima::fastrtps::rtps::NO_KEY;
    if (readerList.find(topicName) != readerList.end()) {
        // aready registered
        return false;
    }
    ReaderAttributes readerAttributes;
    readerAttributes.endpoint.topicKind = tKind;
    auto listener = new BridgedReaderListener(name, payloadDecoder);

    HistoryAttributes hatt;
    hatt.memoryPolicy = DYNAMIC_RESERVE_MEMORY_MODE;
    hatt.payloadMaxSize = 1000;
    hatt.initialReservedCaches = 5;
    hatt.maximumReservedCaches = 0;
    auto history = new ReaderHistory(hatt);
    auto reader = RTPSDomain::createRTPSReader(mp_participant, readerAttributes, history, listener);
    if (reader == nullptr) {
        delete listener;
        delete history;
        return false;
    }
    
    auto readerInfo = new ReaderInfo;
    readerInfo->reader = reader;
    readerInfo->history = history;
    readerInfo->listener = listener;
    readerList[topicName] = readerInfo;
  
    TopicAttributes Tatt(name, dataType, tKind);
    ReaderQos Rqos;
    Rqos.m_partition.push_back(partitionName.c_str());
    auto rezult = mp_participant->registerReader(reader, Tatt, Rqos);
    if (!rezult) {
        RTPSDomain::removeRTPSReader(reader);
        readerList.erase(topicName);
        delete readerInfo;
        return false;
    }
    logInfo(ROV_PARTICIPANT, "Registered reader: " << name << " - " << dataType)
    return true;
}

bool BridgedParticipant::removeReader(const char* name)
{
    logInfo(ROV_PARTICIPANT, "Remove reader: " << name)
    auto topicName = std::string(name);
    if (readerList.find(topicName) == readerList.end()) {
        return false;
    }
    auto readerInfo = readerList[topicName];
    if (!RTPSDomain::removeRTPSReader(readerInfo->reader))
        return false;
    readerList.erase(topicName);
    delete readerInfo;
    return true;
}

bool BridgedParticipant::addWriter(const char* name,
                               const char* dataType,
                               const bool keyed)
{
    auto topicName = std::string(name);
    auto tKind = keyed ? eprosima::fastrtps::rtps::WITH_KEY : eprosima::fastrtps::rtps::NO_KEY;
    if (writerList.find(topicName) != writerList.end()) {
        // aready registered
        return false;
    }

    WriterAttributes watt;
    watt.endpoint.reliabilityKind = BEST_EFFORT;
    watt.endpoint.topicKind = tKind;
    auto listener = new BridgedWriterListener(name);
    HistoryAttributes hatt;
    hatt.memoryPolicy = DYNAMIC_RESERVE_MEMORY_MODE;
    hatt.payloadMaxSize = 1000;
    hatt.initialReservedCaches = 5;
    hatt.maximumReservedCaches = 0;
    auto history = new WriterHistory(hatt);
    auto writer = RTPSDomain::createRTPSWriter(mp_participant, watt, history, listener);
    if (writer == nullptr) {
        delete listener;
        delete history;
        return false;
    }

    auto writerInfo = new WriterInfo();
    writerInfo->writer = writer;
    writerInfo->history = history;
    writerInfo->listener = listener;
    writerList[topicName] = writerInfo;

    TopicAttributes Tatt(name, dataType, tKind);
    WriterQos Wqos;
    Wqos.m_partition.push_back(partitionName.c_str());
    Wqos.m_disablePositiveACKs.enabled = true;
    auto rezult = mp_participant->registerWriter(writer, Tatt, Wqos);
    if (!rezult) {
        RTPSDomain::removeRTPSWriter(writer);
        writerList.erase(topicName);
        delete writerInfo;
        return false;
    }
    logInfo(ROV_PARTICIPANT, "Registered writer: " << name << " - " << dataType)
    return true;
}

bool BridgedParticipant::removeWriter(const char* name)
{
    logInfo(ROV_PARTICIPANT, "Remove writer: " << name)
    auto topicName = std::string(name);
    if (writerList.find(topicName) == writerList.end()) {
        return false;
    }
    auto writerInfo = writerList[topicName];
    if (!RTPSDomain::removeRTPSWriter(writerInfo->writer))
        return false;
    writerList.erase(topicName);
    delete writerInfo;
    return true;
}

bool BridgedParticipant::send(const char* name, const uint8_t* data, uint32_t length, const void* key, uint32_t keyLength)
{
    static const octet header[] = {0, 1, 0, 0};
    auto topicName = std::string(name);
    if (writerList.find(topicName) == writerList.end()) {
        return false;
    }
    auto writerInfo = writerList[topicName];
    if (writerInfo->listener->n_matched == 0) {
        return false;
    }
    auto writer = writerInfo->writer;

    CacheChange_t * change;
    if (key) {
        InstanceHandle_t instanceHandle;
        auto len = keyLength < 16 ? keyLength : 16;
        memcpy(instanceHandle.value, key, len);
        change = writer->new_change([length]() -> uint32_t { return length+sizeof(header);}, ALIVE, instanceHandle);
        if (!change) {    // In the case history is full, remove some old changes
            logInfo(ROV_PARTICIPANT, "cleaning history...")
            writer->remove_older_changes(2);
            change = writer->new_change([length]() -> uint32_t { return length+sizeof(header);}, ALIVE, instanceHandle);
        }
    } else {
        change = writer->new_change([length]() -> uint32_t { return length+sizeof(header);}, ALIVE);
        if (!change) {    // In the case history is full, remove some old changes
            logInfo(ROV_PARTICIPANT, "cleaning history...")
            writer->remove_older_changes(2);
            change = writer->new_change([length]() -> uint32_t { return length+sizeof(header);}, ALIVE);
        }
    }
    change->serializedPayload.length = length + sizeof(header);
    memcpy(change->serializedPayload.data, header, sizeof(header));
    memcpy(change->serializedPayload.data + sizeof(header), data, length);
    writerInfo->history->add_change(change);

    return true;
}
