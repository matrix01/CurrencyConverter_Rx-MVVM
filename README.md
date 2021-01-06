# Currency converter
### Sameple project to demonstrate clean architechture with RxSwift.

This project only demostrate fetching live data from currencylayer.com using 2 api.
1. https://api.currencylayer.com/live
2. https://api.currencylayer.com/list
To collect recent currency rates and list of available currencies

1. If the source currency is not changed it will not call api for new data in 30 mins
2. Enter the desire amount in the text box to see the calculated result for each currency
3. Click the down arrow button to see the list of available currency

### How to run the project
1. Install pod; Run command "pod install" from project directory
2. Build & Run project
3. To do some basic test, please check the "Pay-BaymaxTests.swift" file

### Requirements
1. Project was done in XCODE 11.6, also tested in 11.3.1 (Please update if the xcode version is lower than this)
2. iOS device//Simulator 12.0 is selected as min version as it wasn't mentioned

### Git Emoji
1. I am using gitmoji cli for commiting message with emoji


## Thank you and happy coding
