# logmatic-ios
Send log entries to Logmatic.io directly from your iOS apps.

## Features

- Use the library as a logger. Everything is forwarded to Logmatic.io as JSON documents.
- Metas and extra attributes
- Track real client IP address and user-agent (optional)
- Save logs if no internet connection and try again later

## Quick Start

### Load and initialize logger

#### Install via [CocoaPods](http://cocoapods.org)
To integrate Logmatic into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'

pod 'Logmatic', '~> 1.0'
```

#### Objc-C usage

You can start the logger whenever you want. The `application: didFinishLaunchingWithOptions:` method is probably a good choice in order to start logging as soon as possible.
Set your API key into the shared logger, add optional infos if needed and start the logger.

```objc
#import <Logmatic/LMLogger.h>
...

LMLogger * logger = [LMLogger sharedLogger];
// Set your API key, it can be found on your Logmatic.io platform.
[logger setKey:@"your_key"];

// OPTIONAL init methods
// add some meta attributes in final JSON
[logger setMetas:@{@"userId": @"1234"}];
// resolve client UA and copy it @ 'client.user-agent'
[logger setUserAgentTracking:@"client.user-agent"];
// resolve client IP and copy it @ 'client.IP'
[logger setIPTracking:@"client.IP"];

// don't forget to start the logger!
[logger startLogger];
```

### Usage

#### Fire your own events

To log some events you simply there is simple an unique method called `log: withMessage:`. The first parameter is a NSDictionary which is the JSON object you want to log. You can add an optional message.

```objc
NSDictionary * simpleJSON = @{@"name": @"My button name"};
[[LMLogger sharedLogger] log:simpleJSON withMessage:@"Button clicked"];
```

To clearly explain what happens here, in this exact situation where everything is configured as above the API POSTs the following JSON content to *Logmatic.io*'s API.:

```json
{
  "severity": "info",
  "userId": "1234",
  "name": "My button name",
  "message": "Button clicked",
  "url": "...",
  "client": {
    "IP" : "109.30.xx.xxx",
    "user-agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.130 Safari/537.36"
  }
}
```

## API

You must set the api key to configure the shared logger:
```
[[LMLogger sharedLogger] setKey:<your_api_key>];
```

There is only one method to send log events to *Logmatic.io*:
```
[[LMLogger sharedLogger] log:<context> withMessage:<message>];
```

You can also use all the following parameters using the right method:

| Method        | Description           |  Example  |
| ------------- | ------------- |  ----- |
| setMetas: | add some meta attributes in final JSON | `[logger setMetas:@{@"userId": @"1234"}];` |
| setIPTracking: | resolve client IP and copy it @ ip_attr | `[logger setIPTracking:@"client.IP"];`|
| setUserAgentTracking: | resolve client UA and copy it @ ua_attr | `[logger setUserAgentTracking:@"client.user-agent"];`|
