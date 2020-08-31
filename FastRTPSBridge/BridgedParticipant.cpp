/////
////  BridgedParticipant.cpp
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
#include <fastrtps/transport/UDPv4TransportDescriptor.h>

using namespace eprosima::fastdds;
using namespace eprosima::fastrtps::rtps;

BridgedParticipant::BridgedParticipant(DecoderCallback decoderCallback):
mp_participant(nullptr),
mp_listener(nullptr),
partitionName("*")
{
    BridgedParticipant::decoderCallback = decoderCallback;
}

BridgedParticipant::~BridgedParticipant()
{
    logInfo(ROV_PARTICIPANT, "Delete participant")
    if (mp_participant == nullptr) return;
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

bool BridgedParticipant::createParticipant(const char* name, const char *interfaceIPv4, const char* networkAddress)
{
    RTPSParticipantAttributes pattr;
    pattr.builtin.use_WriterLivelinessProtocol = true;
    pattr.builtin.discovery_config.discoveryProtocol = eprosima::fastrtps::rtps::DiscoveryProtocol::SIMPLE;
    pattr.builtin.discovery_config.leaseDuration_announcementperiod = Duration_t(3,0);
    pattr.builtin.discovery_config.leaseDuration = Duration_t(10,0);
    pattr.builtin.discovery_config.initial_announcements.count = 5;
    pattr.builtin.discovery_config.ignoreParticipantFlags = FILTER_SAME_PROCESS;
    pattr.builtin.readerHistoryMemoryPolicy = PREALLOCATED_WITH_REALLOC_MEMORY_MODE;
    pattr.builtin.writerHistoryMemoryPolicy = PREALLOCATED_WITH_REALLOC_MEMORY_MODE;
    pattr.setName(name);
    
    auto customTransport = std::make_shared<UDPv4TransportDescriptor>();
    customTransport->sendBufferSize = 65536;
    customTransport->receiveBufferSize = 65536;
    if (interfaceIPv4 != nullptr) {
        customTransport->interfaceWhiteList.emplace_back(interfaceIPv4);
    }
    if (networkAddress != nullptr) {
        customTransport->remoteWhiteList.emplace_back(networkAddress);
    }
    pattr.userTransports.push_back(customTransport);
    pattr.useBuiltinTransports = false;

    mp_listener = new BridgedParticipantListener();
    mp_participant = RTPSDomain::createParticipant(0, pattr, mp_listener);
    if (mp_participant == nullptr)
        return false;

    return true;
}

bool BridgedParticipant::addReader(const char* name,
                                   const char* dataType,
                                   const bool keyed,
                                   const bool transientLocal,
                                   const bool reliable,
                                   const void * payloadDecoder)
{
    auto topicName = std::string(name);
    auto tKind = keyed ? eprosima::fastrtps::rtps::WITH_KEY : eprosima::fastrtps::rtps::NO_KEY;
    if (readerList.find(topicName) != readerList.end()) {
        // aready registered
        return false;
    }
    ReaderAttributes readerAttributes;
    readerAttributes.endpoint.topicKind = tKind;
    if (transientLocal) {
        readerAttributes.endpoint.durabilityKind = TRANSIENT_LOCAL;
    }
    if (reliable) {
        readerAttributes.endpoint.reliabilityKind = RELIABLE;
    }
    auto listener = new BridgedReaderListener(name, decoderCallback, payloadDecoder);

    HistoryAttributes historyAttributes;
    historyAttributes.memoryPolicy = DYNAMIC_RESERVE_MEMORY_MODE;
    historyAttributes.payloadMaxSize = 1000;
    historyAttributes.initialReservedCaches = 5;
    historyAttributes.maximumReservedCaches = 0;
    auto history = new ReaderHistory(historyAttributes);
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

    TopicAttributes topicAttributes(name, dataType, tKind);
    ReaderQos readerQos;
    readerQos.m_partition.push_back(partitionName.c_str());
    if (transientLocal == true) {
        readerQos.m_durability.kind = TRANSIENT_LOCAL_DURABILITY_QOS;
    }
    if (reliable == true) {
        readerQos.m_reliability.kind = RELIABLE_RELIABILITY_QOS;
    }
    auto rezult = mp_participant->registerReader(reader, topicAttributes, readerQos);
    if (!rezult) {
        RTPSDomain::removeRTPSReader(reader);
        readerList.erase(topicName);
        delete readerInfo;
        return false;
    }
    logInfo(ROV_PARTICIPANT, "Registered reader: " << name << " - " << dataType)
    return true;
}

const void * BridgedParticipant::removeReader(const char* name)
{
    logInfo(ROV_PARTICIPANT, "Remove reader: " << name)
    auto topicName = std::string(name);
    if (readerList.find(topicName) == readerList.end()) {
        return nullptr;
    }
    auto readerInfo = readerList[topicName];
    auto payloadDecoder = readerInfo->listener->payloadDecoder;
    if (!RTPSDomain::removeRTPSReader(readerInfo->reader))
        return nullptr;
    readerList.erase(topicName);
    delete readerInfo;
    return payloadDecoder;
}

bool BridgedParticipant::addWriter(const char* name,
                               const char* dataType,
                               const bool keyed,
                               const bool transientLocal)
{
    auto topicName = std::string(name);
    auto tKind = keyed ? eprosima::fastrtps::rtps::WITH_KEY : eprosima::fastrtps::rtps::NO_KEY;
    if (writerList.find(topicName) != writerList.end()) {
        // aready registered
        return false;
    }

    WriterAttributes writerAttributes;
    writerAttributes.times.heartbeatPeriod = Duration_t(0, 100000000);       // 100 ms
    writerAttributes.times.nackResponseDelay = Duration_t(0.0);

    writerAttributes.endpoint.topicKind = tKind;
    writerAttributes.endpoint.reliabilityKind = RELIABLE;
    writerAttributes.endpoint.durabilityKind = transientLocal ? TRANSIENT_LOCAL : VOLATILE;

    auto listener = new BridgedWriterListener(name);
    HistoryAttributes historyAttributes;
    historyAttributes.memoryPolicy = DYNAMIC_RESERVE_MEMORY_MODE;
    historyAttributes.payloadMaxSize = 1000;
    historyAttributes.initialReservedCaches = 5;
    historyAttributes.maximumReservedCaches = 0;
    auto history = new WriterHistory(historyAttributes);
    auto writer = RTPSDomain::createRTPSWriter(mp_participant, writerAttributes, history, listener);
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

    TopicAttributes topicAttributes(name, dataType, tKind);
    WriterQos writerQos;
    writerQos.m_partition.push_back(partitionName.c_str());
    writerQos.m_disablePositiveACKs.enabled = true;
    writerQos.m_durability.kind = transientLocal ? TRANSIENT_LOCAL_DURABILITY_QOS: VOLATILE_DURABILITY_QOS;
    
    auto rezult = mp_participant->registerWriter(writer, topicAttributes, writerQos);
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
    auto history = writerInfo->history;
    
    if (history->getHistorySize() > 0) {
        // drop history
        history->remove_all_changes();
    }
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
    history->add_change(change);

    return true;
}
