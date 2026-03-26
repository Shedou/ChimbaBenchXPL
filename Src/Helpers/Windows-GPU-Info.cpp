#include <windows.h>
#include <iostream>

// g++ --static Windows-GPU-Info.cpp

int main() {
    DISPLAY_DEVICE dd;
    dd.cb = sizeof(dd);
    int deviceIndex = 0;

    if (EnumDisplayDevices(NULL, deviceIndex, &dd, 0)) {
        std::wcout << dd.DeviceString << std::endl;
    } else {
        std::cerr << "Failed to get display device info." << std::endl;
    }

    return 0;
}