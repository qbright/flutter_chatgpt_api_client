library chatgpt_api_client;

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

part './chatgpt_api_options.dart';
part './chatgpt_api_response.dart';

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
    chatGptModelOption.pushPropmt('User:\n $msg<|endoftext|>\n ChatGPT:\n ');

    Dio dio = Dio();

    const url = 'https://api.openai.com/v1/completions';

    if (chatGptModelOption.maxPropmtStack != null &&
        chatGptModelOption.maxPropmtStack! < chatGptModelOption.propmt.length) {
      chatGptModelOption.propmt = chatGptModelOption.propmt.sublist(
          chatGptModelOption.propmt.length -
              chatGptModelOption.maxPropmtStack!);
    }
    print(chatGptModelOption.propmt);
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
            chatGptModelOption.propmt.add('$ss<|endoftext|>\n');
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
