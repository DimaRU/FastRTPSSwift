/////
////  FastRTPSWrapper.h
///   Copyright © 2020 Dmitriy Borovikov. All rights reserved.
//

#pragma once

#include <string>
#include <stdint.h>
#include <stdbool.h>
#include "FastRTPSDefs.h"

#include "../BridgedParticipant.h"
#include "../BridgedParticipantListener.h"
#include "../BridgedReaderListener.h"
#include "../BridgedWriterListener.h"

const char * _Nonnull fastDDSVersionString(void);
void setRTPSLoglevel(enum FastRTPSLogLevel logLevel);
