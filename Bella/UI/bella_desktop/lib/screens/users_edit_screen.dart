import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:bella_desktop/layouts/master_screen.dart';
import 'package:bella_desktop/model/user.dart';
import 'package:bella_desktop/model/city.dart';
import 'package:bella_desktop/model/gender.dart';
import 'package:bella_desktop/providers/user_provider.dart';
import 'package:bella_desktop/providers/city_provider.dart';
import 'package:bella_desktop/providers/gender_provider.dart';
import 'package:bella_desktop/utils/base_textfield.dart';
import 'package:bella_desktop/utils/base_switch.dart';
import 'package:bella_desktop/utils/base_image_picker.dart';
import 'package:bella_desktop/screens/users_list_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

// Orange color scheme matching the app
const Color _orangePrimary = Color(0xFFFF8C42);
const Color _orangeDark = Color(0xFFFF6B1A);

class UsersEditScreen extends StatefulWidget {
  final User user;

  const UsersEditScreen({super.key, required this.user});

  @override
  State<UsersEditScreen> createState() => _UsersEditScreenState();
}

class _UsersEditScreenState extends State<UsersEditScreen> {
  final formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late UserProvider userProvider;
  late CityProvider cityProvider;
  late GenderProvider genderProvider;
  bool isLoading = true;
  bool _isLoadingCities = true;
  bool _isLoadingGenders = true;
  bool _isSaving = false;
  List<City> _cities = [];
  List<Gender> _genders = [];
  City? _selectedCity;
  Gender? _selectedGender;
  File? _image;

