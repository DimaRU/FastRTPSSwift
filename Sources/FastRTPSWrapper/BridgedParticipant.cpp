/////
////  BridgedParticipant.cpp
///   Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//

#include "FastRTPSDefs.h"
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

void BridgedParticipant::removeRTPSParticipant() {
    if (mp_participant == nullptr) return;
    logInfo(ROV_PARTICIPANT, "Delete participant")
    mp_participant->stopRTPSParticipantAnnouncement();
    resignAll();
    RTPSDomain::removeRTPSParticipant(mp_participant);
    delete mp_listener;
    mp_participant = nullptr;
    mp_listener = nullptr;
}

BridgedParticipant::~BridgedParticipant()
{
    removeRTPSParticipant();
}

void BridgedParticipant::stopAll()
{
    RTPSDomain::stopAll();
}

void BridgedParticipant::resignAll() {
    for(auto it = readerList.begin(); it != readerList.end(); it++)
    {
        logInfo(ROV_PARTICIPANT, "Remove reader: " << it->first)
        auto reader = it->second;
        BridgedReaderListener * listener = static_cast<BridgedReaderListener *>(reader->getListener());
        RTPSDomain::removeRTPSReader(reader);
        delete listener;
    }
    readerList.clear();

    for(auto it = writerList.begin(); it != writerList.end(); it++)
    {
        logInfo(ROV_PARTICIPANT, "Remove writer: " << it->first)
        auto writer = it->second;
        BridgedWriterListener * listener = static_cast<BridgedWriterListener *>(writer->getListener());
        RTPSDomain::removeRTPSWriter(writer);
        delete listener;
    }
    writerList.clear();
}

bool BridgedParticipant::createParticipant(const char* name,
                                           const uint32_t domain,
                                           const RTPSParticipantProfile* participantProfile,
                                           const char *interfaceIPv4)
{
    RTPSParticipantAttributes participantAttributes;
    participantAttributes.builtin.discovery_config.discoveryProtocol = eprosima::fastrtps::rtps::DiscoveryProtocol::SIMPLE;
    participantAttributes.setName(name);
    if (participantProfile != nullptr) {
        participantAttributes.builtin.discovery_config.leaseDuration_announcementperiod = Duration_t(participantProfile->leaseDurationAnnouncementperiod);
        participantAttributes.builtin.discovery_config.leaseDuration = Duration_t(participantProfile->leaseDuration);
        participantAttributes.builtin.discovery_config.ignoreParticipantFlags = static_cast<ParticipantFilteringFlags_t>(participantProfile->participantFilter);
    }
    
    if (interfaceIPv4 != nullptr) {
        auto customTransport = std::make_shared<UDPv4TransportDescriptor>();
        customTransport->sendBufferSize = 65536;
        customTransport->receiveBufferSize = 65536;
        if (interfaceIPv4 != nullptr) {
            customTransport->interfaceWhiteList.emplace_back(interfaceIPv4);
        }

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


    HistoryAttributes historyAttributes;
    historyAttributes.memoryPolicy = DYNAMIC_REUSABLE_MEMORY_MODE;
    historyAttributes.payloadMaxSize = 1000;
    historyAttributes.initialReservedCaches = 5;
    historyAttributes.maximumReservedCaches = 0;
    auto history = new ReaderHistory(historyAttributes);
    auto listener = new BridgedReaderListener(name, payloadDecoder, container, history);
    auto reader = RTPSDomain::createRTPSReader(mp_participant, readerAttributes, history, listener);
    if (reader == nullptr) {
        delete listener;
        return false;
    }

    readerList[topicName] = reader;

    TopicAttributes topicAttributes(name, dataType, tKind);
    auto rezult = mp_participant->registerReader(reader, topicAttributes, readerQos);
    if (!rezult) {
        RTPSDomain::removeRTPSReader(reader);
        readerList.erase(topicName);
        delete listener;
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
    auto reader = readerList[topicName];
    BridgedReaderListener * listener = static_cast<BridgedReaderListener *>(reader->getListener());
    if (!RTPSDomain::removeRTPSReader(reader))
        return false;
    readerList.erase(topicName);
    delete listener;
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

    HistoryAttributes historyAttributes;
    historyAttributes.memoryPolicy = DYNAMIC_REUSABLE_MEMORY_MODE;
    historyAttributes.payloadMaxSize = 1000;
    historyAttributes.initialReservedCaches = 5;
    historyAttributes.maximumReservedCaches = 0;
    auto history = new WriterHistory(historyAttributes);
    auto listener = new BridgedWriterListener(name, container, history);
    auto writer = RTPSDomain::createRTPSWriter(mp_participant, writerAttributes, history, listener);
    if (writer == nullptr) {
        delete listener;
        return false;
    }

    writerList[topicName] = writer;

    TopicAttributes topicAttributes(name, dataType, tKind);
    auto rezult = mp_participant->registerWriter(writer, topicAttributes, writerQos);
    if (!rezult) {
        RTPSDomain::removeRTPSWriter(writer);
        writerList.erase(topicName);
        delete listener;
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
    auto writer = writerList[topicName];
    BridgedWriterListener* listener = static_cast<BridgedWriterListener*>(writer->getListener());
    if (!RTPSDomain::removeRTPSWriter(writer))
        return false;
    writerList.erase(topicName);
    delete listener;
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
    auto writer = writerList[topicName];
    auto history = static_cast<BridgedWriterListener *>(writer->getListener())->history;
//    if (writer->listener->n_matched == 0) {
//        return false;
//    }
//    
//    if (history->getHistorySize() > 0) {
//        // drop history
//        history->remove_all_changes();
//    }

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
