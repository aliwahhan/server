using System.Collections.Frozen;
using Bit.Core.Enums;
using Bit.Core.Settings;
using Duende.IdentityServer.Models;

namespace Bit.Identity.IdentityServer;

public class StaticClientStore
{
    public StaticClientStore(GlobalSettings globalSettings)
    {
        ApiClients = new List<Client>
        {
            new ApiClient(globalSettings, DeepsaferClient.Mobile, 60, 1),
            new ApiClient(globalSettings, DeepsaferClient.Web, 7, 1),
            new ApiClient(globalSettings, DeepsaferClient.Browser, 30, 1),
            new ApiClient(globalSettings, DeepsaferClient.Desktop, 30, 1),
            new ApiClient(globalSettings, DeepsaferClient.Cli, 30, 1),
            new ApiClient(globalSettings, DeepsaferClient.DirectoryConnector, 30, 24)
        }.ToFrozenDictionary(c => c.ClientId);
    }

    public FrozenDictionary<string, Client> ApiClients { get; }
}
