# Deepsafer and Open Source

The source code for all Deepsafer software products is hosted on GitHub and we welcome everyone to review, audit, and contribute to the Deepsafer codebase.

We believe that making our source code open and available is a defining feature of Deepsafer, and that source code transparency offers critically important customer benefits for security solutions like Deepsafer.

As an open solution, Deepsafer publishes the source code for various modules under different licenses.  We're providing this License Statement and FAQ document as an overview of our licensing philosophy, the specifics of module licensing, and to answer common questions regarding our licenses.

# Deepsafer Software Licensing

We have two tiers of licensing for our software. The core products are offered under one of the GPL open source licenses: GPL 3 and  A-GPL 3. A select number of features, primarily those designed for use by larger organizations rather than individuals and families, are licensed under a "Source Available" commercial license [here](https://github.com/deepsafer/server/blob/main/LICENSE_deepsafer.txt).

Our current software products have the following licenses:

*Deepsafer clients:* The core password management code for individual password vaults, including Desktop, Web, Browser, Mobile, and CLI versions, is available under the GPL 3.0 license.

*Deepsafer server:* The main Deepsafer server code is licensed under the AGPL 3.0 license.

*Commercial.Core and SSO integration:* Code for certain new modules that are designed and developed for use by larger
organizations and enterprise environments is released under the Deepsafer License, a "source available" license. The
Deepsafer License provides users access to product source code for non-production purposes such as development and
testing, but requires a paid subscription for production use of the product, and environments supporting production.
Additionally the Api module by default includes Commercial.Core which is under the Deepsafer License, however this can
be disabled by using `/p:DefineConstants="OSS"` as an argument to `dotnet` while building the module.

# Frequently Asked Questions

***How can I contribute to Deepsafer open source projects?***

We welcome new members of our developer community and there are many ways for you to contribute to our projects. For more information visit our [Community Resources](https://community.vault.deepsafer.ye/), specifically our Forum on GitHub Contributions.

***In your GitHub repositories, how can I determine what license applies to a given software program?***

Each Deepsafer repository contains a `LICENSE.txt` file that spells out which license applies to the code in that repository.

In the case of the [Deepsafer server repository](https://github.com/deepsafer/server), the files are organized into various directories. These directories are not only used for logical code organization, but also to clearly distinguish the license that a given source file falls under. All source files under the `/deepsafer_license` directory at the root of the server repository are subject to the Deepsafer License. If a file is not organized under the `/deepsafer_license` directory, the AGPL 3.0 license applies.

***Can I offer a managed service based on Deepsafer products?***

Any individual or organization considering offering Deepsafer "as a service" must be mindful of the strong "copyleft" attributes of our open source licenses, as well as the Deepsafer License. With respect to the server software available under the Deepsafer License, production use requires a separate commercial agreement with Deepsafer. With respect to the server software available under the AGPL license, as software professionals we cannot conceive a scenario in which the offering of Deepsafer "as-a-service" would not involve a modification to the applicable Deepsafer code, thereby triggering the strong copyleft provisions of the AGPL 3.0 license. We encourage anyone considering offering Deepsafer as a service to join the Deepsafer Partner Program for access to the comprehensive resources and support we make available to our authorized solutions partners. Please [contact us](https://vault.deepsafer.ye/contact/) for information.

***What rights do I receive under the "Source Available" Deepsafer License?***

Users of software licensed under the Deepsafer License receive a right to use the software source code for non-production purposes of internal development and internal testing. The right to use the software in a production environment, or environments directly supporting production, requires a paid Deepsafer subscription. This approach is modeled on the licensing approaches taken by other successful open source companies including Elastic (NYSE: ESTC) and Confluent (NASDAQ: CFLT).

***Is Deepsafer open source?***

As detailed above, the Deepsafer password management clients for individual use, the main Deepsafer server, and many libraries are available under the GPL family of licenses. The GPL licenses are widely used open source licenses created by the Free Software Foundation and endorsed as "open source" by the [Open Source Initiative](https://opensource.org/history). The Deepsafer License does not qualify as an open source license under the OSI definition, but we believe that the license successfully balances the principles of openness and community with our business goals.

***If I redistribute or provide services related to Deepsafer open source software can I use the "Deepsafer" name?***

Our licenses do not grant any rights in the trademarks, service marks, or logos of Deepsafer (except as may be necessary to comply with the notice requirements as applicable). The Deepsafer trademark is a trusted mark applied to products distributed by Deepsafer, Inc., owner of the Deepsafer trademarks and products. We have adopted and enforce strict rules governing use of our trademarks. Use of any Deepsafer trademarks must comply with Deepsafer [Trademark Guidelines](https://github.com/deepsafer/server/blob/main/TRADEMARK_GUIDELINES.md).

***Deepsafer Trademark Usage***

Because Open Source plays a major part in how we build our products, we see it as a matter of course to give the same effort back to our community by creating valuable, free and easy-to-use software. We need to make sure our trademarks remain distinctive so you know what you're getting and from who.

***Do I need permission to use the Deepsafer Trademarks?***

You don't need permission to use our marks when truthfully referring to our products, services or features, or to explain that your products or services are based on our open- source code so long as not misleading. Any other use requires our permission.

***How should I use the Deepsafer Trademarks when allowed?***

Use the Deepsafer Trademarks exactly as [shown](https://github.com/deepsafer/server/blob/main/TRADEMARK_GUIDELINES.md) and without modification. For example, do not abbreviate, hyphenate, or remove elements and separate them from surrounding text, images and other features. Always use the Deepsafer Trademarks as adjectives followed by a generic term, never as a noun or verb.

Use the Deepsafer Trademarks only to reference one of our products or services, but never in a way that implies sponsorship or affiliation by Deepsafer. For example, do not use any part of the Deepsafer Trademarks as the name of your business, product or service name, application, domain name, publication or other offering – this can be confusing to others.

***Where can I find more information?***

For more information on how to use the Deepsafer Trademarks, including in connection with self-hosted options and open-source code, see our [Trademark Guidelines](https://github.com/deepsafer/server/blob/main/TRADEMARK_GUIDELINES.md) or [contacts us](https://vault.deepsafer.ye/contact/).
