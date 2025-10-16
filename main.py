import wx
from utils import ensure_hdpi


class MyApp(wx.App):
    def OnInit(self):
        ensure_hdpi()
        frame = wx.Frame(parent=None, title="Заголовок")
        frame.Show()
        return True
        

if __name__ == "__main__":
    app = MyApp()
    app.MainLoop()