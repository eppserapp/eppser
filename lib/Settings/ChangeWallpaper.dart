import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class Changewallpaper extends StatefulWidget {
  const Changewallpaper({super.key});

  @override
  State<Changewallpaper> createState() => _ChangewallpaperState();
}

class _ChangewallpaperState extends State<Changewallpaper> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'Duvar Kağıdı',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Iconsax.arrow_left_2,
            color: Theme.of(context).textTheme.bodyMedium?.color,
            size: 32,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: const DecorationImage(
                        image: AssetImage('assets/images/background3.jpg'),
                        fit: BoxFit.cover),
                  ),
                  height: 500,
                  width: MediaQuery.of(context).size.width - 100,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      height: 180,
                      width: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Stack(
                        children: [
                          Image.asset(
                            'assets/images/logo.png',
                            height: 180,
                            width: 180,
                          ),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 20),
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Text(
                                'Wallpaper',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Container(
                      height: 180,
                      width: 180,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: GestureDetector(
                        onTap: () {},
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Iconsax.gallery,
                              color: Colors.white,
                              size: 100,
                            ),
                            Text(
                              'Galeri',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18))),
                  onPressed: () {},
                  child: const Text(
                    'Varsayılanı Ayarla',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ))
            ],
          ),
        ],
      ),
    );
  }
}
