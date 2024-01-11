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
#include <fastrtps/TopicDataType.h>

#include <fastrtps/attributes/TopicAttributes.h>
#include <fastrtps/qos/ReaderQos.h>
#include <fastrtps/qos/WriterQos.h>
#include <fastrtps/log/Log.h>
#include <fastrtps/transport/UDPv4TransportDescriptor.h>

using namespace eprosima::fastdds;
using namespace eprosima::fastrtps::rtps;

BridgedParticipant::BridgedParticipant():
mp_participant(nullptr),
mp_listener(nullptr)
{
}

void BridgedParticipant::setContainer(BridgeContainer container)
{
    BridgedParticipant::container = container;
}

BridgedParticipant::~BridgedParticipant()
{
    logInfo(ROV_PARTICIPANT, "Delete participant")
    if (mp_participant == nullptr) return;
    mp_participant->stopRTPSParticipantAnnouncement();
    resignAll();
    RTPSDomain::removeRTPSParticipant(mp_participant);
    delete mp_listener;
}

void BridgedParticipant::stopAll()
{
    RTPSDomain::stopAll();
}

void BridgedParticipant::resignAll() {
    for(auto it = readerList.begin(); it != readerList.end(); it++)
    {
        logInfo(ROV_PARTICIPANT, "Remove reader: " << it->first)
        auto readerInfo = it->second;
        auto payloadDecoder = (void * _Nonnull)readerInfo->listener->payloadDecoder;
        RTPSDomain::removeRTPSReader(readerInfo->reader);
        container.releaseCallback(payloadDecoder);
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

bool BridgedParticipant::createParticipant(const char* name,
                                           const uint32_t domain,
                                           const RTPSParticipantProfile* participantProfile,
                                           const char *interfaceIPv4,
                                           const char* remoteWhitelistAddress)
{
    RTPSParticipantAttributes participantAttributes;
    participantAttributes.builtin.discovery_config.discoveryProtocol = eprosima::fastrtps::rtps::DiscoveryProtocol::SIMPLE;
    participantAttributes.setName(name);
    if (participantProfile != nullptr) {
        participantAttributes.builtin.discovery_config.leaseDuration_announcementperiod = Duration_t(participantProfile->leaseDuration_announcementperiod);
        participantAttributes.builtin.discovery_config.leaseDuration = Duration_t(participantProfile->leaseDuration);
        switch (participantProfile->participantFilter) {
            case Disabled:
                participantAttributes.builtin.discovery_config.ignoreParticipantFlags = NO_FILTER;
                break;
            case DifferentHost:
                participantAttributes.builtin.discovery_config.ignoreParticipantFlags = FILTER_DIFFERENT_HOST;
                break;
            case DifferentProcess:
                participantAttributes.builtin.discovery_config.ignoreParticipantFlags = FILTER_DIFFERENT_PROCESS;
                break;
            case SameProcess:
                participantAttributes.builtin.discovery_config.ignoreParticipantFlags = FILTER_SAME_PROCESS;
                break;
        }
    }
    
#ifdef FASTRTPS_WHITELIST
    if (interfaceIPv4 != nullptr || remoteWhitelistAddress != nullptr) {
#else
    if (interfaceIPv4 != nullptr) {
#endif
        auto customTransport = std::make_shared<UDPv4TransportDescriptor>();
        customTransport->sendBufferSize = 65536;
        customTransport->receiveBufferSize = 65536;
        if (interfaceIPv4 != nullptr) {
            customTransport->interfaceWhiteList.emplace_back(interfaceIPv4);
        }

#ifdef FASTRTPS_WHITELIST
        if (remoteWhitelistAddress != nullptr) {
            customTransport->remoteWhiteList.emplace_back(remoteWhitelistAddress);
        }
#endif
    
        participantAttributes.userTransports.push_back(customTransport);
        participantAttributes.useBuiltinTransports = false;
    }
    mp_listener = new BridgedParticipantListener(container);
    mp_participant = RTPSDomain::createParticipant(domain, participantAttributes, mp_listener);
    if (mp_participant == nullptr)
        return false;

    return true;
}

bool BridgedParticipant::addReader(const char* name,
                                   const char* dataType,
                                   const RTPSReaderProfile readerProfile,
                                   const void * payloadDecoder,
                                   const char * partition)
{
    auto topicName = std::string(name);
    auto tKind = readerProfile.keyed ? eprosima::fastrtps::rtps::WITH_KEY : eprosima::fastrtps::rtps::NO_KEY;
    if (readerList.find(topicName) != readerList.end()) {
        // aready registered
        container.releaseCallback((void * _Nonnull)payloadDecoder);
        return false;
    }
    ReaderAttributes readerAttributes;
    readerAttributes.endpoint.topicKind = tKind;
    ReaderQos readerQos;
    if (partition != nullptr) {
        readerQos.m_partition.push_back(partition);
    }
    switch (readerProfile.reliability) {
        case ReliabilityReliable:
            readerAttributes.endpoint.reliabilityKind = RELIABLE;
            readerQos.m_reliability.kind = RELIABLE_RELIABILITY_QOS;
            break;
        case ReliabilityBestEffort:
            readerAttributes.endpoint.reliabilityKind = BEST_EFFORT;
            readerQos.m_reliability.kind = BEST_EFFORT_RELIABILITY_QOS;
            break;
    }
    switch (readerProfile.durability) {
        case DurabilityVolatile:
            readerAttributes.endpoint.durabilityKind = VOLATILE;
            readerQos.m_durability.kind = VOLATILE_DURABILITY_QOS;
            break;
        case DurabilityTransientLocal:
            readerAttributes.endpoint.durabilityKind = TRANSIENT_LOCAL;
            readerQos.m_durability.kind = TRANSIENT_LOCAL_DURABILITY_QOS;
            break;
        case DurabilityTransient:
            readerAttributes.endpoint.durabilityKind = TRANSIENT;
            readerQos.m_durability.kind = TRANSIENT_DURABILITY_QOS;
            break;
        case DurabilityPersistent:
            readerAttributes.endpoint.durabilityKind = PERSISTENT;
            readerQos.m_durability.kind = PERSISTENT_DURABILITY_QOS;
            break;
    }

    auto listener = new BridgedReaderListener(name, payloadDecoder, container);

    HistoryAttributes historyAttributes;
    historyAttributes.memoryPolicy = DYNAMIC_REUSABLE_MEMORY_MODE;
    historyAttributes.payloadMaxSize = 1000;
    historyAttributes.initialReservedCaches = 5;
    historyAttributes.maximumReservedCaches = 0;
    auto history = new ReaderHistory(historyAttributes);
    auto reader = RTPSDomain::createRTPSReader(mp_participant, readerAttributes, history, listener);
    if (reader == nullptr) {
        delete listener;
        delete history;
        container.releaseCallback((void * _Nonnull)payloadDecoder);
        return false;
    }

    auto readerInfo = new ReaderInfo;
    readerInfo->reader = reader;
    readerInfo->history = history;
    readerInfo->listener = listener;
    readerList[topicName] = readerInfo;

    TopicAttributes topicAttributes(name, dataType, tKind);
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

bool BridgedParticipant::removeReader(const char* name)
{
    logInfo(ROV_PARTICIPANT, "Remove reader: " << name)
    auto topicName = std::string(name);
    if (readerList.find(topicName) == readerList.end()) {
        return false;
    }
    auto readerInfo = readerList[topicName];
    auto payloadDecoder = (void * _Nonnull)readerInfo->listener->payloadDecoder;
    if (!RTPSDomain::removeRTPSReader(readerInfo->reader))
        return false;
    readerList.erase(topicName);
    delete readerInfo;
    container.releaseCallback(payloadDecoder);
    return true;
}

bool BridgedParticipant::addWriter(const char* name,
                                   const char* dataType,
                                   const RTPSWriterProfile writerProfile,
                                   const char * partition)
{
    auto topicName = std::string(name);
    auto tKind = writerProfile.keyed ? eprosima::fastrtps::rtps::WITH_KEY : eprosima::fastrtps::rtps::NO_KEY;
    if (writerList.find(topicName) != writerList.end()) {
        // aready registered
        return false;
    }

    WriterAttributes writerAttributes;
    writerAttributes.endpoint.topicKind = tKind;
    WriterQos writerQos;
    if (partition != nullptr) {
        writerQos.m_partition.push_back(partition);
    }
    writerQos.m_disablePositiveACKs.enabled = writerProfile.disablePositiveACKs;
    switch (writerProfile.reliability) {
        case ReliabilityReliable:
            writerAttributes.endpoint.reliabilityKind = RELIABLE;
            writerQos.m_reliability.kind = RELIABLE_RELIABILITY_QOS;
            break;
        case ReliabilityBestEffort:
            writerAttributes.endpoint.reliabilityKind = BEST_EFFORT;
            writerQos.m_reliability.kind = BEST_EFFORT_RELIABILITY_QOS;
            break;
    }
    switch (writerProfile.durability) {
        case DurabilityVolatile:
            writerAttributes.endpoint.durabilityKind = VOLATILE;
            writerQos.m_durability.kind = VOLATILE_DURABILITY_QOS;
            break;
        case DurabilityTransientLocal:
            writerAttributes.endpoint.durabilityKind = TRANSIENT_LOCAL;
            writerQos.m_durability.kind = TRANSIENT_LOCAL_DURABILITY_QOS;
            break;
        case DurabilityTransient:
            writerAttributes.endpoint.durabilityKind = TRANSIENT;
            writerQos.m_durability.kind = TRANSIENT_DURABILITY_QOS;
            break;
        case DurabilityPersistent:
            writerAttributes.endpoint.durabilityKind = PERSISTENT;
            writerQos.m_durability.kind = PERSISTENT_DURABILITY_QOS;
            break;
    }

    auto listener = new BridgedWriterListener(name, container);
    HistoryAttributes historyAttributes;
    historyAttributes.memoryPolicy = DYNAMIC_REUSABLE_MEMORY_MODE;
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
    MD5 md5;
    
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
    if (key && keyLength > 0) {
        InstanceHandle_t instanceHandle;
        if (keyLength > 16) {
            md5.init();
            md5.update((octet *)key, static_cast<unsigned int>(keyLength));
            md5.finalize();
            memcpy(instanceHandle.value, md5.digest, sizeof(md5.digest));
        } else {
            memcpy(instanceHandle.value, key, keyLength);
        }
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
