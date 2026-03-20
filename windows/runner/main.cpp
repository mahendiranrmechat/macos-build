#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"

HANDLE g_mutex = NULL;
HHOOK keyboardHook = NULL;

// 👇 Helper to hide taskbar
void HideTaskbar()
{
  HWND taskbar = FindWindow(L"Shell_TrayWnd", NULL);
  HWND startBtn = FindWindow(L"Button", NULL); // Might not always work
  if (taskbar)
    ShowWindow(taskbar, SW_HIDE);
  if (startBtn)
    ShowWindow(startBtn, SW_HIDE);
}

// 👇 Helper to show taskbar
void ShowTaskbar()
{
  HWND taskbar = FindWindow(L"Shell_TrayWnd", NULL);
  HWND startBtn = FindWindow(L"Button", NULL);
  if (taskbar)
    ShowWindow(taskbar, SW_SHOW);
  if (startBtn)
    ShowWindow(startBtn, SW_SHOW);
}

// 👇 Low-level keyboard hook to block system shortcuts
LRESULT CALLBACK LowLevelKeyboardProc(int nCode, WPARAM wParam, LPARAM lParam)
{
  if (nCode == HC_ACTION && (wParam == WM_KEYDOWN || wParam == WM_SYSKEYDOWN))
  {
    KBDLLHOOKSTRUCT *p = (KBDLLHOOKSTRUCT *)lParam;
    bool alt = (GetAsyncKeyState(VK_MENU) & 0x8000);
    bool ctrl = (GetAsyncKeyState(VK_CONTROL) & 0x8000);

    if ((alt && p->vkCode == VK_TAB) || (alt && p->vkCode == VK_F4) ||
        (p->vkCode == VK_LWIN || p->vkCode == VK_RWIN) ||
        (alt && p->vkCode == VK_ESCAPE) || (ctrl && p->vkCode == VK_ESCAPE))
    {
      return 1; // Block
    }
  }
  return CallNextHookEx(NULL, nCode, wParam, lParam);
}

int APIENTRY wWinMain(HINSTANCE instance, HINSTANCE prev, wchar_t *command_line, int show_command)
{
  // 👇 Prevent multiple instances
  g_mutex = CreateMutex(NULL, TRUE, L"Global\\JACKPOT_UNIQUE_MUTEX");
  if (GetLastError() == ERROR_ALREADY_EXISTS)
  {
    MessageBox(NULL, L"JACKPOT is already running.", L"Warning", MB_OK | MB_ICONWARNING);
    return 0;
  }

  // 👇 Show debug console if needed
  if (!AttachConsole(ATTACH_PARENT_PROCESS) && IsDebuggerPresent())
  {
    CreateAndAttachConsole();
  }

  CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  // 👇 Hide taskbar
  // HideTaskbar();

  flutter::DartProject project(L"data");
  std::vector<std::string> args = GetCommandLineArguments();
  project.set_dart_entrypoint_arguments(std::move(args));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);

  if (!window.CreateAndShow(L"JACKPOT", origin, size))
  {
    return EXIT_FAILURE;
  }

  window.SetQuitOnClose(true);

  // 👇 Install keyboard hook
  keyboardHook = SetWindowsHookEx(WH_KEYBOARD_LL, LowLevelKeyboardProc, NULL, 0);

  // 👇 Main loop
  MSG msg;
  while (GetMessage(&msg, nullptr, 0, 0))
  {
    TranslateMessage(&msg);
    DispatchMessage(&msg);
  }

  // 👇 Cleanup
  if (keyboardHook)
    UnhookWindowsHookEx(keyboardHook);

  ShowTaskbar(); // Show taskbar on app close

  CoUninitialize();

  if (g_mutex)
    CloseHandle(g_mutex);

  return EXIT_SUCCESS;
}
