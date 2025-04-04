import 'package:flutter/material.dart';
import 'package:furever_home/views/screens/event_screen.dart';
import 'package:furever_home/views/screens/adopted_dogs_screen.dart';
import 'package:furever_home/views/screens/dog_screen.dart';
import 'package:furever_home/views/screens/donation_screen.dart';
import 'medical_services_screen.dart';
import 'about_screen.dart';

import 'package:url_launcher/url_launcher.dart';

class MerchScreen extends StatefulWidget {
  const MerchScreen({super.key});

  @override
  State<MerchScreen> createState() => _MerchScreenState();
}

class _MerchScreenState extends State<MerchScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _searchQuery = '';
  String _selectedCategory = '';

  void _showProductDetails(Map<String, dynamic> product) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Close button
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              // Image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.asset(
                  product['image'],
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      product['name'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Category
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF32649B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        product['category'],
                        style: const TextStyle(
                          color: Color(0xFF32649B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Description
                    Text(
                      product['description'],
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Shop Now Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _launchURL(product['url']),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF32649B),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Shop Now',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}


  // Sample product data
  final List<Map<String, dynamic>> _products = [
    {
      'name': 'TopBreed Dry Dog Food',
      'description': 'Premium quality dog food with balanced nutrition',
      'category': 'Treats',
      'image': 'assets/images/dog-food-1.jpg',
      'url':
          'https://www.lazada.com.ph/products/topbreed-dry-dog-food-adultpuppy-20kg-sack-i5004551848-s29267041772.html?c=&channelLpJumpArgs=&clickTrackInfo=query%253A%253Bnid%253A5004551848%253Bsrc%253ALazadaMainSrp%253Brn%253A611be01b68988bf79c67690b8dbadecd%253Bregion%253Aph%253Bsku%253A5004551848_PH%253Bprice%253A3230%253Bclient%253Adesktop%253Bsupplier_id%253A501424000291%253Bbiz_source%253Ah5_internal%253Bslot%253A2%253Butlog_bucket_id%253A470687%253Basc_category_id%253A21917%253Bitem_id%253A5004551848%253Bsku_id%253A29267041772%253Bshop_id%253A5760251%253BtemplateInfo%253A107881_D_E%2523-1_A3_C%2523&freeshipping=1&fs_ab=2&fuse_fs=&lang=en&location=Albay&price=3.23E%203&priceCompare=skuId%3A29267041772%3Bsource%3Alazada-search-voucher%3Bsn%3A611be01b68988bf79c67690b8dbadecd%3BoriginPrice%3A323000%3BdisplayPrice%3A323000%3BsinglePromotionId%3A-1%3BsingleToolCode%3AmockedSalePrice%3BvoucherPricePlugin%3A0%3Btimestamp%3A1742821265816&ratingscore=&request_id=611be01b68988bf79c67690b8dbadecd&review=&sale=0&search=1&source=search&spm=a2o4l.SearchListBrand.list.2&stock=1',
    },
    {
      'name': 'Dr Shiba Anti Flea & Tick Spray',
      'description': 'Keeps your Pet Protected and Itch-free',
      'category': 'Health',
      'image': 'assets/images/dog-health-1.jpg',
      'url':
          'https://www.lazada.com.ph/products/dr-shiba-anti-flea-tick-spray-and-soap-bundle-for-dogs-cats-keeps-your-pet-protected-and-itch-free-strengthens-your-pets-defences-uses-the-natural-power-of-citronella-eucalyptus-and-neem-oil-i4473423029-s25484993043.html?c=&channelLpJumpArgs=&clickTrackInfo=query%253Adr%25252520shiba%25252520%25252520anti%25252520flea%253Bnid%253A4473423029%253Bsrc%253ALazadaMainSrp%253Brn%253Ad46da13697ef49e89a89b37779ffdf46%253Bregion%253Aph%253Bsku%253A4473423029_PH%253Bprice%253A424%253Bclient%253Adesktop%253Bsupplier_id%253A500188287031%253Bbiz_source%253Ah5_internal%253Bslot%253A2%253Butlog_bucket_id%253A470687%253Basc_category_id%253A24329%253Bitem_id%253A4473423029%253Bsku_id%253A25484993043%253Bshop_id%253A2813964%253BtemplateInfo%253A107881_D_E%2523-1_A3_C%2523&freeshipping=1&fs_ab=2&fuse_fs=&lang=en&location=Metro%20Manila~Las%20Pinas&price=424&priceCompare=skuId%3A25484993043%3Bsource%3Alazada-search-voucher%3Bsn%3Ad46da13697ef49e89a89b37779ffdf46%3BoriginPrice%3A42400%3BdisplayPrice%3A42400%3BsinglePromotionId%3A900000046498025%3BsingleToolCode%3ApromPrice%3BvoucherPricePlugin%3A0%3Btimestamp%3A1742821995943&ratingscore=4.956818181818182&request_id=d46da13697ef49e89a89b37779ffdf46&review=440&sale=1020&search=1&source=search&spm=a2o4l.searchList.list.2&stock=1',
    },
    {
      'name': 'Dog Toy Squeak Squeaker',
      'description': 'Pet Toy Screaming Chicken Yellow Rubber Chicken',
      'category': 'Toys',
      'image': 'assets/images/dog-toy-1.jpg',
      'url':
          'https://www.lazada.com.ph/products/pet-toy-screaming-chicken-yellow-rubber-chicken-pet-dog-toy-squeak-squeaker-i3445861883-s17684253765.html?c=&channelLpJumpArgs=&clickTrackInfo=query%253Atoys%252Bfor%252Bdogs%253Bnid%253A3445861883%253Bsrc%253ALazadaMainSrp%253Brn%253A22e7e63e5403e7959a22b342c1da61ba%253Bregion%253Aph%253Bsku%253A3445861883_PH%253Bprice%253A22.28%253Bclient%253Adesktop%253Bsupplier_id%253A500226228217%253Bbiz_source%253Ah5_internal%253Bslot%253A1%253Butlog_bucket_id%253A470687%253Basc_category_id%253A10100632%253Bitem_id%253A3445861883%253Bsku_id%253A17684253765%253Bshop_id%253A3376683%253BtemplateInfo%253A107881_D_E%2523-1_A3_C%2523&freeshipping=1&fs_ab=2&fuse_fs=&lang=en&location=Bulacan&price=22.28&priceCompare=skuId%3A17684253765%3Bsource%3Alazada-search-voucher%3Bsn%3A22e7e63e5403e7959a22b342c1da61ba%3BoriginPrice%3A2228%3BdisplayPrice%3A2228%3BsinglePromotionId%3A900000045954335%3BsingleToolCode%3ApromPrice%3BvoucherPricePlugin%3A0%3Btimestamp%3A1742827072928&ratingscore=4.83451536643026&request_id=22e7e63e5403e7959a22b342c1da61ba&review=423&sale=1475&search=1&source=search&spm=a2o4l.searchList.list.1&stock=1',
    },
    {
      'name': 'Pet Nail Scissors',
      'description': 'Keeps your pets nails trimmed and healthy',
      'category': 'Accessories',
      'image': 'assets/images/dog-accessories-1.jpg',
      'url':
          'https://www.lazada.com.ph/products/y-shape-dog-pet-nail-scissors-toe-claw-clippers-trimmers-cutter-tools-i2078900581-s9263466159.html?c=&channelLpJumpArgs=&clickTrackInfo=query%253Ascissors%252Bfor%252Bdogs%253Bnid%253A2078900581%253Bsrc%253ALazadaMainSrp%253Brn%253A4240df547722cafc59a7e61d0b50cdf2%253Bregion%253Aph%253Bsku%253A2078900581_PH%253Bprice%253A74.22%253Bclient%253Adesktop%253Bsupplier_id%253A500168715073%253Bbiz_source%253Ah5_internal%253Bslot%253A4%253Butlog_bucket_id%253A470687%253Basc_category_id%253A21934%253Bitem_id%253A2078900581%253Bsku_id%253A9263466159%253Bshop_id%253A1836466%253BtemplateInfo%253A107881_D_E%2523-1_A3_C%2523&freeshipping=1&fs_ab=2&fuse_fs=&lang=en&location=Laguna&price=74.22&priceCompare=skuId%3A9263466159%3Bsource%3Alazada-search-voucher%3Bsn%3A4240df547722cafc59a7e61d0b50cdf2%3BoriginPrice%3A7422%3BdisplayPrice%3A7422%3BsinglePromotionId%3A900000045954335%3BsingleToolCode%3ApromPrice%3BvoucherPricePlugin%3A0%3Btimestamp%3A1742827381117&ratingscore=4.97907949790795&request_id=4240df547722cafc59a7e61d0b50cdf2&review=239&sale=864&search=1&source=search&spm=a2o4l.searchList.list.4&stock=1',
    },
    {
      'name': 'Dr Shiba Happy Tummy Treats',
      'description':
          'Dr. Shiba Happy Tummy Treats help maintain gut health, making them a perfect daily snack for promoting overall well-being.',
      'category': 'Treats',
      'image': 'assets/images/dog-food-2.jpg',
      'url':
          'https://www.lazada.com.ph/products/deshiba-happy-tummy-treats-250g90g40g-i4444377628-s25172806463.html?c=&channelLpJumpArgs=&clickTrackInfo=query%253Adr%25252520shiba%253Bnid%253A4444377628%253Bsrc%253ALazadaMainSrp%253Brn%253Ad4286b14dadaa31f9b876d6d70e270e9%253Bregion%253Aph%253Bsku%253A4444377628_PH%253Bprice%253A179%253Bclient%253Adesktop%253Bsupplier_id%253A1000221705%253Bbiz_source%253Ah5_internal%253Bslot%253A3%253Butlog_bucket_id%253A470687%253Basc_category_id%253A21917%253Bitem_id%253A4444377628%253Bsku_id%253A25172806463%253Bshop_id%253A396304%253BtemplateInfo%253A107881_A3_C_D_E%2523&clusterType=nonSpu&freeshipping=1&fs_ab=2&fuse_fs=&lang=en&location=Cavite&price=179&priceCompare=skuId%3A25172806463%3Bsource%3Alazada-search-voucher%3Bsn%3Ad4286b14dadaa31f9b876d6d70e270e9%3BoriginPrice%3A17900%3BdisplayPrice%3A17900%3BsinglePromotionId%3A-1%3BsingleToolCode%3A-1%3BvoucherPricePlugin%3A0%3Btimestamp%3A1742827631526&ratingscore=4.942604856512141&request_id=d4286b14dadaa31f9b876d6d70e270e9&review=453&sale=1123&search=1&source=search&spm=a2o4l.searchList.list.3&stock=1',
    },
    {
      'name': 'Dog Toothbrush',
      'description':
          'Dental Hygiene Convenient Soft Toothbrush Clean Pet Teeth',
      'category': 'Health',
      'image': 'assets/images/dog-health-2.png',
      'url':
          'https://www.lazada.com.ph/products/pet-toothbrush-dog-toothbrush-dual-headed-dental-hygiene-convenient-soft-toothbrush-clean-pet-teeth-i4317101196-s24248579425.html?c=&channelLpJumpArgs=&clickTrackInfo=query%253Atoothbrushfor%25252520dogs%253Bnid%253A4317101196%253Bsrc%253ALazadaMainSrp%253Brn%253A091dee5181cf07f1df7c180996673580%253Bregion%253Aph%253Bsku%253A4317101196_PH%253Bprice%253A17.02%253Bclient%253Adesktop%253Bsupplier_id%253A500654352332%253Bbiz_source%253Ah5_internal%253Bslot%253A1%253Butlog_bucket_id%253A470687%253Basc_category_id%253A21933%253Bitem_id%253A4317101196%253Bsku_id%253A24248579425%253Bshop_id%253A4991675%253BtemplateInfo%253A107881_D_E%2523-1_A3_C%2523&freeshipping=1&fs_ab=2&fuse_fs=&lang=en&location=Bulacan&price=17.02&priceCompare=skuId%3A24248579425%3Bsource%3Alazada-search-voucher%3Bsn%3A091dee5181cf07f1df7c180996673580%3BoriginPrice%3A1702%3BdisplayPrice%3A1702%3BsinglePromotionId%3A900000045954335%3BsingleToolCode%3ApromPrice%3BvoucherPricePlugin%3A0%3Btimestamp%3A1742828112940&ratingscore=5.0&request_id=091dee5181cf07f1df7c180996673580&review=23&sale=162&search=1&source=search&spm=a2o4l.searchList.list.1&stock=1',
    },
    // Add more products...
  ];

  List<Map<String, dynamic>> get filteredProducts {
    return _products.where((product) {
      final matchesSearch =
          product['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
              product['description']
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategory.isEmpty || product['category'] == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.grey,
                ),
              ),
              accountName: Text('John Doe'),
              accountEmail: Text('johndoe@example.com'),
            ),
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('Events'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EventScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.pets),
              title: const Text('Dogs'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DogScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.volunteer_activism),
              title: const Text('Donate'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DonationScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Adopted'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdoptedDogsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.medical_services),
              title: const Text('Medical Services'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MedicalServicesScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_bag),
              title: const Text('Merch'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MerchScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About Us'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AboutScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                // TODO: Implement logout functionality
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      backgroundColor:
          const Color(0xFF32649B), // Background color for whole screen
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar Container
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Search TextField
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white, // Light background for search bar
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'Search items...',
                                border: InputBorder.none,
                                hintStyle: TextStyle(color: Colors.grey[600]),
                                contentPadding: const EdgeInsets.only(left: 16),
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Icon(Icons.search, color: Color(0xFF32649B)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () {
                      _scaffoldKey.currentState?.openEndDrawer();
                    },
                  ),
                ],
              ),
            ),
            // Rest of your content goes here
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedCategory = 'Treats';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF32649B),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      icon: const Icon(Icons.food_bank_outlined),
                      label: const Text('Treats'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedCategory = 'Toys';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF32649B),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      icon: const Icon(Icons.sports_baseball_sharp),
                      label: const Text('Toys'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedCategory = 'Health';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF32649B),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      icon: const Icon(Icons.health_and_safety),
                      label: const Text('Health'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedCategory = 'Accessories';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF32649B),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      icon: const Icon(Icons.handyman_outlined),
                      label: const Text('Accessories'),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pet Shop',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategory = ''; // Clear category filter
                        _searchQuery = ''; // Optional: clear search query too
                      });
                    },
                    child: const Text(
                      'See all',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 99, 175, 255),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Replace the existing Row with GridView
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 columns
                    childAspectRatio: 0.65, // Adjust for card height
                    crossAxisSpacing: 5, // Horizontal space between cards
                    mainAxisSpacing: 5, // Vertical space between cards
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: InkWell( // Add this
                        onTap: () => _showProductDetails(product),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(15),
                            ),
                            child: Image.asset(
                              product['image'],
                              width: double.infinity,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product['name'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  product['description'],
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                TextButton(
                                  onPressed: () => _launchURL(product['url']),
                                  child: const Text(
                                    'Shop Now →',
                                    style: TextStyle(
                                      color: Color(0xFF32649B),
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      )
                    ); 
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
