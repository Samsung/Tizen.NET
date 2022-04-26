
namespace Microsoft.NetConf2021.Maui.Platforms.Tizen;

public class AudioService : IAudioService
{
    public bool IsPlaying => false;

    public double CurrentPosition => 0;

    public Task InitializeAsync(string audioURI)
    {
        return Task.CompletedTask;
    }

    public Task PauseAsync()
    {
        return Task.CompletedTask;
    }

    public Task PlayAsync(double position = 0)
    {
        return Task.CompletedTask;
    }
}
