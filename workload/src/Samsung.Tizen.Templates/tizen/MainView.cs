using Tizen.UI;
using Tizen.UI.Components.Material;
using Tizen.UI.Layouts;

namespace TizenApp1
{
    public class MainView : Scaffold
    {
        public MainView() : base()
        {
           int count = 0;

            AppBar = new AppBar
            {
                BackgroundColor = MaterialColor.PrimaryContainer,
                Title = "TizenApp1",
            };

            Content = new VStack
            {
                Children =
                {
                    new Label
                    {
                        Text = $"Current Count: {count}",
                        FontSize = 40f,
                    }
                    .Self(out var label)
                    .Expand()
                    .Center(),
                }
            };

            FloatingActionButton = new IconButton(MaterialIcon.Add, IconButtonVariables.FAB)
            {
                ClickedCommand = (_, _) => label.Text = $"Current Count: {++count}"
            };
        }
    }
}
