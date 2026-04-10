#include <windows.h>
#include <iostream>
#include <set>
#include <string>
#include <vector>

// g++ --static Windows-GPU-Info-Alt-Drv.cpp

std::wstring GetDriverVersion(const std::wstring& gpuName) {
    std::wstring classPath = L"SYSTEM\\CurrentControlSet\\Control\\Class\\{4d36e968-e325-11ce-bfc1-08002be10318}";
    HKEY hClassKey;
    std::wstring foundVersion = L"Unknown";
    
    if (RegOpenKeyExW(HKEY_LOCAL_MACHINE, classPath.c_str(), 0, KEY_READ, &hClassKey) == ERROR_SUCCESS) {
        for (int i = 0; i < 32; ++i) {
            wchar_t subKeyName[5];
            swprintf(subKeyName, 5, L"%04d", i);
            
            HKEY hSubKey;
            if (RegOpenKeyExW(hClassKey, subKeyName, 0, KEY_READ, &hSubKey) == ERROR_SUCCESS) {
                wchar_t desc[256];
                DWORD sizeDesc = sizeof(desc);
                if (RegQueryValueExW(hSubKey, L"DriverDesc", NULL, NULL, (LPBYTE)desc, &sizeDesc) == ERROR_SUCCESS) {
                    if (gpuName == desc) {
                        wchar_t version[256];
                        DWORD sizeVer = sizeof(version);
                        if (RegQueryValueExW(hSubKey, L"DriverVersion", NULL, NULL, (LPBYTE)version, &sizeVer) == ERROR_SUCCESS) {
                            foundVersion = version;
                            RegCloseKey(hSubKey);
                            break;
                        }
                    }
                }
                RegCloseKey(hSubKey);
            }
        }
        RegCloseKey(hClassKey);
    }
    return foundVersion;
}

int main() {
    setlocale(LC_ALL, "");
    DISPLAY_DEVICEW dd;
    dd.cb = sizeof(dd);
    int deviceIndex = 0;
    
    std::wstring primaryGpuStr = L"";
    std::set<std::wstring> allGpus;
    
    // Перебираем устройства
    while (EnumDisplayDevicesW(NULL, deviceIndex, &dd, 0)) {
        // Пропускаем только зеркальные драйверы
        if (!(dd.StateFlags & DISPLAY_DEVICE_MIRRORING_DRIVER)) {
            
            std::wstring name = dd.DeviceString;
            if (!name.empty()) {
                std::wstring version = GetDriverVersion(name);
                std::wstring fullInfo = name + L" (" + version + L")";
                
                // Основная активная карта
                if (dd.StateFlags & DISPLAY_DEVICE_PRIMARY_DEVICE) {
                    primaryGpuStr = fullInfo;
                }
                
                allGpus.insert(fullInfo);
            }
        }
        deviceIndex++;
    }
    
    // Вывод активного GPU
    if (!primaryGpuStr.empty()) {
        std::wcout << primaryGpuStr << L" Other GPUs: ";
    }
    
    for (const auto& gpu : allGpus) {
        // Прочие видеокарты если есть
        if (gpu != primaryGpuStr) {
            std::wcout << L" (" << gpu << L")";
        }
    }

    return 0;
}
