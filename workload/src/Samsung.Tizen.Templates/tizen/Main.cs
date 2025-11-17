using Tizen.UI;
using Tizen.UI.Components;
using Tizen.UI.Components.Material;

namespace TizenApp1
{
    class Program : MaterialApplication
    {
        protected override void OnCreate()
        {
            base.OnCreate();
            FocusManager.Instance.EnableDefaultFocusAlgorithm(true);
            Window.Default.AddAvailableOrientation(WindowOrientation.Portrait);
            Window.Default.AddAvailableOrientation(WindowOrientation.Landscape);
            Window.Default.AddAvailableOrientation(WindowOrientation.PortraitInverse);
            Window.Default.AddAvailableOrientation(WindowOrientation.LandscapeInverse);
            Window.Default.KeyEvent += (s, e) =>
            {
                if (e.KeyEvent.State == KeyState.Up && (e.KeyEvent.KeyPressedName == "BackSpace" || e.KeyEvent.KeyPressedName == "XF86Back"))
                {
                    if (!RootNavigateBack())
                    {
                        Window.Default.Dispose();
                        Exit();
                    }
                }
            };
            var navigator = new Navigator();
            Window.Default.DefaultLayer.Add(navigator);
            navigator.PushAsync(new MainView());
        }

        static void Main(string[] args)
        {
            var app = new Program();
            app.Run(args);
        }
    }
}
