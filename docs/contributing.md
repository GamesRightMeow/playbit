# Contributing guide
Thank you for considering making a contribution to Playbit - community involvement is warmly welcomed!

Following these guidelines helps to communicate that you respect the time of the developers managing and developing this open source project. In return, they should reciprocate that respect in addressing your issue, assessing changes, and helping you finalize your pull requests.

The main ways you can contribute are:
- Opening [issues](https://github.com/GamesRightMeow/playbit/issues) for bugs reports or feature requests.
- Leaving comments or reactions on issues to communicate your support for changes/fixes.
- Opening pull requests to address issues for documentation, bug fixes, or implementation of features.
- Participating in [community discussions](https://github.com/GamesRightMeow/playbit/discussions) about the future of Playbit.

# Your first Playbit contribution
Unsure where to begin? You can start by looking through issues with these labels: 
- [good-first-issue](https://github.com/GamesRightMeow/playbit/issues?q=is%3Aissue%20state%3Aopen%20label%3A%22good%20first%20issue%22): beginner issues that should either only require a few lines of code and/or little previous knowledge of Playbit.
- [help-wanted](https://github.com/GamesRightMeow/playbit/issues?q=is%3Aissue%20state%3Aopen%20label%3A%22help%20wanted%22): more advanced issues that maintainers are seeking contributors to help with.

If this is your first time contributing to an open source project, here are some resources to help you get started with open source contributions:
- https://www.firsttimersonly.com/
- https://makeapullrequest.com/
- [Finding ways to contribute to open source on GitHub](https://docs.github.com/get-started/exploring-projects-on-github/finding-ways-to-contribute-to-open-source-on-github)
- [Set up Git](https://docs.github.com/get-started/quickstart/set-up-git)
- [Collaborating with pull requests](https://docs.github.com/github/collaborating-with-pull-requests)

# Issues

# Pull requests

## Recreate SDK first then add user configuration 
One of Playbit's primary goals is to recreate the Playdate SDK as closely as possible. The idea being that users should be able to drop Playbit into their project, and have it run like it does on the Playdate.

However, when possible, Playbit should provide users with ways to configure default behaviors. Since desktop is a very different platform than Playdate, users will likely want to make tweaks to tailor the experience. Playbit should make this as easy as possible!

For example out-of-the-box Playbit uses the same input mapping as the Simulator but provides 
[a method for changing it](https://github.com/GamesRightMeow/playbit/blob/main/playbit/input.lua#L15).

## Do not submit code from the Playdate SDK

Any code taken directly from the Playdate SDK will be rejected as the [Playdate SDK License](https://play.date/dev/sdk-license/) prohibits distributing the SDK. Relevant excerpt:
> You will not:
> - Modify, disassemble, or decompile any part of the SDK;
> - Distribute or transfer the SDK to others (other than the incorporation of distributable elements of the SDK in Your Developed Programs in accordance with the terms of this Agreement);
> - Modify, adapt, alter, translate, or incorporate into or with other software or create a derivative work of any part of the SDK, except as permitted herein, without express written permission from Panic;
> - Use the SDK to develop applications for other platforms or to develop another SDK, without express written permission from Panic.

## Write small and focused pull requests
Aim to create small, focused pull requests that fulfill a single purpose. Smaller pull requests are easier and faster to review and merge, leave less room to introduce bugs, and provide a clearer history of changes. 

## Provide context and guidance
Write clear titles and descriptions for your pull requests so that reviewers can quickly understand what the pull request does. In the pull request body, include:

- The purpose of the pull request
- An overview of what changed
- Links to any additional context such as tracking issues or previous conversations

To help reviewers, share the type of feedback you need. For example, do you need a quick look or a deeper critique?

If your pull request consists of changes to multiple files, provide guidance to reviewers about the order in which to review the files. Recommend where to start and how to proceed with the review.

## Unit tests
TODO: write once unit test system is in place

## Code style

TODO: code style guide - is there a standard lua one we can link?