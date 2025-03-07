import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'profile_page.dart';

import '../utils/database.dart';
import '../utils/app_state.dart';
import '../utils/notification_services.dart';

import '../widgets/product_card.dart';
import '../widgets/filter_modal_sheet.dart';
import '../widgets/confirmation_dialog.dart';
import '../widgets/edit_product_info_dialog.dart';

import '../data_classes/product_info.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  static const String productsName = 'products';

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  late final AppLifecycleListener _appLifecycleListener;

  final MenuController _menuController = MenuController();

  int selectedSortOption = 0;

  bool _isSelecting = false;
  final Set<String> _selectedItems = {};

  Set<String> _selectedCategories = {};
  Set<int> _selectedExpiryDates = {};
  Set<int> _selectedQuantities = {};

  @override
  void initState() {
    super.initState();
    NotificationServices.flutterLocalNotificationsPlugin.cancelAll();
    _appLifecycleListener = AppLifecycleListener(
      onResume: () {
        NotificationServices.flutterLocalNotificationsPlugin.cancelAll();
      },
    );
  }

  @override
  void dispose() {
    _appLifecycleListener.dispose();
    super.dispose();
  }

  Widget _buildCustomMenuItem(IconData icon, String text, int value, bool isDarkMode) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedSortOption = value;
          _menuController.close();
        });
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: selectedSortOption == value ? Border.all(color: Colors.blue.shade700, width: 1.5) : null,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            children: [
              Icon(icon, color: selectedSortOption == value ? Colors.blue.shade700 : isDarkMode ? Colors.white : Colors.black, size: 24),
              const SizedBox(width: 10),
              Text(
                text,
                style: TextStyle(
                  color: selectedSortOption == value ? Colors.blue.shade700 : isDarkMode ? Colors.white : Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    bool isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Consumer<ApplicationState>(
        builder: (context, appState, _) {
          List<ProductInfo> filteredProducts = appState.isConnectedToPantry ? appState.productInfo : [];

          if (_searchQuery.isNotEmpty) {
            filteredProducts = appState.productInfo.where((product) => product.name.toLowerCase().contains(_searchQuery)).toList();
          }

          if (_selectedExpiryDates.isNotEmpty) {
            if (_selectedExpiryDates.length == 1) {
              if (_selectedExpiryDates.contains(0)) {
                filteredProducts = filteredProducts.where((product) => product.isExpired).toList();
              } else if (_selectedExpiryDates.contains(1)) {
                filteredProducts = filteredProducts.where((product) {
                  final isAfter = product.expiryDate!.isAfter(
                    DateFormat('dd/MM/yyyy').parse(
                      DateFormat('dd/MM/yyyy').format(DateTime.now().add(Duration(days: 3)))
                    )
                  );

                  return !product.isExpired && !isAfter;
                }).toList();
              } else if (_selectedExpiryDates.contains(2)) {
                filteredProducts = filteredProducts.where((product) {
                  final isAfter = product.expiryDate!.isAfter(
                    DateFormat('dd/MM/yyyy').parse(
                      DateFormat('dd/MM/yyyy').format(DateTime.now().add(Duration(days: 3)))
                    )
                  );

                  return !product.isExpired && isAfter;
                }).toList();
              }
            } else if (_selectedExpiryDates.length == 2) {
              if (_selectedExpiryDates.contains(0) && _selectedExpiryDates.contains(1)) {
                filteredProducts = filteredProducts.where((product) {
                  final isAfter = product.expiryDate!.isAfter(
                    DateFormat('dd/MM/yyyy').parse(
                      DateFormat('dd/MM/yyyy').format(DateTime.now().add(Duration(days: 3)))
                    )
                  );

                  return product.isExpired || !isAfter;
                }).toList();
              } else if (_selectedExpiryDates.contains(0) && _selectedExpiryDates.contains(2)) {
                filteredProducts = filteredProducts.where((product) {
                  final isAfter = product.expiryDate!.isAfter(
                    DateFormat('dd/MM/yyyy').parse(
                      DateFormat('dd/MM/yyyy').format(DateTime.now().add(Duration(days: 3)))
                    )
                  );

                  return product.isExpired || isAfter;
                }).toList();
              } else if (_selectedExpiryDates.contains(1) && _selectedExpiryDates.contains(2)) {
                filteredProducts = filteredProducts.where((product) => !product.isExpired).toList();
              }
            }
          }

          if (_selectedCategories.isNotEmpty) {
            filteredProducts = filteredProducts.where((product) => product.categories.any((category) => _selectedCategories.contains(category))).toList();
          }

          if (_selectedQuantities.isNotEmpty) {
            if (_selectedQuantities.length == 1) {
              if (_selectedQuantities.contains(0)) {
                filteredProducts = filteredProducts.where((product) => product.quantity <= 3).toList();
              } else if (_selectedQuantities.contains(1)) {
                filteredProducts = filteredProducts.where((product) => product.quantity > 3).toList();
              }
            }
          }

          switch (selectedSortOption) {
            case 0:
              filteredProducts.sort((a, b) {
                if (a.expiryDate == null && b.expiryDate == null) {
                  return 0;
                } else if (a.expiryDate == null) {
                  return -1;
                } else if (b.expiryDate == null) {
                  return 1;
                } else {
                  return a.expiryDate!.isBefore(b.expiryDate!) ? -1 : 1;
                }
              });
              break;
            case 1:
              filteredProducts.sort((a, b) {
                if (a.expiryDate == null && b.expiryDate == null) {
                  return 0;
                } else if (a.expiryDate == null) {
                  return 1;
                } else if (b.expiryDate == null) {
                  return -1;
                } else {
                  return a.expiryDate!.isBefore(b.expiryDate!) ? 1 : -1;
                }
              });
              break;
            case 2:
              filteredProducts.sort((a, b) => a.name.compareTo(b.name));
              break;
            case 3:
              filteredProducts.sort((a, b) => b.name.compareTo(a.name));
              break;
            case 4:
              filteredProducts.sort((a, b) => a.quantity.compareTo(b.quantity));
              break;
            case 5:
              filteredProducts.sort((a, b) => b.quantity.compareTo(a.quantity));
              break;
          }
          return Column(
            children: [
              Stack(
                children: [
                  if (filteredProducts.isNotEmpty)
                    Material(
                      elevation: 3,
                      borderRadius: BorderRadius.circular(16.0),
                      child: Container(
                        width: double.infinity,
                        height: 115,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        alignment: Alignment.bottomCenter,
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Swipe left on any product to delete it',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                    ),
                  AppBar(
                    title: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: _isSelecting ? Text('${_selectedItems.length} products selected') : AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        transitionBuilder: (child, animation) {
                          return SizeTransition(
                            sizeFactor: animation,
                            axisAlignment: -1.0,
                            child: child
                          );
                        },
                        child: _isSearching
                          ? TextField(
                              key: ValueKey('searchField'),
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                              },
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search products...',
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                filled: false,
                              ),
                              autofocus: true,
                            )
                          : Text(
                              'Products',
                              key: ValueKey('title'),
                            ),
                      ),
                    ),
                    leading: Visibility(
                      visible: appState.isConnectedToPantry && appState.productInfo.isNotEmpty,
                      child: IconButton(
                        tooltip: _isSelecting ? 'Cancel selection' : _isSearching ? 'Cancel' : 'Search products',
                        icon: Icon(
                          _isSelecting 
                            ? Icons.close_rounded
                            : _isSearching
                              ? Icons.close_rounded
                              : Icons.search_rounded,
                          size: 27,
                        ),
                        onPressed: _isSelecting ? () {
                          setState(() {
                            _selectedItems.clear();
                            _isSelecting = false;
                          });
                        } : () {
                          setState(() {
                            _isSearching = !_isSearching;
                            if (!_isSearching) {
                              _searchController.clear();
                              _searchQuery = '';
                            }
                          });
                        },
                      ),
                    ),
                    actions: [
                      Visibility(
                        visible: appState.isConnectedToPantry && appState.productInfo.isNotEmpty && !_isSelecting,
                        child: Row(
                          children: [
                            IconButton(
                              tooltip: 'Filter products',
                              icon: Icon(
                                Icons.tune_rounded,
                                size: 27,
                              ),
                              onPressed: () async {
                                _searchFocusNode.unfocus();
                                final result = await showModalBottomSheet(
                                  context: context,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                  ),
                                  builder: (context) => FilterModalSheet(
                                    selectedCategories: _selectedCategories,
                                    selectedExpiryDates: _selectedExpiryDates,
                                    selectedQuantities: _selectedQuantities,
                                  ),
                                );

                                if(result[0] == true) {
                                  setState(() {
                                    _selectedExpiryDates = {...result[1]};
                                    _selectedCategories = {...result[2]};
                                    _selectedQuantities = {...result[3]};
                                  });
                                } else if (result[0] == false) {
                                  setState(() {
                                    _selectedExpiryDates.clear();
                                    _selectedCategories.clear();
                                    _selectedQuantities.clear();
                                  });
                                }
                              },
                            ),
                            MenuAnchor(
                              controller: _menuController,
                              alignmentOffset: const Offset(-50, 0),
                              builder: (context, controller, child) {
                                return IconButton(
                                  tooltip: 'Sort Products',
                                  icon: Icon(
                                    Icons.swap_vert_rounded,
                                    size: 27,
                                  ),
                                  onPressed: () {
                                    _searchFocusNode.unfocus();
                                    _menuController.isOpen ? _menuController.close() : _menuController.open();
                                  },
                                );
                              },
                              menuChildren: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildCustomMenuItem(Icons.arrow_upward_rounded, 'Expiry Date', 0, isDarkMode),
                                    _buildCustomMenuItem(Icons.arrow_downward_rounded, 'Expiry Date', 1, isDarkMode),
                                    PopupMenuDivider(height: 5),
                                    _buildCustomMenuItem(Icons.arrow_upward_rounded, 'Name', 2, isDarkMode),
                                    _buildCustomMenuItem(Icons.arrow_downward_rounded, 'Name', 3, isDarkMode),
                                    PopupMenuDivider(height: 5),
                                    _buildCustomMenuItem(Icons.arrow_upward_rounded, 'Quantity', 4, isDarkMode),
                                    _buildCustomMenuItem(Icons.arrow_downward_rounded, 'Quantity', 5, isDarkMode),
                                  ],
                                ),
                              ]
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: IconButton(
                          tooltip: 'Profile',
                          icon: Icon(
                            _isSelecting
                              ? Icons.delete_outline_rounded
                              : Icons.person_rounded,
                            size: 27,
                            color: _isSelecting ? Colors.red.shade800 : null,
                          ),
                          onPressed: _isSelecting ? () async {
                            final confirmation = await showDialog(
                              context: context,
                              builder: (context) => ConfirmationDialog(text: 'Are you sure you want to delete these ${_selectedItems.length} products?')
                            );

                            if (confirmation) {
                              var messages = [];
                              for (var docId in _selectedItems) {
                                final message = await Database.deleteProduct(docId: docId);
                                messages.add(message);
                              }
                              if (messages.every((message) => message.contains('Success'))) {
                                Fluttertoast.showToast(
                                  msg: 'Selected products deleted successfully',
                                  toastLength: Toast.LENGTH_SHORT,
                                );
                              }
                              setState(() {
                                _selectedItems.clear();
                                _isSelecting = false;
                              });
                            }
                          } : () {
                            if (!_isSearching) {
                              context.pushNamed(ProfilePage.profileName);
                            } else {
                              setState(() {
                                _isSearching = !_isSearching;
                                _searchQuery = '';
                              });
                              Future.delayed(Duration(milliseconds: 600));
                              context.pushNamed(ProfilePage.profileName);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Expanded(
                  child: filteredProducts.isNotEmpty 
                  ? ListView.builder(
                      padding: EdgeInsets.only(top: 0.0),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final productInfo = filteredProducts[index];
                        final isSelected = _selectedItems.contains(productInfo.docId);

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                          child: Dismissible(
                            key: Key(productInfo.docId),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                              ),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20.0),
                              child: Icon(Icons.delete_forever_rounded, color: Colors.red.shade900),
                            ),
                            confirmDismiss: (_) async {
                              return await showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (context) => ConfirmationDialog(text: 'Are you sure you want to delete ${productInfo.name}?'),
                              );
                            },
                            onDismissed: (_) async {
                              final message = await Database.deleteProduct(docId: productInfo.docId);
                              if (message.contains('Success')) {
                                Fluttertoast.showToast(
                                  msg: 'Product deleted successfully',
                                  toastLength: Toast.LENGTH_SHORT,
                                );
                              }
                            },
                            child: GestureDetector(
                              onLongPress: _isSelecting ? null : () {
                                setState(() {
                                  _isSelecting = true;
                                  _selectedItems.add(productInfo.docId);
                                });
                              },
                              onTap: _isSelecting ? () {
                                setState(() {
                                  if (_selectedItems.contains(productInfo.docId)) {
                                    _selectedItems.remove(productInfo.docId);
                                    if (_selectedItems.isEmpty) {
                                      _isSelecting = false;
                                    }
                                  } else {
                                    _selectedItems.add(productInfo.docId);
                                  }
                                });
                              } : () {
                                showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (context) => EditProductInfoDialog(productInfo: productInfo),
                                );
                              },
                              child: ProductCard(productInfo: productInfo, isSelected: isSelected)
                            ),
                          ),
                        );
                      }
                    )
                  : Center(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                        child: Text(!appState.isConnectedToPantry 
                          ? 'You are not connected to your pantry.\nGo to the profile page and connect in order to see your products'
                          : _isSearching || _selectedCategories.isNotEmpty || _selectedExpiryDates.isNotEmpty || _selectedQuantities.isNotEmpty
                            ? 'No products match your search criteria'
                            : 'You have no products in your pantry',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue.shade700,
                          ),
                          softWrap: true,
                          textAlign: TextAlign.center,
                        ),
                      )
                    )
                ),
            ],
          );
        }
      ),
    );
  }
}