import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:vai/screens/widgets/feature_box.dart';
import 'package:vai/services/openai_service.dart';
import 'package:vai/utils/color_manager.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final speechToText = SpeechToText();
  String lastWords = '';

  final OpenAiService openAiService = OpenAiService();
  final flutterTts = FlutterTts();
  String? generatedContent;
  String? generatedImageUrl;
  int start = 200;
  int delay = 200;
  @override
  void initState() {
    super.initState();
    initSpeechToText();
    initTextToSpeech();
  }

  Future<void> initTextToSpeech() async {
    await flutterTts.setSharedInstance(true);
    setState(() {});
  }

  //initialize speech
  Future<void> initSpeechToText() async {
    await speechToText.initialize();
    setState(() {});
  }

  //start speech recognition
  Future<void> startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {});
  }

  //stop speech recognition
  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  Future<void> systemSpeak(String content) async {
    await flutterTts.speak(content);
  }

  @override
  void dispose() {
    super.dispose();
    speechToText.stop();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BounceInDown(child: const Text('VAI')),
        leading: const Icon(Icons.menu),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ZoomIn(
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      height: 120,
                      width: 120,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: const BoxDecoration(
                        color: ColorManager.assistantCircleColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Container(
                    height: 123,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage(
                          'assets/images/vai.jpeg',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // chat
            FadeInRight(
              child: Visibility(
                visible: generatedImageUrl == null,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 40)
                      .copyWith(top: 30),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: ColorManager.borderColor,
                    ),
                    borderRadius: BorderRadius.circular(20).copyWith(
                      topLeft: Radius.zero,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10.0,
                    ),
                    child: Text(
                      generatedContent == null
                          ? 'Good Morning, How Can I Help You?'
                          : generatedContent!,
                      style: TextStyle(
                        fontFamily: 'Cera Pro',
                        color: ColorManager.mainFontColor,
                        fontSize: generatedContent == null ? 25 : 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            if (generatedImageUrl != null)
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(generatedImageUrl!)),
              ),

            SlideInLeft(
              child: Visibility(
                visible: generatedContent == null && generatedImageUrl == null,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(top: 10, left: 22),
                  child: const Text(
                    'Try these features',
                    style: TextStyle(
                      fontFamily: 'Cera Pro',
                      color: ColorManager.mainFontColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            Visibility(
              visible: generatedContent == null && generatedImageUrl == null,
              child: Column(
                children: [
                  SlideInLeft(
                    delay: Duration(milliseconds: start),
                    child: const FeatureBox(
                      color: ColorManager.firstSuggestionBoxColor,
                      headerText: 'ChatGPT',
                      descriptionText:
                          'A smarter way to stay organized and informed with ChatGPT',
                    ),
                  ),
                  SlideInLeft(
                    delay: Duration(milliseconds: start + delay),
                    child: const FeatureBox(
                      color: ColorManager.secondSuggestionBoxColor,
                      headerText: 'Dall-E',
                      descriptionText:
                          'Get Inspired and stay creative with your personal assistant',
                    ),
                  ),
                  SlideInLeft(
                    delay: Duration(milliseconds: start + 2 * delay),
                    child: const FeatureBox(
                      color: ColorManager.thirdSuggestionBoxColor,
                      headerText: 'Smart Voice Assistant',
                      descriptionText:
                          'Get the best of both worlds with a voice assitant powered by Dall-E and ChatGPT',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (await speechToText.hasPermission && speechToText.isNotListening) {
            await startListening();
          } else if (speechToText.isListening) {
            final speech = await openAiService.isArtPromptAPI(lastWords);
            if (speech.contains('https')) {
              generatedImageUrl = speech;
              generatedContent = null;
            } else {
              generatedImageUrl = null;
              generatedContent = speech;
              await systemSpeak(speech);
            }

            await stopListening();
          } else {
            initSpeechToText();
          }
        },
        backgroundColor: ColorManager.firstSuggestionBoxColor,
        child: Icon(speechToText.isListening ? Icons.stop : Icons.mic),
      ),
    );
  }
}
