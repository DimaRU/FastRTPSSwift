/////
////  CustomLogConsumer.cpp
///   Copyright © 2019 Dmitriy Borovikov. All rights reserved.
//

#include "CustomLogConsumer.h"
#include <iostream>
#include <iomanip>

namespace eprosima {
namespace fastrtps {

void CustomLogConsumer::Consume(const Log::Entry& entry)
{
   PrintHeader(entry);
   PrintMessage(std::cout, entry, false);
   PrintContext(entry);
   PrintNewLine(std::cout, false);
}

void CustomLogConsumer::PrintHeader(const Log::Entry& entry) const
{
    PrintTimestamp(std::cout, entry, false);
    LogConsumer::PrintHeader(std::cout, entry, false);
}

void CustomLogConsumer::PrintContext(const Log::Entry& entry) const
{
    LogConsumer::PrintContext(std::cout, entry, false);
}

} // Namespace fastrtps
} // Namespace eprosima
