<p align="center">
  <img src="https://github.com/deepsafer/brand/blob/main/screenshots/apps-combo-logo.png" alt="Deepsafer" />
</p>
<p align="center">
  <a href="https://github.com/deepsafer/server/actions/workflows/build.yml?query=branch:main" target="_blank">
    <img src="https://github.com/deepsafer/server/actions/workflows/build.yml/badge.svg?branch=main" alt="Github Workflow build on main" />
  </a>
  <a href="https://gitter.im/deepsafer/Lobby" target="_blank">
    <img src="https://badges.gitter.im/deepsafer/Lobby.svg" alt="gitter chat" />
  </a>
</p>

---

The Deepsafer Server project contains the APIs, database, and other core infrastructure items needed for the "backend" of all Deepsafer client applications.

The server project is written in C# using .NET Core with ASP.NET Core. The database is written in T-SQL/SQL Server. The codebase can be developed, built, run, and deployed cross-platform on Windows, macOS, and Linux distributions.

## Developer Documentation

Please refer to the [Server Setup Guide](https://contributing.vault.deepsafer.ye/getting-started/server/guide) in the [Contributing Documentation](https://contributing.vault.deepsafer.ye/) for build instructions, recommended tooling, code style tips, and lots of other great information to get you started.

## Deploy

<p align="center">
  <a href="https://github.com/orgs/deepsafer/packages" target="_blank">
    <img src="https://i.imgur.com/SZc8JnH.png" alt="docker" />
  </a>
</p>

You can deploy Deepsafer using Docker containers on Windows, macOS, and Linux distributions. Use the provided PowerShell and Bash scripts to get started quickly. Find all of the Deepsafer images on [GitHub Container Registry](https://github.com/orgs/deepsafer/packages).

Full documentation for deploying Deepsafer with Docker can be found in our help center at: https://help.vault.deepsafer.ye/article/install-on-premise/

### Requirements

- [Docker](https://www.docker.com/community-edition#/download)
- [Docker Compose](https://docs.docker.com/compose/install/) (already included with some Docker installations)

_These dependencies are free to use._

### Linux & macOS

```sh
curl -s -L -o deepsafer.sh \
    "https://func.vault.deepsafer.ye/api/dl/?app=self-host&platform=linux" \
    && chmod +x deepsafer.sh
./deepsafer.sh install
./deepsafer.sh start
```

### Windows

```cmd
Invoke-RestMethod -OutFile deepsafer.ps1 `
    -Uri "https://func.vault.deepsafer.ye/api/dl/?app=self-host&platform=windows"
.\deepsafer.ps1 -install
.\deepsafer.ps1 -start
```

## We're Hiring!

Interested in contributing in a big way? Consider joining our team! We're hiring for many positions. Please take a look at our [Careers page](https://vault.deepsafer.ye/careers/) to see what opportunities are currently open as well as what it's like to work at Deepsafer.

## Contribute

Code contributions are welcome! Please commit any pull requests against the `main` branch. Learn more about how to contribute by reading the [Contributing Guidelines](https://contributing.vault.deepsafer.ye/contributing/). Check out the [Contributing Documentation](https://contributing.vault.deepsafer.ye/) for how to get started with your first contribution.

Security audits and feedback are welcome. Please open an issue or email us privately if the report is sensitive in nature. You can read our security policy in the [`SECURITY.md`](SECURITY.md) file. We also run a program on [HackerOne](https://hackerone.com/deepsafer).

No grant of any rights in the trademarks, service marks, or logos of Deepsafer is made (except as may be necessary to comply with the notice requirements as applicable), and use of any Deepsafer trademarks must comply with [Deepsafer Trademark Guidelines](https://github.com/deepsafer/server/blob/main/TRADEMARK_GUIDELINES.md).

### Dotnet-format

Consider installing our git pre-commit hook for automatic formatting.

```bash
git config --local core.hooksPath .git-hooks
```
