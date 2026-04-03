#include <windows.h>
#include <iostream>

// g++ --static Windows-GPU-Info.cpp

int main() {
    DISPLAY_DEVICE dd;
    dd.cb = sizeof(dd);
    int deviceIndex = 0;

    while (EnumDisplayDevices(NULL, deviceIndex, &dd, 0)) {
        if (dd.StateFlags & DISPLAY_DEVICE_ATTACHED_TO_DESKTOP) {
            std::wcout << deviceIndex << L": " << dd.DeviceString << std::endl;
        }
        deviceIndex++;
    }

    if (deviceIndex == 0) {
        std::cerr << "Failed to get display device info." << std::endl;
    }

    return 0;
}
