import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var myAPiKye = "your_api_key";
  TextEditingController controller = TextEditingController();
  var imageUrl = '';
  bool isLoading = false;
  void generateImage(prompt) async {
    setState(() {
      isLoading = true;
    });
    final apiKey = myAPiKye;
    final uri = Uri.parse('https://api.openai.com/v1/images/generations');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey'
    };
    final body = jsonEncode({
      'model': 'dall-e-3',
      'prompt': '$prompt',
      'size': '1024x1024',
      'quality': 'standard',
      'n': 1,
    });

    try {
      final response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        var imageUrl = responseData['data'][0]['url'];
        print('Image URL: $imageUrl');

        setState(() {
          imageUrl = imageUrl;
          isLoading = false;
        });
      } else {
        print('Failed to generate image: ${response.body}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: Container(
        margin: const EdgeInsets.all(20),
        child: Stack(
          children: [
            Container(
              child: Column(
                children: [
                  const SizedBox(
                    height: 40,
                  ),
                  const Text(
                    "Generate Image With AI !",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 40),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  isLoading
                      ? Builder(builder: (context) {
                          return const CircularProgressIndicator();
                        })
                      : imageUrl != ''
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                imageUrl,
                                width: 400,
                                height: 400,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Container(),
                ],
              ),
            ),
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextField(
                    controller: controller,
                    maxLines: 6,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade800,
                        hintText: "Enter description of the image",
                        hintStyle: const TextStyle(color: Colors.white60),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        )),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        onPressed: () {
                          if (!isLoading) {
                            generateImage(controller.text);
                          }
                        },
                        child: Text(
                          isLoading ? "Generating..." : "Generate Image",
                          style: const TextStyle(fontSize: 19),
                        )),
                  ),
                  const SizedBox(
                    height: 30,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
