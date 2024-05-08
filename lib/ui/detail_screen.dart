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

  Future<void> output(String url) async {
    try {
      String sanitizedUrl = sanitizeUrl(url); // Sanitize the URL
      if (sanitizedUrl.isEmpty) {
        log('URL is empty or contains blacklisted keywords.');
        return;
      }

      String apiKey =
          "AIzaSyA4v1UgPMacCmrRQb658NbY6B5DPe1-msE"; // Fetch API key securely
      if (apiKey.isEmpty) {
        log('API Key is empty.');
        return;
      }

      final model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: apiKey,
      );
      var content =
          "I have this site $sanitizedUrl. Can you provide me contact details including company name, contact number, email address, and Address?";

      setState(() {
        _isLoading = true;
      });
      outPutResponse = await model.generateContent([Content.text(content)]);
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      log('Error fetching content: $e');
    }
  }

  String sanitizeUrl(String url) {
    // Define a list of keywords or phrases to remove
    final List<String> blacklist = ["spam", "malware", "phishing", "adult"];

    // Lowercase the URL for case-insensitive matching
    url = url.toLowerCase();

    // Check for presence of any blacklisted keywords
    for (var keyword in blacklist) {
      if (url.contains(keyword)) {
        return ""; // Return empty string if a blacklist keyword is found
      }
    }

    // If no blacklist keywords are found, return the original URL
    return url;
  }

  String appTitle(title) {
    RegExp regex = RegExp(r'\[(.*?)\]');
    String extractedString = regex.firstMatch(title)?.group(1) ?? '';
    return extractedString;
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
        title: Text(appTitle(widget.title)),
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
