import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/tool_model.dart';
import '../../providers/app_providers.dart';

class AddToolScreen extends ConsumerStatefulWidget {
  const AddToolScreen({super.key});

  @override
  ConsumerState<AddToolScreen> createState() => _AddToolScreenState();
}

class _AddToolScreenState extends ConsumerState<AddToolScreen> {
  final _formKey = GlobalKey<FormState>();
  final _toolNameController = TextEditingController();
  final _monthlyPriceController = TextEditingController();
  final _seatsController = TextEditingController();
  final _growthRateController = TextEditingController();

  String _selectedCategory = AppConstants.toolCategories.first;
  String _selectedBillingType = AppConstants.billingMonthly;
  bool _isLoading = false;

  @override
  void dispose() {
    _toolNameController.dispose();
    _monthlyPriceController.dispose();
    _seatsController.dispose();
    _growthRateController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(supabaseRepositoryProvider);
      final userId = repository.currentUserId;

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final tool = ToolModel(
        id: const Uuid().v4(),
        userId: userId,
        toolName: _toolNameController.text.trim(),
        category: _selectedCategory,
        monthlyPrice: double.parse(_monthlyPriceController.text),
        seats: int.parse(_seatsController.text),
        billingType: _selectedBillingType,
        growthRate: double.parse(_growthRateController.text),
        createdAt: DateTime.now(),
      );

      final addTool = ref.read(addToolProvider);
      await addTool(tool);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tool added successfully!'),
            backgroundColor: AppTheme.accentColor,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add SaaS Tool')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tool Name
              TextFormField(
                controller: _toolNameController,
                decoration: const InputDecoration(
                  labelText: 'Tool Name',
                  hintText: 'e.g., Slack, Notion, Figma',
                  prefixIcon: Icon(Icons.apps),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter tool name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.spacing16),

              // Category Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category),
                ),
                items: AppConstants.toolCategories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCategory = value);
                  }
                },
              ),
              const SizedBox(height: AppTheme.spacing16),

              // Monthly Price
              TextFormField(
                controller: _monthlyPriceController,
                decoration: const InputDecoration(
                  labelText: 'Monthly Price',
                  hintText: '0.00',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter monthly price';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price < 0) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.spacing16),

              // Seats
              TextFormField(
                controller: _seatsController,
                decoration: const InputDecoration(
                  labelText: 'Number of Seats',
                  hintText: '0',
                  prefixIcon: Icon(Icons.people),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter number of seats';
                  }
                  final seats = int.tryParse(value);
                  if (seats == null || seats < 0) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.spacing16),

              // Billing Type
              DropdownButtonFormField<String>(
                initialValue: _selectedBillingType,
                decoration: const InputDecoration(
                  labelText: 'Billing Type',
                  prefixIcon: Icon(Icons.payment),
                ),
                items: const [
                  DropdownMenuItem(
                    value: AppConstants.billingMonthly,
                    child: Text('Monthly'),
                  ),
                  DropdownMenuItem(
                    value: AppConstants.billingYearly,
                    child: Text('Yearly'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedBillingType = value);
                  }
                },
              ),
              const SizedBox(height: AppTheme.spacing16),

              // Growth Rate
              TextFormField(
                controller: _growthRateController,
                decoration: const InputDecoration(
                  labelText: 'Expected Yearly Growth Rate (%)',
                  hintText: '0.0',
                  prefixIcon: Icon(Icons.trending_up),
                  helperText: 'Expected annual price increase percentage',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter growth rate';
                  }
                  final rate = double.tryParse(value);
                  if (rate == null || rate < 0 || rate > 100) {
                    return 'Please enter a valid percentage (0-100)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.spacing32),

              // Submit Button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Add Tool'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
