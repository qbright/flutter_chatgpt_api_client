part of './chatgpt_api_client.dart';

class ChatGptApiResponse {
  final String id;
  final String object;
  final int created;
  final ResponseUsage? usage;
  final List<ResponseChoice> choices;

  ChatGptApiResponse(
      this.id, this.object, this.created, this.usage, this.choices);

  factory ChatGptApiResponse.fromJson(Map<String, dynamic> json) {
    List<ResponseChoice> choices = [];
    (json['choices'] as List<dynamic>).forEach((item) {
      choices.add(ResponseChoice.fromJson(item));
    });
    ResponseUsage? usage =
        json['usage'] != null ? ResponseUsage.fromJson(json['usage']) : null;
    return ChatGptApiResponse(
        json['id'], json['object'], json['created'], usage, choices);
  }
}

class ResponseChoice {
  final String text;
  final int index;
  final int? logprobs;
  final String? finish_reason;
  ResponseChoice(this.text, this.index, this.logprobs, this.finish_reason);

  factory ResponseChoice.fromJson(Map<String, dynamic> json) {
    return ResponseChoice(
        json['text'], json['index'], json['logprobs'], json['finish_reason']);
  }
}

class ResponseUsage {
  final int prompt_tokens;
  final int completion_tokens;
  final int total_tokens;
  ResponseUsage(this.prompt_tokens, this.completion_tokens, this.total_tokens);

  factory ResponseUsage.fromJson(Map<String, dynamic> json) {
    return ResponseUsage(
        json['prompt_tokens'], json['completion_tokens'], json['total_tokens']);
  }
}
