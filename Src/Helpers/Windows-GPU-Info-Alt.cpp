#include <windows.h>
#include <iostream>
#include <set>
#include <string>
#include <vector>

// g++ --static Windows-GPU-Info-Alt.cpp

int main() {
    DISPLAY_DEVICEW dd;
    dd.cb = sizeof(dd);
    int deviceIndex = 0;

    std::wstring primaryGpu = L"";
    std::set<std::wstring> otherGpus;

    // 1. Collect and identify GPUs
    while (EnumDisplayDevicesW(NULL, deviceIndex, &dd, 0)) {
        // Skip virtual mirroring drivers
        if (!(dd.StateFlags & DISPLAY_DEVICE_MIRRORING_DRIVER)) {
            std::wstring currentGpu = dd.DeviceString;
            
            if (!currentGpu.empty()) {
                // Check if this is the Active/Primary GPU
                if (dd.StateFlags & DISPLAY_DEVICE_PRIMARY_DEVICE) {
                    primaryGpu = currentGpu;
                } else {
                    otherGpus.insert(currentGpu);
                }
            }
        }
        deviceIndex++;
    }

    // 2. Output Active GPU first
    /*
    if (!primaryGpu.empty()) {
        std::wcout << L"A: " << primaryGpu << std::endl;
        // Remove from the set if it somehow got in there to prevent duplicates
        otherGpus.erase(primaryGpu);
    } else {
        std::wcout << L"Active GPU: Not found" << std::endl;
    }
    */

    // 3. Output the rest of the list
    //std::wcout << L"--- All GPUs in system ---" << std::endl;
    
    // Print the primary one again as part of the full list
    if (!primaryGpu.empty()) std::wcout << primaryGpu << L" (Primary). Other GPUs:";

    for (const auto& gpuName : otherGpus) {
        std::wcout << L" \"" << gpuName << L"\"";
    }

    return 0;
}
