import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:bella_desktop/layouts/master_screen.dart';
import 'package:bella_desktop/model/hairstyle.dart';
import 'package:bella_desktop/model/length.dart';
import 'package:bella_desktop/model/gender.dart';
import 'package:bella_desktop/providers/hairstyle_provider.dart';
import 'package:bella_desktop/providers/length_provider.dart';
import 'package:bella_desktop/providers/gender_provider.dart';
import 'package:bella_desktop/utils/base_textfield.dart';
import 'package:bella_desktop/utils/base_switch.dart';
import 'package:bella_desktop/utils/base_image_picker.dart';
import 'package:bella_desktop/screens/hairstyle_list_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

// Orange color scheme matching the app
const Color _orangePrimary = Color(0xFFFF8C42);
const Color _orangeDark = Color(0xFFFF6B1A);

class HairstyleEditScreen extends StatefulWidget {
  final Hairstyle? hairstyle;

  const HairstyleEditScreen({super.key, this.hairstyle});

  @override
  State<HairstyleEditScreen> createState() => _HairstyleEditScreenState();
}

class _HairstyleEditScreenState extends State<HairstyleEditScreen> {
  final formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late HairstyleProvider hairstyleProvider;
  late LengthProvider lengthProvider;
  late GenderProvider genderProvider;
  bool isLoading = true;
  bool _isSaving = false;
  File? _image;

  List<Length> _lengths = [];
  List<Gender> _genders = [];
  bool _isLoadingLengths = true;
  bool _isLoadingGenders = true;
  Length? _selectedLength;
  Gender? _selectedGender;

  @override
  void initState() {
    super.initState();
    hairstyleProvider = Provider.of<HairstyleProvider>(context, listen: false);
    lengthProvider = Provider.of<LengthProvider>(context, listen: false);
    genderProvider = Provider.of<GenderProvider>(context, listen: false);
    
    _initialValue = {
      "name": widget.hairstyle?.name ?? '',
      "price": widget.hairstyle?.price != null 
          ? widget.hairstyle!.price.toStringAsFixed(2) 
          : '0.00',
      "image": widget.hairstyle?.image,
      "isActive": widget.hairstyle?.isActive ?? true,
      "lengthId": null,
      "genderId": null,
    };
    initFormData();
  }

  initFormData() async {
    await _loadLengths();
    await _loadGenders();
    
    // Set selected length and gender if editing
    if (widget.hairstyle != null && _lengths.isNotEmpty && _genders.isNotEmpty) {
      try {
        _selectedLength = _lengths.firstWhere(
          (len) => len.id == widget.hairstyle!.lengthId,
        );
        _initialValue['lengthId'] = _selectedLength;
      } catch (e) {
        _selectedLength = null;
        _initialValue['lengthId'] = null;
      }
      
      try {
        _selectedGender = _genders.firstWhere(
          (gen) => gen.id == widget.hairstyle!.genderId,
        );
        _initialValue['genderId'] = _selectedGender;
      } catch (e) {
        _selectedGender = null;
        _initialValue['genderId'] = null;
      }
    }
    
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _loadLengths() async {
    try {
      final result = await lengthProvider.get(filter: {
        'pageSize': 1000,
      });
      setState(() {
        _lengths = result.items ?? [];
        _isLoadingLengths = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingLengths = false;
      });
    }
  }

  Future<void> _loadGenders() async {
    try {
      final result = await genderProvider.get(filter: {
        'isActive': true,
        'pageSize': 1000,
      });
      setState(() {
        _genders = result.items ?? [];
        _isLoadingGenders = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingGenders = false;
      });
    }
  }

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null && result.files.single.path != null) {
      _image = File(result.files.single.path!);
      _initialValue['image'] = base64Encode(_image!.readAsBytesSync());
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: widget.hairstyle != null
          ? "Edit Hairstyle"
          : "Add Hairstyle",
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

                      // Get length and gender from form values
                      final length = request['lengthId'] as Length?;
                      final gender = request['genderId'] as Gender?;
                      
                      if (length != null) {
                        request['lengthId'] = length.id;
                      }
                      if (gender != null) {
                        request['genderId'] = gender.id;
                      }

                      // Handle image
                      if (_initialValue['image'] != null) {
                        request['image'] = _initialValue['image'];
                      }

                      // Include isActive
                      request['isActive'] = _initialValue['isActive'] ?? true;

                      try {
                        if (widget.hairstyle == null) {
                          await hairstyleProvider.insert(request);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Hairstyle created successfully'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 1),
                            ),
                          );
                        } else {
                          await hairstyleProvider.update(
                              widget.hairstyle!.id, request);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Hairstyle updated successfully'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 1),
                            ),
                          );
                        }
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const HairstyleListScreen(),
                            settings: const RouteSettings(name: 'HairstyleListScreen'),
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

  Widget _buildLengthDropdown() {
    if (_isLoadingLengths) {
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
            Text("Loading lengths...", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_lengths.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Text(
          "No lengths available",
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return FormBuilderDropdown<Length>(
      name: "lengthId",
      decoration: customTextFieldDecoration(
        "Length",
        prefixIcon: Icons.straighten_outlined,
      ),
      initialValue: _selectedLength,
      items: _lengths.map((length) {
        return DropdownMenuItem<Length>(
          value: length,
          child: Text(length.name),
        );
      }).toList(),
      onChanged: (Length? value) {
        setState(() {
          _selectedLength = value;
        });
      },
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(errorText: 'Please select a length'),
      ]),
    );
  }

  Widget _buildGenderDropdown() {
    if (_isLoadingGenders) {
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
            Text("Loading genders...", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_genders.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Text(
          "No genders available",
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return FormBuilderDropdown<Gender>(
      name: "genderId",
      decoration: customTextFieldDecoration(
        "Gender",
        prefixIcon: Icons.person_outline,
      ),
      initialValue: _selectedGender,
      items: _genders.map((gender) {
        return DropdownMenuItem<Gender>(
          value: gender,
          child: Text(gender.name),
        );
      }).toList(),
      onChanged: (Gender? value) {
        setState(() {
          _selectedGender = value;
        });
      },
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(errorText: 'Please select a gender'),
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
                          Icons.content_cut_rounded,
                          size: 24,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.hairstyle != null
                            ? "Edit Hairstyle"
                            : "Add New Hairstyle",
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
                          base64Image: _initialValue['image'] as String?,
                          onSelectImage: _pickImage,
                          onClearImage: () {
                            setState(() {
                              _image = null;
                              _initialValue['image'] = null;
                            });
                          },
                          imageSize: 250,
                          width: 250,
                          height: 250,
                          label: "Hairstyle Image",
                          placeholderIcon: Icons.content_cut,
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
                              // Hairstyle Name
                              FormBuilderTextField(
                                name: "name",
                                decoration: customTextFieldDecoration(
                                  "Hairstyle Name",
                                  prefixIcon: Icons.content_cut_outlined,
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

                              // Length Dropdown
                              _buildLengthDropdown(),
                              const SizedBox(height: 24),

                              // Gender Dropdown
                              _buildGenderDropdown(),
                              const SizedBox(height: 24),

                              // IsActive Switch
                              Row(
                                children: [
                                  const Text(
                                    'Active Hairstyle',
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

