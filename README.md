<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->
## ChatGpt Api client

you can request the chatgpt by the openai api

more detail about the openai api: [comletions](https://platform.openai.com/docs/api-reference/completions)

## Features

* ask questions to ChatGpt
* full model options supports , parameters detail: [comletions](https://platform.openai.com/docs/api-reference/completions)
* propmt support
* normal request and stream request support

## Getting started

TODO: List prerequisites and provide or point to information on how to
start using the package.

## Usage

the full example you can see the `./example`

```dart
/// init instance with the  model options
ChatGptApiClient client =
      ChatGptApiClient(api_key, ChatGptModelOption(stream: false));

/// send message to chatgpt
 client.sendMessage(text,
		    onData: (ChatGptApiResponse response) {
		          print(response);
		    }, 
		    onStreamData: (ChatGptApiResponse response) {
			  print(response);
		    }, 
		    onStreamEnd: () {
			  print('end');
		     });
```

## Additional information

If you have any questions, you can directly raise the issue
