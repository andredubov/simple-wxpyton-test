
def hide_splash_screen():
    import tempfile, os
    if "NUITKA_ONEFILE_PARENT" in os.environ:
        splash_filename = os.path.join(tempfile.gettempdir(), "onefile_%d_splash_feedback.tmp" % int(os.environ["NUITKA_ONEFILE_PARENT"]))
        if os.path.exists(splash_filename):
            os.unlink(splash_filename)


def ensure_hdpi():
    import platform, ctypes, sys
    
    if platform.system() == "Windows":
        try:
            # Проверяем версию Windows
            version = sys.getwindowsversion()

            # Для Windows 7 и старше используем старый API
            if version.major == 6 and version.minor == 1:  # Windows 7
                try:
                    # Старый API для Windows 7
                    ctypes.windll.user32.SetProcessDPIAware()
                except Exception:
                    pass  # Игнорируем ошибки на Windows 7
            else:
                # Для Windows 8.1+ используем новый API
                try:
                    ctypes.windll.shcore.SetProcessDpiAwareness(2)
                except AttributeError:
                    try:
                        # Fallback для Windows Vista+
                        ctypes.windll.user32.SetProcessDPIAware()
                    except AttributeError:
                        pass  # Старые версии Windows без DPI поддержки
        except Exception:
            # Если любая проверка fails, просто игнорируем DPI настройки
            pass