import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:eppser/Web/AboutPageMobile.dart';
import 'package:eppser/Web/FAQPageMobile.dart';
import 'package:eppser/Web/WebLandingPageMobile.dart';
import 'package:eppser/Widgets/FadeInUp.dart';
import 'package:flutter/material.dart';

class ContactPageMobile extends StatefulWidget {
  const ContactPageMobile({super.key});

  @override
  State<ContactPageMobile> createState() => _ContactPageMobileState();
}

class _ContactPageMobileState extends State<ContactPageMobile> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSubmitting = true;
      });

      final name = _nameController.text;
      // ignore: unused_local_variable
      final email = _emailController.text;
      // ignore: unused_local_variable
      final message = _messageController.text;

      await Future.delayed(Duration(seconds: 2));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mesaj gönderildi: $name')),
      );

      setState(() {
        _isSubmitting = false;
      });

      _nameController.clear();
      _emailController.clear();
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 70,
        backgroundColor: Colors.black,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 14, left: 16),
              child: AnimatedTextKit(
                totalRepeatCount: 1,
                animatedTexts: [
                  TypewriterAnimatedText(
                    "#goldisrealmoney",
                    textStyle: const TextStyle(
                        fontFamily: 'font1', fontSize: 42, color: Colors.amber),
                  ),
                  WavyAnimatedText("eppser",
                      textStyle: const TextStyle(
                          fontFamily: 'font1',
                          fontSize: 42,
                          color: Colors.white),
                      speed: const Duration(milliseconds: 150)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton(
            icon: Image.asset('assets/icons/menu.png'),
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                    child: InkWell(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WebLandingPageMobile(),
                      )),
                  child: const Text(
                    "Ana Sayfa",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                )),
                PopupMenuItem(
                    child: InkWell(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AboutPageMobile(),
                      )),
                  child: const Text(
                    "Hakkımızda",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                )),
                const PopupMenuItem(
                  child: Text(
                    "İletişim",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                PopupMenuItem(
                    child: InkWell(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FAQPageMobile(),
                      )),
                  child: const Text(
                    "SSS",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                ))
              ];
            },
          ),
          const SizedBox(
            width: 12,
          )
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: Center(
                  child: SingleChildScrollView(
                    child: FadeInUpWidget(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            const Text(
                              'Bizimle İletişime Geçin',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 60),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 24),
                            _buildTextField(
                              controller: _nameController,
                              label: 'Adınız',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Lütfen adınızı girin';
                                }
                                return null;
                              },
                            ),
                            _buildTextField(
                              controller: _emailController,
                              label: 'E-posta Adresiniz',
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Lütfen e-posta adresinizi girin';
                                }
                                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                    .hasMatch(value)) {
                                  return 'Geçerli bir e-posta adresi girin';
                                }
                                return null;
                              },
                            ),
                            _buildTextField(
                              controller: _messageController,
                              label: 'Mesajınız',
                              maxLines: 5,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Lütfen mesajınızı girin';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),
                            SizedBox(
                              width: 100,
                              child: ElevatedButton(
                                onPressed: _isSubmitting ? null : _submitForm,
                                child: _isSubmitting
                                    ? CircularProgressIndicator(
                                        color: Colors.white)
                                    : Text('Gönder'),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  textStyle: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                color: Colors.black,
                padding: const EdgeInsets.symmetric(
                    vertical: 24.0, horizontal: 32.0),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo and Description
                    Center(
                      child: Text(
                        "eppser",
                        style: TextStyle(
                            fontFamily: 'font1',
                            fontSize: 42,
                            color: Colors.white),
                      ),
                    ),

                    SizedBox(height: 24),
                    // Copyright
                    Text(
                      "© 2024 eppser Technology - Tüm Hakları Saklıdır",
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  TextInputType? keyboardType,
  required FormFieldValidator<String> validator,
  int? maxLines,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16.0),
    child: TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
    ),
  );
}
