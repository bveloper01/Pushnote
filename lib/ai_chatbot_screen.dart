import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:url_launcher/url_launcher.dart';

class AIChatbotScreen extends StatefulWidget {
  const AIChatbotScreen({super.key});

  @override
  State<AIChatbotScreen> createState() => _AIChatbotScreenState();
}

class _AIChatbotScreenState extends State<AIChatbotScreen> {
  late final Gemini gemini = Gemini.instance;

  List<ChatMessage> messages = [];

  ChatUser currentUser = ChatUser(id: "0", firstName: "User");
  ChatUser geminiUser = ChatUser(
    id: "1",
    firstName: "Zineth",
    profileImage:
        "https://i.pinimg.com/236x/23/50/2d/23502d3c9e95b8a95f9484ec8f2e58f8.jpg",
  );
  double height = AppBar().preferredSize.height;

  void chatbot() async {
    await dotenv.load(fileName: '.env');
    Gemini.init(apiKey: dotenv.env['API_KEY']!);
  }

  @override
  void initState() {
    chatbot();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        surfaceTintColor: Colors.blue,
        backgroundColor: const Color.fromARGB(255, 196, 219, 237),
        title: const Text(
          'AI Chatbot',
          style: TextStyle(
              color: Color.fromARGB(255, 23, 23, 23),
              fontSize: 21,
              fontWeight: FontWeight.w600),
        ),
      ),
      body: _buildUI(),
      backgroundColor: const Color.fromARGB(255, 239, 236, 226),
    );
  }

  Widget _buildUI() {
    return Container(
      padding: const EdgeInsets.only(left: 5, right: 5, bottom: 5),
      child: DashChat(
        inputOptions: InputOptions(
          textCapitalization: TextCapitalization.sentences,
          autocorrect: true,
          inputDecoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            hintText: "Ask Zineth..",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          sendButtonBuilder: (Function() onSend) {
            return Container(
              margin: const EdgeInsets.only(left: 7),
              width: 40,
              height: 40,
              child: FloatingActionButton(
                heroTag: 'synergy',
                shape: const CircleBorder(),
                onPressed: onSend,
                elevation: 0,
                backgroundColor: Colors.blue,
                child: const Icon(
                  Icons.send,
                  size: 22,
                  color: Colors.white,
                ),
              ),
            );
          },
          trailing: [
            Container(
              margin: const EdgeInsets.only(left: 6),
              width: 40,
              height: 40,
              child: FloatingActionButton(
                heroTag: 'yess',
                shape: const CircleBorder(),
                elevation: 0,
                onPressed: _sendMediaMessage,
                child: const Icon(
                  Icons.image_rounded,
                  size: 22,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        messageOptions: MessageOptions(
          currentUserContainerColor: const Color.fromARGB(255, 178, 236, 209),
          currentUserTextColor: Colors.black,
          messageTextBuilder: (ChatMessage message,
              ChatMessage? previousMessage, ChatMessage? nextMessage) {
            return _buildMessageText(message);
          },
        ),
        currentUser: currentUser,
        onSend: _sendMessage,
        messages: messages,
      ),
    );
  }

  Widget _buildMessageText(ChatMessage message) {
    final messageTextSpans = _parseMessageText(message.text);
    return RichText(
      text: TextSpan(
        children: messageTextSpans,
        style: TextStyle(
          color:
              message.user.id == currentUser.id ? Colors.black : Colors.black,
        ),
      ),
    );
  }

  List<TextSpan> _parseMessageText(String text) {
    final textSpans = <TextSpan>[];
    final regex = RegExp(
        r'(\*\*(.*?)\*\*)|(\*(.*?)\*)|(\bhttps?://[^\s]+\b)'); // Regex to detect bold text, bullet points, and URLs
    final matches = regex.allMatches(text);
    int start = 0;

    for (final match in matches) {
      if (match.start > start) {
        textSpans.add(TextSpan(text: text.substring(start, match.start)));
      }
      final boldText = match.group(2);
      final bulletText = match.group(4);
      final linkText = match.group(5);

      if (boldText != null) {
        textSpans.add(TextSpan(
          text: boldText,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ));
      } else if (bulletText != null) {
        textSpans.add(
          TextSpan(
            text: '\u2022 $bulletText\n', // Unicode for bullet point
            style: const TextStyle(fontWeight: FontWeight.normal),
          ),
        );
      } else if (linkText != null) {
        textSpans.add(
          TextSpan(
            text: linkText,
            style: const TextStyle(color: Colors.blue),
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                final url = Uri.parse(linkText);
                if (!await launchUrl(url)) {
                  throw Exception('Could not launch $url');
                }
              },
          ),
        );
      }
      start = match.end;
    }

    if (start < text.length) {
      textSpans.add(TextSpan(text: text.substring(start)));
    }

    return textSpans;
  }

  void _sendMessage(ChatMessage chatMessage) {
    setState(() {
      messages = [chatMessage, ...messages];
    });
    try {
      String question = chatMessage.text;
      List<Uint8List>? images;
      if (chatMessage.medias?.isNotEmpty ?? false) {
        images = [
          File(chatMessage.medias!.first.url).readAsBytesSync(),
        ];
      }
      gemini
          .streamGenerateContent(
        question,
        images: images,
      )
          .listen((event) {
        ChatMessage? lastMessage = messages.firstOrNull;
        if (lastMessage != null && lastMessage.user == geminiUser) {
          lastMessage = messages.removeAt(0);
          String response = event.content?.parts?.fold(
                  "", (previous, current) => "$previous${current.text}") ??
              "";
          lastMessage.text += response;
          setState(() {
            messages = [lastMessage!, ...messages];
          });
        } else {
          String response = event.content?.parts?.fold(
                  "", (previous, current) => "$previous${current.text}") ??
              "";
          ChatMessage message = ChatMessage(
            user: geminiUser,
            createdAt: DateTime.now(),
            text: response,
          );
          setState(() {
            messages = [message, ...messages];
          });
        }
      });
    } catch (e) {
      print(e);
    }
  }

  void _sendMediaMessage() async {
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (file != null) {
      ChatMessage chatMessage = ChatMessage(
        user: currentUser,
        createdAt: DateTime.now(),
        text: "Describe this picture?",
        medias: [
          ChatMedia(
            url: file.path,
            fileName: "",
            type: MediaType.image,
          )
        ],
      );
      _sendMessage(chatMessage);
    }
  }
}
