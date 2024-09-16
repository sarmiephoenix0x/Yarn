import 'package:flutter/material.dart';

class MainApp extends StatefulWidget {
  const MainApp({
    super.key,
  });

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 0;
  final TextEditingController searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final List<bool> _hasNotification = [
    false,
    false,
    false,
    false
  ]; // Example notification state

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // Scrollable views for each bottom nav item
          ListView(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Spacer(),
                        InkWell(
                          onTap: () {},
                          child: Image.asset(
                            'images/NotificationIcon.png',
                            height: 50,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextFormField(
                      controller: searchController,
                      focusNode: _searchFocusNode,
                      style: const TextStyle(
                        fontSize: 16.0,
                      ),
                      decoration: InputDecoration(
                          labelText: 'Search',
                          labelStyle: const TextStyle(
                            color: Colors.grey,
                            fontFamily: 'Poppins',
                            fontSize: 12.0,
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: Colors.black,
                            ),
                          ),
                          prefixIcon: IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () {},
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.filter_list_alt),
                            onPressed: () {},
                          )),
                      cursorColor: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
          ListView.builder(
            itemCount: 20,
            itemBuilder: (context, index) =>
                ListTile(title: Text("Item ${index + 1}")),
          ),
          ListView.builder(
            itemCount: 20,
            itemBuilder: (context, index) =>
                ListTile(title: Text("Item ${index + 1}")),
          ),
          ListView.builder(
            itemCount: 20,
            itemBuilder: (context, index) =>
                ListTile(title: Text("Item ${index + 1}")),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const ImageIcon(
              AssetImage('images/Home.png'),
              color: Colors.grey,
            ),
            label: '',
            // Add notification dot
            activeIcon: Stack(
              alignment: Alignment.center,
              children: [
                const ImageIcon(AssetImage('images/Home-Active.png')),
                if (_hasNotification[0])
                  Positioned(
                    bottom: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      width: 8,
                      height: 8,
                    ),
                  ),
              ],
            ),
          ),
          BottomNavigationBarItem(
            icon: const ImageIcon(
              AssetImage('images/Explore.png'),
              color: Colors.grey,
            ),
            label: '',
            activeIcon: Stack(
              alignment: Alignment.center,
              children: [
                const ImageIcon(AssetImage('images/Explore.png')),
                if (_hasNotification[1])
                  Positioned(
                    bottom: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      width: 8,
                      height: 8,
                    ),
                  ),
              ],
            ),
          ),
          BottomNavigationBarItem(
            icon: const ImageIcon(
              AssetImage('images/Like.png'),
              color: Colors.grey,
            ),
            label: '',
            activeIcon: Stack(
              alignment: Alignment.center,
              children: [
                const ImageIcon(AssetImage('images/Like.png')),
                if (_hasNotification[2])
                  Positioned(
                    bottom: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      width: 8,
                      height: 8,
                    ),
                  ),
              ],
            ),
          ),
          BottomNavigationBarItem(
            icon: const ImageIcon(
              AssetImage('images/Account.png'),
              color: Colors.grey,
            ),
            label: '',
            activeIcon: Stack(
              alignment: Alignment.center,
              children: [
                const ImageIcon(AssetImage('images/Account-active.png')),
                if (_hasNotification[3])
                  Positioned(
                    bottom: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      width: 8,
                      height: 8,
                    ),
                  ),
              ],
            ),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue, // Customize the selected item color
        onTap: _onItemTapped,
      ),
    );
  }
}
