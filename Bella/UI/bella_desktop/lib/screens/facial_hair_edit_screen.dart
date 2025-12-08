import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:bella_desktop/layouts/master_screen.dart';
import 'package:bella_desktop/model/facial_hair.dart';
import 'package:bella_desktop/providers/facial_hair_provider.dart';
import 'package:bella_desktop/utils/base_textfield.dart';
import 'package:bella_desktop/utils/base_switch.dart';
import 'package:bella_desktop/utils/base_image_picker.dart';
import 'package:bella_desktop/screens/facial_hair_list_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

// Orange color scheme matching the app
const Color _orangePrimary = Color(0xFFFF8C42);
const Color _orangeDark = Color(0xFFFF6B1A);

class FacialHairEditScreen extends StatefulWidget {
  final FacialHair? facialHair;

  const FacialHairEditScreen({super.key, this.facialHair});

  @override
  State<FacialHairEditScreen> createState() => _FacialHairEditScreenState();
}

class _FacialHairEditScreenState extends State<FacialHairEditScreen> {
  final formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late FacialHairProvider facialHairProvider;
  bool isLoading = false;
  bool _isSaving = false;
  File? _image;

  @override
  void initState() {
    super.initState();
    facialHairProvider = Provider.of<FacialHairProvider>(context, listen: false);
    
    _initialValue = {
      "name": widget.facialHair?.name ?? '',
      "price": widget.facialHair?.price != null 
          ? widget.facialHair!.price.toStringAsFixed(2) 
          : '0.00',
      "image": widget.facialHair?.image,
      "isActive": widget.facialHair?.isActive ?? true,
    };
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
      title: widget.facialHair != null
          ? "Edit Facial Hair"
          : "Add Facial Hair",
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

                      // Handle image
                      if (_initialValue['image'] != null) {
                        request['image'] = _initialValue['image'];
                      }

                      // Include isActive
                      request['isActive'] = _initialValue['isActive'] ?? true;

                      try {
                        if (widget.facialHair == null) {
                          await facialHairProvider.insert(request);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Facial hair created successfully'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 1),
                            ),
                          );
                        } else {
                          await facialHairProvider.update(
                              widget.facialHair!.id, request);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Facial hair updated successfully'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 1),
                            ),
                          );
                        }
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const FacialHairListScreen(),
                            settings: const RouteSettings(name: 'FacialHairListScreen'),
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

  Widget _buildForm() {
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
                          Icons.face_rounded,
                          size: 24,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.facialHair != null
                            ? "Edit Facial Hair"
                            : "Add New Facial Hair",
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
                          label: "Facial Hair Image",
                          placeholderIcon: Icons.face,
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
                              // Facial Hair Name
                              FormBuilderTextField(
                                name: "name",
                                decoration: customTextFieldDecoration(
                                  "Facial Hair Name",
                                  prefixIcon: Icons.face_outlined,
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

                              // IsActive Switch
                              Row(
                                children: [
                                  const Text(
                                    'Active Facial Hair',
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

