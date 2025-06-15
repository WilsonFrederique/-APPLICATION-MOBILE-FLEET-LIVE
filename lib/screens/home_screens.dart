import 'package:fleetlive/containers/position_frm_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fleetlive/containers/historique_container.dart';
import 'package:fleetlive/containers/position_container.dart';
import 'package:fleetlive/containers/vehicule_container.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTabIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<String> _menuItems = const ["Véhicules", "Positions", "Historique"];

  void _onTabSelected(int index) {
    setState(() {
      _currentTabIndex = index;
    });
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _showMoreMenu(BuildContext context) async {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(button.size.topRight(Offset.zero), ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    final result = await showMenu<String>(
      context: context,
      position: position,
      items: [
        const PopupMenuItem<String>(
          value: 'settings',
          child: ListTile(
            leading: Icon(Icons.settings, color: Color(0xFF023661)),
            title: Text('Paramètres'),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'help',
          child: ListTile(
            leading: Icon(Icons.help, color: Color(0xFF023661)),
            title: Text('Aide'),
          ),
        ),
        // const PopupMenuItem<String>(
        //   value: 'logout',
        //   child: ListTile(
        //     leading: Icon(Icons.logout, color: Color(0xFF023661)),
        //     title: Text('Déconnexion'),
        //   ),
        // ),
      ],
    );

    if (result != null) {
      _handleMenuSelection(result);
    }
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'settings':
        // Naviguer vers les paramètres
        break;
      case 'help':
        // Naviguer vers l'aide
        break;
      case 'logout':
        // Gérer la déconnexion
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(),
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          MenuSection(
            menuItems: _menuItems,
            selectedIndex: _currentTabIndex,
            onItemSelected: _onTabSelected,
          ),
          Expanded(
            child: _buildContentForTab(_currentTabIndex),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF023661),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'FLEET LIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Application mobile de géolocalisation instantanée',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Menu principal',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          ...List.generate(_menuItems.length, (index) => ListTile(
            leading: Icon(
              _getIconForIndex(index),
              color: const Color(0xFF023661),
            ),
            title: Text(_menuItems[index]),
            selected: _currentTabIndex == index,
            selectedTileColor: Colors.blue.withOpacity(0.1),
            onTap: () {
              Navigator.pop(context);
              _onTabSelected(index);
            },
          )),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings, color: Color(0xFF023661)),
            title: const Text('Paramètres'),
            onTap: () {
              Navigator.pop(context);
              // Ajouter la navigation vers les paramètres
            },
          ),
          ListTile(
            leading: const Icon(Icons.help, color: Color(0xFF023661)),
            title: const Text('Aide'),
            onTap: () {
              Navigator.pop(context);
              // Ajouter la navigation vers l'aide
            },
          ),
        ],
      ),
    );
  }

  IconData _getIconForIndex(int index) {
    switch(index) {
      case 0: return Icons.dashboard;
      case 1: return Icons.location_on;
      case 2: return Icons.history;
      default: return Icons.error;
    }
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        onPressed: _openDrawer,
        icon: const Icon(
          Icons.menu,
          color: Colors.white,
          size: 30,
        ),
      ),
      title: const Text('FLEET LIVE'),
      actions: [
        IconButton(
          onPressed: () => _showMoreMenu(context),
          icon: const Icon(Icons.more_vert),
        )
      ],
    );
  }

  Widget _buildContentForTab(int index) {
    switch (index) {
      case 0:
        return const VehiculeContainer();
      case 1:
        return const PositionContainer();
      case 2:
        return const HistoriqueContainer();
      default:
        return Container(color: Colors.grey);
    }
  }

  Widget _buildFloatingActionButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PositionFormContainer()),
          );
        },
        backgroundColor: Colors.blue,
        elevation: 6.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        child: Image.asset(
          'assets/images/logo5.png',
          width: 53,
          height: 53,
        ),
      ),
    );
  }
}

class MenuSection extends StatelessWidget {
  final List<String> menuItems;
  final int selectedIndex;
  final Function(int) onItemSelected;

  const MenuSection({
    super.key,
    required this.menuItems,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _buildBoxDecoration(),
      height: 70,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: List.generate(
              menuItems.length,
              (index) => _buildMenuItem(index, menuItems[index]),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildBoxDecoration() {
    return BoxDecoration(
      color: const Color(0xFF023661),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildMenuItem(int index, String item) {
    final isSelected = selectedIndex == index;
    
    return GestureDetector(
      onTap: () => onItemSelected(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        // decoration: isSelected
        //     ? const BoxDecoration(
        //         border: Border(
        //           bottom: BorderSide(
        //             color: Colors.white,
        //             width: 3.0,
        //           ),
        //         ),
        //       )
        //     : null,
        child: Text(
          item,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : const Color.fromARGB(192, 255, 255, 255),
            fontSize: 17,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}