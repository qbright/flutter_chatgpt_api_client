library chatgpt_api_client;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

part './chatgpt_api_options.dart';

/// A Calculator.
class ChatGptApiClient {
  final String apiKey;
  final ChatGptModelOption chatGptModelOption;
  ChatGptApiClient(this.apiKey, this.chatGptModelOption) {
    sendMessage('你是ChatGpt吗?');
  }

  sendMessage(String msg) async {
    this.chatGptModelOption.pushPropmt(msg);
    print('msg');

    Dio dio = Dio();

    const url = 'https://api.openai.com/v1/completions';

    // Response responseBody = await dio.post(url,
    //     data: chatGptModelOption.toJson(),
    //     options: Options(headers: {
    //       'content-type': 'application/json',
    //       'Authorization': 'Bearer $apiKey'
    //     }));

    // print(responseBody.data);
// {id: cmpl-6iZY6oCweuSeI8b83fUiVeLKJETN3, object: text_completion, created: 1676081102, model: text-davinci-003, choices: [{text:
//  I/flutter (15213): 我是一个学生。, index: 0, logprobs: null, finish_reason: stop}], usage: {prompt_tokens: 6, completion_tokens: 12, total_tokens: 18}}

// // stream ////////////////////////////////////
    Response<ResponseBody> responseBody = await dio.post(url,
        data: chatGptModelOption.toJson(),
        options: Options(headers: {
          'content-type': 'application/json',
          'Authorization': 'Bearer $apiKey'
        }, responseType: ResponseType.stream));
    StreamTransformer<Uint8List, List<int>> unit8Transformer =
        StreamTransformer.fromHandlers(
      handleData: (data, sink) {
        sink.add(List<int>.from(data));
      },
    );

    responseBody.data?.stream
        .transform(unit8Transformer)
        .transform(const Utf8Decoder())
        // .transform(const LineSplitter())
        .listen((event) {
      // unicode
      String decoded = decodeUniconByString(event);

      if (chatGptModelOption.stream) {
        if (decoded.trim() != 'data: [DONE]') {
          print(jsonDecode(decoded.replaceFirst("data:", "")));
        } else {
          print('dddddddddd');
        }
      } else {
        print(decoded);
      }
      // print(event);
    });

// stream  response I/flutter (15213): {id: cmpl-6iQ2sGLBQd3InsDTjldnEgRfjE7Yj, object: text_completion, created: 1676044570, choices: [{text: 一, index: 0, logprobs: null, finish_reason: null}], model: text-davinci-003}
// stream end response [DONE]

//     //end stream ////////////////////////////////////
  }
}

String decodeUniconByString(String event) {
  var re = RegExp(
    r'(%(?<asciiValue>[0-9A-Fa-f]{2}))'
    r'|(\\u(?<codePoint>[0-9A-Fa-f]{4}))'
    r'|.',
  );
  var matches = re.allMatches(event);
  var codePoints = <int>[];
  for (var match in matches) {
    var codePoint =
        match.namedGroup('asciiValue') ?? match.namedGroup('codePoint');
    if (codePoint != null) {
      codePoints.add(int.parse(codePoint, radix: 16));
    } else {
      codePoints += match.group(0)!.runes.toList();
    }
  }
  return String.fromCharCodes(codePoints);
}
