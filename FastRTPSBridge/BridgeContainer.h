/////
////  BridgeContainer.h
///   Copyright © 2020 Dmitriy Borovikov. All rights reserved.
//


#ifndef BridgeContainer_h
#define BridgeContainer_h

#include "FastRTPSBridge.h"

struct BridgeContainer
{
    DecoderCallback decoderCallback;
    ReleaseCallback releaseCallback;
    const void *listnerObject;
    ReaderWriterListenerCallback readerWriterListenerCallback;
    DiscoveryParticipantCallback discoveryParticipantCallback;
    DiscoveryReaderWriterCallback discoveryReaderWriterCallback;
};

#endif /* BridgeContainer_h */