  final double leftColumnWidth = 300;

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    cityProvider = Provider.of<CityProvider>(context, listen: false);
    genderProvider = Provider.of<GenderProvider>(context, listen: false);
    _initialValue = {
      "firstName": widget.user.firstName,
      "lastName": widget.user.lastName,
      "email": widget.user.email,
      "username": widget.user.username,
      "phoneNumber": widget.user.phoneNumber ?? '',
      "isActive": widget.user.isActive,
      "picture": widget.user.picture,
    };
    initFormData();
    _loadCities();
    _loadGenders();
  }

  initFormData() async {
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _loadCities() async {
    try {
      setState(() {
        _isLoadingCities = true;
      });

      final result = await cityProvider.get();
      if (result.items != null && result.items!.isNotEmpty) {
        setState(() {
          _cities = result.items!;
          _isLoadingCities = false;
        });
        _setDefaultCitySelection();
      } else {
        setState(() {
          _cities = [];
          _isLoadingCities = false;
        });
      }
    } catch (e) {
      setState(() {
        _cities = [];
        _isLoadingCities = false;
      });
    }
  }

  void _setDefaultCitySelection() {
    if (_cities.isNotEmpty) {
      try {
        _selectedCity = _cities.firstWhere(
          (city) => city.id == widget.user.cityId,
          orElse: () => _cities.first,
        );
      } catch (e) {
        _selectedCity = _cities.first;
      }
      setState(() {});
    }
  }

  Future<void> _loadGenders() async {
    try {
      setState(() {
        _isLoadingGenders = true;
      });

      final result = await genderProvider.get();
      if (result.items != null && result.items!.isNotEmpty) {
        setState(() {
          _genders = result.items!;
          _isLoadingGenders = false;
        });
        _setDefaultGenderSelection();
      } else {
        setState(() {
          _genders = [];
          _isLoadingGenders = false;
        });
      }
    } catch (e) {
      setState(() {
        _genders = [];
        _isLoadingGenders = false;
      });
    }
  }

  void _setDefaultGenderSelection() {
    if (_genders.isNotEmpty) {
      try {
        _selectedGender = _genders.firstWhere(
          (gender) => gender.id == widget.user.genderId,
          orElse: () => _genders.first,
        );
      } catch (e) {
        _selectedGender = _genders.first;
      }
      setState(() {});
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

  Widget _buildCityDropdown() {
    if (_isLoadingCities) {
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
            Text("Loading cities...", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_cities.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Text(
          "No cities available",
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return DropdownButtonFormField<City>(
      value: _selectedCity,
      decoration: customTextFieldDecoration(
        "City",
        prefixIcon: Icons.location_city,
      ),
      items: _cities.map((city) {
        return DropdownMenuItem<City>(value: city, child: Text(city.name));
      }).toList(),
      onChanged: (City? value) {
        setState(() {
          _selectedCity = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return "Please select a city";
        }
        return null;
      },
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

    return DropdownButtonFormField<Gender>(
      value: _selectedGender,
      decoration: customTextFieldDecoration("Gender", prefixIcon: Icons.person),
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
      validator: (value) {
        if (value == null) {
          return "Please select a gender";
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Edit User",
      showBackButton: true,
      child: _buildForm(),
    );
  }

  Widget _buildSaveButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          onPressed: _isSaving
              ? null
              : () {
                  Navigator.of(context).pop();
                },
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
                      if (_selectedCity == null || _selectedGender == null) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Validation Error'),
                            content: const Text(
                              'Please select both city and gender',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                        return;
                      }

                      setState(() => _isSaving = true);
                      var request = Map.from(formKey.currentState?.value ?? {});
                      request['cityId'] = _selectedCity!.id;
                      request['genderId'] = _selectedGender!.id;
                      request['picture'] = _initialValue['picture'];
                      request['isActive'] = _initialValue['isActive'] ?? true;

                      try {
                        await userProvider.update(widget.user.id, request);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('User updated successfully'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 1),
                          ),
                        );
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const UsersListScreen(),
                            settings: const RouteSettings(
                              name: 'UsersListScreen',
                            ),
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
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1100),
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
                          Icons.person_rounded,
                          size: 24,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Edit User",
                        style: TextStyle(
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
                  child: FormBuilder(
                    key: formKey,
                    initialValue: _initialValue,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                    // Measure left column height dynamically by using IntrinsicHeight on the whole row
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Left column: picture + buttons
                          SizedBox(
                            width: leftColumnWidth,
                            child: BaseImagePicker(
                              base64Image: _initialValue['picture'] as String?,
                              onSelectImage: _pickImage,
                              onClearImage: () {
                                setState(() {
                                  _image = null;
                                  _initialValue['picture'] = null;
                                });
                              },
                              imageSize: 200,
                              label: "Profile Picture",
                              placeholderIcon: Icons.person,
                            ),
                          ),

                          const SizedBox(width: 24),

                          // Middle column aligned to bottom
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  FormBuilderTextField(
                                    name: "firstName",
                                    decoration: customTextFieldDecoration(
                                      "First Name",
                                      prefixIcon: Icons.person_outline,
                                    ),
                                    validator: FormBuilderValidators.compose([
                                      FormBuilderValidators.required(),
                                      FormBuilderValidators.match(
                                        RegExp(r'^[\p{L} ]+$', unicode: true),
                                        errorText:
                                            'Only letters (including international), and spaces allowed',
                                      ),
                                    ]),
                                  ),
                                  const SizedBox(height: 16),
                                  FormBuilderTextField(
                                    name: "lastName",
                                    decoration: customTextFieldDecoration(
                                      "Last Name",
                                      prefixIcon: Icons.person_outline,
                                    ),
                                    validator: FormBuilderValidators.compose([
                                      FormBuilderValidators.required(),
                                      FormBuilderValidators.match(
                                        RegExp(r'^[\p{L} ]+$', unicode: true),
                                        errorText:
                                            'Only letters (including international), and spaces allowed',
                                      ),
                                    ]),
                                  ),
                                  const SizedBox(height: 16),
                                  FormBuilderTextField(
                                    name: "username",
                                    decoration: customTextFieldDecoration(
                                      "Username",
                                      prefixIcon: Icons.alternate_email,
                                    ),
                                    validator: FormBuilderValidators.compose([
                                      FormBuilderValidators.required(),
                                      FormBuilderValidators.minLength(3),
                                      FormBuilderValidators.maxLength(50),
                                    ]),
                                  ),
                                  const SizedBox(height: 16),
                                  FormBuilderTextField(
                                    name: "email",
                                    decoration: customTextFieldDecoration(
                                      "Email",
                                      prefixIcon: Icons.email,
                                    ),
                                    validator: FormBuilderValidators.compose([
                                      FormBuilderValidators.required(),
                                      FormBuilderValidators.email(),
                                    ]),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 24),

                          // Right column aligned to bottom
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  FormBuilderTextField(
                                    name: "phoneNumber",
                                    decoration: customTextFieldDecoration(
                                      "Phone Number (Optional)",
                                      prefixIcon: Icons.phone,
                                    ),
                                    validator: FormBuilderValidators.compose([
                                      FormBuilderValidators.match(
                                        RegExp(r'^[\d\s\-\+\(\)]+$'),
                                        errorText:
                                            'Please enter a valid phone number',
                                      ),
                                    ]),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildCityDropdown(),
                                  const SizedBox(height: 16),
                                  _buildGenderDropdown(),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      const Text(
                                        'Active Account',
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
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                        const SizedBox(height: 50),

                        _buildSaveButton(),
                      ],
                    ),
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
