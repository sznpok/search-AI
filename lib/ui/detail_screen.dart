import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, this.title});

  final String? title;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  GenerateContentResponse? outPutResponse;
  bool _isLoading = false;

  output(String url) async {
    try {
      String apiKey =
          "AIzaSyA4v1UgPMacCmrRQb658NbY6B5DPe1-msE"; // Fetch API key securely
      if (apiKey.isEmpty) {
        log(apiKey.toString());
        return;
      }
      final model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: apiKey,
      );
      var content =
          "I have this site $url .can you provide me contact details including company name, contact number, email address and Address";

      setState(() {
        _isLoading = true;
      });
      outPutResponse = await model.generateContent([Content.text(content)]);
      setState(() {
        _isLoading = false;
      });
      (context as Element).markNeedsBuild();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      log('Error fetching content: $e');
    }
  }

  @override
  void initState() {
    output(widget.title!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: outPutResponse != null && !_isLoading
          ? SizedBox(
              width: double.infinity,
              child: Card(
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: outPutResponse != null &&
                          outPutResponse!.candidates.isNotEmpty
                      ? (outPutResponse!.text != null
                          ? Text(outPutResponse!.text!.replaceAll("*", ""))
                          : const Text("No Data available"))
                      : const Text(
                          "Error: Content generation blocked due to safety."),
                ),
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
