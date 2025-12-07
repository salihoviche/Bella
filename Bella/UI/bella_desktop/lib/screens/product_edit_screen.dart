import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:bella_desktop/layouts/master_screen.dart';
import 'package:bella_desktop/model/product.dart';
import 'package:bella_desktop/model/category.dart';
import 'package:bella_desktop/model/manufacturer.dart';
import 'package:bella_desktop/providers/product_provider.dart';
import 'package:bella_desktop/providers/category_provider.dart';
import 'package:bella_desktop/providers/manufacturer_provider.dart';
import 'package:bella_desktop/utils/base_textfield.dart';
import 'package:bella_desktop/utils/base_switch.dart';
import 'package:bella_desktop/utils/base_image_picker.dart';
import 'package:bella_desktop/screens/product_list_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

// Orange color scheme matching the app
const Color _orangePrimary = Color(0xFFFF8C42);
const Color _orangeDark = Color(0xFFFF6B1A);

class ProductEditScreen extends StatefulWidget {
  final Product? product;

  const ProductEditScreen({super.key, this.product});

  @override
  State<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends State<ProductEditScreen> {
  final formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late ProductProvider productProvider;
  late CategoryProvider categoryProvider;
  late ManufacturerProvider manufacturerProvider;
  bool isLoading = true;
  bool _isSaving = false;
  File? _image;

  List<Category> _categories = [];
  List<Manufacturer> _manufacturers = [];
  bool _isLoadingCategories = true;
  bool _isLoadingManufacturers = true;
  Category? _selectedCategory;
  Manufacturer? _selectedManufacturer;

  @override
  void initState() {
    super.initState();
    productProvider = Provider.of<ProductProvider>(context, listen: false);
    categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    manufacturerProvider = Provider.of<ManufacturerProvider>(context, listen: false);
    
    _initialValue = {
      "name": widget.product?.name ?? '',
      "price": widget.product?.price != null 
          ? widget.product!.price.toStringAsFixed(2) 
          : '0.00',
      "picture": widget.product?.picture,
      "isActive": widget.product?.isActive ?? true,
      "categoryId": null,
      "manufacturerId": null,
    };
    initFormData();
  }

  initFormData() async {
    await _loadCategories();
    await _loadManufacturers();
    
    // Set selected category and manufacturer if editing
    if (widget.product != null && _categories.isNotEmpty && _manufacturers.isNotEmpty) {
      try {
        _selectedCategory = _categories.firstWhere(
          (cat) => cat.id == widget.product!.categoryId,
        );
        _initialValue['categoryId'] = _selectedCategory;
      } catch (e) {
        _selectedCategory = null;
        _initialValue['categoryId'] = null;
      }
      
      try {
        _selectedManufacturer = _manufacturers.firstWhere(
          (mfr) => mfr.id == widget.product!.manufacturerId,
        );
        _initialValue['manufacturerId'] = _selectedManufacturer;
      } catch (e) {
        _selectedManufacturer = null;
        _initialValue['manufacturerId'] = null;
      }
    }
    
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _loadCategories() async {
    try {
      final result = await categoryProvider.get(filter: {
        'isActive': true,
        'pageSize': 1000,
      });
      setState(() {
        _categories = result.items ?? [];
        _isLoadingCategories = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  Future<void> _loadManufacturers() async {
    try {
      final result = await manufacturerProvider.get(filter: {
        'isActive': true,
        'pageSize': 1000,
      });
      setState(() {
        _manufacturers = result.items ?? [];
        _isLoadingManufacturers = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingManufacturers = false;
      });
    }
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null && result.files.single.path != null) {
      _image = File(result.files.single.path!);
      _initialValue['picture'] = base64Encode(_image!.readAsBytesSync());
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: widget.product != null
          ? "Edit Product"
          : "Add Product",
      showBackButton: true,
      child: _buildForm(),
    );
  }

  Widget _buildSaveButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade300,
            foregroundColor: Colors.black87,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 16),
        Container(
          decoration: BoxDecoration(
            gradient: _isSaving
                ? null
                : const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _orangePrimary,
                      _orangeDark,
                    ],
                  ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: _isSaving
                ? null
                : [
                    BoxShadow(
                      color: _orangePrimary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: ElevatedButton(
            onPressed: _isSaving
                ? null
                : () async {
                    formKey.currentState?.saveAndValidate();
                    if (formKey.currentState?.validate() ?? false) {
                      setState(() => _isSaving = true);
                      var request = Map.from(formKey.currentState?.value ?? {});

                      // Convert price string to double
                      if (request['price'] != null && request['price'] is String) {
                        request['price'] = double.tryParse(request['price']) ?? 0.0;
                      }

                      // Get category and manufacturer from form values
                      final category = request['categoryId'] as Category?;
                      final manufacturer = request['manufacturerId'] as Manufacturer?;
                      
                      if (category != null) {
                        request['categoryId'] = category.id;
                      }
                      if (manufacturer != null) {
                        request['manufacturerId'] = manufacturer.id;
                      }

                      // Handle image
                      if (_initialValue['picture'] != null) {
                        request['picture'] = _initialValue['picture'];
                      }

                      // Include isActive
                      request['isActive'] = _initialValue['isActive'] ?? true;

                      try {
                        if (widget.product == null) {
                          await productProvider.insert(request);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Product created successfully'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 1),
                            ),
                          );
                        } else {
                          await productProvider.update(
                              widget.product!.id, request);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Product updated successfully'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 1),
                            ),
                          );
                        }
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const ProductListScreen(),
                            settings: const RouteSettings(name: 'ProductListScreen'),
                          ),
                        );
                      } catch (e) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Error'),
                            content: Text(
                              e.toString().replaceFirst('Exception: ', ''),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      } finally {
                        if (mounted) setState(() => _isSaving = false);
                      }
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: _isSaving ? Colors.grey[300] : Colors.transparent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    if (_isLoadingCategories) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 16),
            Text("Loading categories...", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_categories.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Text(
          "No categories available",
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return FormBuilderDropdown<Category>(
      name: "categoryId",
      decoration: customTextFieldDecoration(
        "Category",
        prefixIcon: Icons.category_outlined,
      ),
      initialValue: _selectedCategory,
      items: _categories.map((category) {
        return DropdownMenuItem<Category>(
          value: category,
          child: Text(category.name),
        );
      }).toList(),
      onChanged: (Category? value) {
        setState(() {
          _selectedCategory = value;
        });
      },
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(errorText: 'Please select a category'),
      ]),
    );
  }

  Widget _buildManufacturerDropdown() {
    if (_isLoadingManufacturers) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 16),
            Text("Loading manufacturers...", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_manufacturers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Text(
          "No manufacturers available",
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return FormBuilderDropdown<Manufacturer>(
      name: "manufacturerId",
      decoration: customTextFieldDecoration(
        "Manufacturer",
        prefixIcon: Icons.factory_outlined,
      ),
      initialValue: _selectedManufacturer,
      items: _manufacturers.map((manufacturer) {
        return DropdownMenuItem<Manufacturer>(
          value: manufacturer,
          child: Text(manufacturer.name),
        );
      }).toList(),
      onChanged: (Manufacturer? value) {
        setState(() {
          _selectedManufacturer = value;
        });
      },
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(errorText: 'Please select a manufacturer'),
      ]),
    );
  }

  Widget _buildForm() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Center(
      child: SingleChildScrollView(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with orange gradient
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _orangePrimary,
                        _orangeDark,
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.shopping_bag_rounded,
                          size: 24,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.product != null
                            ? "Edit Product"
                            : "Add New Product",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left column: image
                      SizedBox(
                        width: 300,
                        child: BaseImagePicker(
                          base64Image: _initialValue['picture'] as String?,
                          onSelectImage: _pickImage,
                          onClearImage: () {
                            setState(() {
                              _image = null;
                              _initialValue['picture'] = null;
                            });
                          },
                          imageSize: 250,
                          width: 250,
                          height: 250,
                          label: "Product Image",
                          placeholderIcon: Icons.shopping_bag,
                        ),
                      ),
                      const SizedBox(width: 32),
                      // Right column: form fields
                      Expanded(
                        child: FormBuilder(
                          key: formKey,
                          initialValue: _initialValue,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product Name
                              FormBuilderTextField(
                                name: "name",
                                decoration: customTextFieldDecoration(
                                  "Product Name",
                                  prefixIcon: Icons.shopping_bag_outlined,
                                ),
                                validator: FormBuilderValidators.compose([
                                  FormBuilderValidators.required(),
                                  FormBuilderValidators.maxLength(200),
                                ]),
                              ),
                              const SizedBox(height: 24),

                              // Price
                              FormBuilderTextField(
                                name: "price",
                                decoration: customTextFieldDecoration(
                                  "Price",
                                  prefixIcon: Icons.attach_money,
                                ),
                                keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                validator: FormBuilderValidators.compose([
                                  FormBuilderValidators.required(),
                                  FormBuilderValidators.numeric(),
                                  (value) {
                                    if (value != null && value.isNotEmpty) {
                                      final price = double.tryParse(value);
                                      if (price == null) {
                                        return 'Please enter a valid number';
                                      }
                                      if (price <= 0) {
                                        return 'Price must be greater than 0';
                                      }
                                    }
                                    return null;
                                  },
                                ]),
                              ),
                              const SizedBox(height: 24),

                              // Category Dropdown
                              _buildCategoryDropdown(),
                              const SizedBox(height: 24),

                              // Manufacturer Dropdown
                              _buildManufacturerDropdown(),
                              const SizedBox(height: 24),

                              // IsActive Switch
                              Row(
                                children: [
                                  const Text(
                                    'Active Product',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  BaseSwitch(
                                    value: _initialValue['isActive'] as bool? ?? true,
                                    onChanged: (bool newValue) {
                                      setState(() {
                                        _initialValue['isActive'] = newValue;
                                        formKey.currentState?.fields['isActive']?.didChange(newValue);
                                      });
                                    },
                                    width: 50,
                                    height: 28,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Save and Cancel Buttons
                              _buildSaveButton(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
