import 'package:bella_desktop/model/category.dart';
import 'package:bella_desktop/providers/category_provider.dart';
import 'package:flutter/material.dart';
import 'package:bella_desktop/layouts/master_screen.dart';
import 'package:bella_desktop/utils/base_textfield.dart';
import 'package:bella_desktop/utils/base_switch.dart';
import 'package:bella_desktop/screens/product_category_list_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

// Orange color scheme matching the app
const Color _orangePrimary = Color(0xFFFF8C42);
const Color _orangeDark = Color(0xFFFF6B1A);

class ProductCategoryEditScreen extends StatefulWidget {
  final Category? category;

  const ProductCategoryEditScreen({super.key, this.category});

  @override
  State<ProductCategoryEditScreen> createState() =>
      _ProductCategoryEditScreenState();
}

class _ProductCategoryEditScreenState
    extends State<ProductCategoryEditScreen> {
  final formKey = GlobalKey<FormBuilderState>();
  Map<String, dynamic> _initialValue = {};
  late CategoryProvider categoryProvider;
  bool isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    _initialValue = {
      "name": widget.category?.name ?? '',
      "description": widget.category?.description ?? '',
      "isActive": widget.category?.isActive ?? true,
      "createdAt": widget.category?.createdAt.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
    initFormData();
  }

  initFormData() async {
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: widget.category != null
          ? "Edit Category"
          : "Add Category",
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
                      request['isActive'] = _initialValue['isActive'] ?? true;

                      try {
                        if (widget.category == null) {
                          await categoryProvider.insert(request);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Category created successfully'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 1),
                            ),
                          );
                        } else {
                          await categoryProvider.update(
                              widget.category!.id, request);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Category updated successfully'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 1),
                            ),
                          );
                        }
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) =>
                                const ProductCategoryListScreen(),
                            settings: const RouteSettings(
                                name: 'ProductCategoryListScreen'),
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

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
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
                        Icons.category_rounded,
                        size: 24,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.category != null
                          ? "Edit Category"
                          : "Add New Category",
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
                child: FormBuilder(
                  key: formKey,
                  initialValue: _initialValue,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 24),

                      // Category Name
                      FormBuilderTextField(
                        name: "name",
                        decoration: customTextFieldDecoration(
                          "Category Name",
                          prefixIcon: Icons.category_outlined,
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.maxLength(150),
                        ]),
                      ),
                      const SizedBox(height: 24),

                      // Description
                      FormBuilderTextField(
                        name: "description",
                        decoration: customTextFieldDecoration(
                          "Description (Optional)",
                          prefixIcon: Icons.description_outlined,
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),

                      // IsActive Switch
                      Row(
                        children: [
                          const Text(
                            'Active Category',
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
      ),
    );
  }
}
