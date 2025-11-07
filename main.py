import wx
from utils import hide_splash_screen, ensure_hdpi


class MainFrame(wx.Frame):
    def __init__(self, parent, title):
        super().__init__(parent, title=title)
        self.panel = wx.Panel(self)


class MyApp(wx.App):
    def OnInit(self):
        frame = MainFrame(parent=None, title="Simple wxPython Application")
        frame.Center()
        frame.Show()
        hide_splash_screen()
        return True


if __name__ == "__main__":
    ensure_hdpi()
    app = MyApp()
    app.MainLoop()