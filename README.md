# Welcome to SSUMobile

This is the repository for the official iOS App for Sonoma State University.

## Contributing

To see what we are currently working on, check out the list of open [issues](/issues)

If you are new to `git` or Github, try out GitHub's [Try Git: Git Tutorial](https://try.github.io/)

If you are interested in contributing to the project, you can [fork the repo](https://guides.github.com/activities/forking/) and then submit a pull request. See GitHub's guide [Contributing to Open Source on GitHub](https://guides.github.com/activities/contributing-to-open-source/) for more info. 

If you would like to be added to the `ssu-cs-department` GitHub organization, please contact the current CS department chair.

## Swift & Objective-C

This project is currently written in Objective-C. With the introduction of Swift, it is clear that Swift is both more friendly to newcomers as well as the future of iOS development overall. In addition, SSU's `CS 470` covers iOS development in Swift, so it makes sense for this project to be written in Swift as well.

SSUMobile is undergoing gradual conversion to Swift. To track the progress of the migration to Swift, please see #18.

## Development Setup

To set up the project for local development, open `Terminal` and follow the steps below

First, clone the repo with git:

    git clone https://github.com/SSU-CS-Department/ssumobile-ios
    cd ssumobile-ios
    

Then, the CocoaPods dependency manager needs to be run to pull in dependencies.
If you do not have it installed already, see [here](http://guides.cocoapods.org/using/getting-started.html#installation) for installation instructions

    pod install
    open SSUMobile.xcworkspace
    
