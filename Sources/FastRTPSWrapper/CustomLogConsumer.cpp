/////
////  CustomLogConsumer.cpp
///   Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//

#include "CustomLogConsumer.h"
#include <iostream>
#include <iomanip>

namespace eprosima {
namespace fastdds {
namespace dds {

void CustomLogConsumer::Consume(const Log::Entry& entry)
{
    print_header(entry);
    print_message(std::cout, entry, false);
    print_context(entry);
    print_new_line(std::cout, false);
}

void CustomLogConsumer::print_header(
        const Log::Entry& entry) const
{
    print_timestamp(std::cout, entry, false);
    LogConsumer::print_header(std::cout, entry, false);
}

void CustomLogConsumer::print_context(const Log::Entry& entry) const
{
    LogConsumer::print_context(std::cout, entry, false);
}

} // Namespace dds
} // Namespace fastdds
} // Namespace eprosima
