library chatgpt_api_client;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

part './chatgpt_api_options.dart';
part './chatgpt_api_response.dart';

/// A Calculator.
class ChatGptApiClient {
  final String apiKey;
  final ChatGptModelOption chatGptModelOption;
  ChatGptApiClient(this.apiKey, this.chatGptModelOption) {
    chatGptModelOption.pushPropmt(
        '<|endoftext|>You are ChatGPT, a large language model trained by OpenAI.<|endoftext|>');
  }

  cleanPropmt() {
    chatGptModelOption.propmt.clear();
  }

  sendMessage(String msg,
      {
      /// callback when chatGptModelOption.propmt = true and response data come
      Function(ChatGptApiResponse response)? onStreamData,

      /// callback when stream response finish
      Function? onStreamEnd,

      /// callback when response end
      Function(ChatGptApiResponse response)? onData}) async {
    // this.chatGptModelOption.pushPropmt('<|endoftext|>');
    chatGptModelOption.pushPropmt('User:\n $msg<|endoftext|>\n ChatGPT: \n\n');
    // print('msg ------------------');
    // print(chatGptModelOption.propmt.join('\n'));

    // print('end meg ------------------');
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

    List<ChatGptApiResponse> rss = [];

    responseBody.data?.stream
        .transform(unit8Transformer)
        .transform(const Utf8Decoder())
        .listen((event) {
      // unicode
      String decoded = decodeUniconByString(event);

      if (chatGptModelOption.stream) {
        if (decoded.trim() != 'data: [DONE]') {
          if (onStreamData != null) {
            ChatGptApiResponse rs = ChatGptApiResponse.fromJson(
                jsonDecode(decoded.replaceFirst("data:", "")));
            rss.add(rs);
            onStreamData(rs);
          }
        } else {
          if (onStreamEnd != null) {
            Iterable<String> s = rss.map((ChatGptApiResponse rs) {
              return rs.choices[0].text;
            });
            String ss = s.toList().join();
            print(ss);
            onStreamEnd();
          }
        }
      } else {
        if (onData != null) {
          ChatGptApiResponse rs =
              ChatGptApiResponse.fromJson(jsonDecode(decoded));

          chatGptModelOption.propmt.add('${rs.choices[0].text}<|endoftext|>\n');

          onData(rs);
        }
      }
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
