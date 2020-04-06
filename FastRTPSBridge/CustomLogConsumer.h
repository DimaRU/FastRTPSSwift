/////
////  CustomLogConsumer.h
///   Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//

#pragma once

#include <fastdds/dds/log/Log.hpp>

namespace eprosima {
namespace fastdds {
namespace dds {

class CustomLogConsumer : public LogConsumer
{
public:
    virtual ~CustomLogConsumer() {}
    RTPS_DllAPI virtual void Consume(const Log::Entry&);

private:
    void print_header(const Log::Entry&) const;
    void print_context(const Log::Entry&) const;
};

} // namespace dds
} // namespace fastdds
} // namespace eprosima
