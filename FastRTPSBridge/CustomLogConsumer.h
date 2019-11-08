/////
////  CustomLogConsumer.h
///   Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//

#pragma once

#include <fastrtps/log/Log.h>

namespace eprosima {
namespace fastrtps {

class CustomLogConsumer: public LogConsumer {
public:
    virtual ~CustomLogConsumer() {};
    RTPS_DllAPI virtual void Consume(const Log::Entry&);

private:
    void PrintHeader(const Log::Entry&) const;
    void PrintContext(const Log::Entry&) const;
};

} // namespace fastrtps
} // namespace eprosima
