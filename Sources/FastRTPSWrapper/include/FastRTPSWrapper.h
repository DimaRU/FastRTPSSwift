/////
////  FastRTPSWrapper.h
///   Copyright © 2020 Dmitriy Borovikov. All rights reserved.
//

#pragma once

#include "FastRTPSDefs.h"

#include "../BridgedParticipant.h"
#include "../BridgedParticipantListener.h"
#include "../BridgedReaderListener.h"
#include "../BridgedWriterListener.h"
#include "../BridgedReaderProxyData.h"
#include "../BridgedWriterProxyData.h"
#include "../BridgedParticipantProxyData.h"

const char * _Nonnull fastDDSVersionString(void);
void setRTPSLoglevel(enum FastRTPSLogLevel logLevel);
