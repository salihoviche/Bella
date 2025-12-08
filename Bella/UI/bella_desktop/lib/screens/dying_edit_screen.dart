import 'package:flutter/material.dart';
import 'package:bella_desktop/layouts/master_screen.dart';
import 'package:bella_desktop/model/dying.dart';
import 'package:bella_desktop/providers/dying_provider.dart';
import 'package:bella_desktop/utils/base_textfield.dart';
import 'package:bella_desktop/utils/base_switch.dart';
import 'package:bella_desktop/utils/base_color_picker.dart';
import 'package:bella_desktop/screens/dying_list_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

// Orange color scheme matching the app
const Color _orangePrimary = Color(0xFFFF8C42);
const Color _orangeDark = Color(0xFFFF6B1A);

class DyingEditScreen extends StatefulWidget {
  final Dying? dying;

  const DyingEditScreen({super.key, this.dying});

  @override
  State<DyingEditScreen> createState() => _DyingEditScreenState();
}

class _DyingEditScreenState extends State<DyingEditScreen> {
  final formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late DyingProvider dyingProvider;
  bool _isSaving = false;
  Color? _selectedColor;

  @override
  void initState() {
    super.initState();
    dyingProvider = Provider.of<DyingProvider>(context, listen: false);
    
    final hexCode = widget.dying?.hexCode;
    _selectedColor = _parseHexColor(hexCode);
    
    _initialValue = {
      "name": widget.dying?.name ?? '',
      "hexCode": hexCode ?? '',
      "isActive": widget.dying?.isActive ?? true,
    };
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  void _onColorChanged(Color color) {
    setState(() {
      _selectedColor = color;
      final hexCode = _colorToHex(color);
      _initialValue['hexCode'] = hexCode;
      formKey.currentState?.fields['hexCode']?.didChange(hexCode);
    });
  }

  Color? _parseHexColor(String? hexCode) {
    if (hexCode == null || hexCode.isEmpty) return null;
    try {
      // Remove # if present
      String hex = hexCode.replaceAll('#', '');
      // Handle both 3 and 6 digit hex codes
      if (hex.length == 3) {
        hex = hex.split('').map((char) => char + char).join();
      }
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: widget.dying != null
          ? "Edit Dye Color"
          : "Add Dye Color",
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

                      // Handle hexCode - ensure it starts with # if provided
                      if (request['hexCode'] != null && request['hexCode'].toString().isNotEmpty) {
                        String hexCode = request['hexCode'].toString().trim();
                        if (!hexCode.startsWith('#')) {
                          hexCode = '#$hexCode';
                        }
                        request['hexCode'] = hexCode;
                      } else {
                        request['hexCode'] = null;
                      }

                      // Include isActive
                      request['isActive'] = _initialValue['isActive'] ?? true;

                      try {
                        if (widget.dying == null) {
                          await dyingProvider.insert(request);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Dye color created successfully'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 1),
                            ),
                          );
                        } else {
                          await dyingProvider.update(
                              widget.dying!.id, request);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Dye color updated successfully'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 1),
                            ),
                          );
                        }
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const DyingListScreen(),
                            settings: const RouteSettings(name: 'DyingListScreen'),
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
                          Icons.palette_rounded,
                          size: 24,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.dying != null
                            ? "Edit Dye Color"
                            : "Add New Dye Color",
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
                      // Left column: color preview
                      SizedBox(
                        width: 300,
                        child: Column(
                          children: [
                            Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                color: _selectedColor ?? Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.3),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: _selectedColor == null
                                  ? Icon(
                                      Icons.palette_outlined,
                                      size: 64,
                                      color: Colors.grey[600],
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Color Preview',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
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
                              // Dye Color Name
                              FormBuilderTextField(
                                name: "name",
                                decoration: customTextFieldDecoration(
                                  "Dye Color Name",
                                  prefixIcon: Icons.palette_outlined,
                                ),
                                validator: FormBuilderValidators.compose([
                                  FormBuilderValidators.required(),
                                  FormBuilderValidators.maxLength(100),
                                ]),
                                onChanged: (value) {
                                  setState(() {
                                    _initialValue['name'] = value;
                                  });
                                },
                              ),
                              const SizedBox(height: 24),

                              // Color Picker
                              BaseColorPicker(
                                selectedColor: _selectedColor,
                                onColorChanged: _onColorChanged,
                                label: 'Color',
                                prefixIcon: Icons.color_lens_outlined,
                              ),
                              const SizedBox(height: 8),
                              // Hex Code field (read-only or editable as backup)
                              FormBuilderTextField(
                                name: "hexCode",
                                decoration: customTextFieldDecoration(
                                  "Hex Code",
                                  prefixIcon: Icons.code_outlined,
                                ),
                                readOnly: true,
                                validator: FormBuilderValidators.compose([
                                  (value) {
                                    if (value != null && value.isNotEmpty) {
                                      String hex = value.replaceAll('#', '');
                                      // Check if it's a valid hex code (3 or 6 digits)
                                      if (hex.length != 3 && hex.length != 6) {
                                        return 'Hex code must be 3 or 6 characters';
                                      }
                                      // Check if it contains only valid hex characters
                                      if (!RegExp(r'^[A-Fa-f0-9]+$').hasMatch(hex)) {
                                        return 'Hex code must contain only valid hex characters (0-9, A-F)';
                                      }
                                    }
                                    return null;
                                  },
                                ]),
                                onChanged: (value) {
                                  setState(() {
                                    _initialValue['hexCode'] = value;
                                    _selectedColor = _parseHexColor(value);
                                  });
                                },
                              ),
                              const SizedBox(height: 24),

                              // IsActive Switch
                              Row(
                                children: [
                                  const Text(
                                    'Active Dye Color',
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

