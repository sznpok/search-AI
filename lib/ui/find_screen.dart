import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gemini_ai/ui/detail_screen.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class FindScreen extends StatefulWidget {
  const FindScreen({super.key});

  @override
  State<FindScreen> createState() => _FindScreenState();
}

class _FindScreenState extends State<FindScreen> {
  GenerateContentResponse? responseResponse;
  GenerateContentResponse? outPutResponse;
  final TextEditingController findController = TextEditingController();

  bool _isLoading = false;

  create(String title) async {
    try {
      String apiKey = "AIzaSyA4v1UgPMacCmrRQb658NbY6B5DPe1-msE";
      if (apiKey.isEmpty) {
        log(apiKey.toString());
        return;
      }
      final model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: apiKey,
      );
      var content = "$title url ";

      setState(() {
        _isLoading = true;
      });

      responseResponse = await model.generateContent([Content.text(content)]);
      log(responseResponse!.text.toString());
      setState(() {
        _isLoading = false;
      });
      (context as Element).markNeedsBuild();
    } catch (e) {
      log('Error fetching content: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Companies"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFD7D3D3),
                    offset: Offset(
                      5.0,
                      5.0,
                    ),
                    blurRadius: 10.0,
                    spreadRadius: 2.0,
                  ),
                  BoxShadow(
                    color: Colors.white,
                    offset: Offset(0.0, 0.0),
                    blurRadius: 0.0,
                    spreadRadius: 0.0,
                  ),
                ],
              ),
              child: TextFormField(
                keyboardType: TextInputType.text,
                controller: findController,
                decoration: InputDecoration(
                  hintText: "search here...",
                  prefixIcon: const Icon(Icons.search),
                  contentPadding: const EdgeInsets.all(16.0),
                  suffixIcon: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      await create(findController.text);

                      findController.clear();
                    },
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          )
                        : Text(
                            "Search",
                            style:
                                Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            _isLoading
                ? const Expanded(
                    child: Center(
                      child:
                          CircularProgressIndicator(), // Centered progress indicator
                    ),
                  )
                : responseResponse != null
                    ? Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _buildUrlList(responseResponse!.text!),
                          ),
                        ),
                      )
                    : const Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("No Data found"),
                          ],
                        ),
                      ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildUrlList(String text) {
    final lines = text.split('\n');
    final urls = lines
        .where((line) => line.startsWith(RegExp(r'\d+\. ')))
        .map((line) => 'https://' + line.split(':')[1].trim())
        .toList();
    return lines
        .map((url) => TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailScreen(
                      title: url,
                    ),
                  ),
                );
              },
              child: Text(
                url,
                style: const TextStyle(
                  decoration: TextDecoration.underline,
                  color: Colors.blue,
                ),
              ),
            ))
        .toList();
  }
}
