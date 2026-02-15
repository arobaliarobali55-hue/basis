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
  final _seatsController = TextEditingController(); // [RESTORED]
  final _growthRateController = TextEditingController(); // [RESTORED]
  final _assignedSeatsController = TextEditingController();

  String _selectedCategory = AppConstants.toolCategories.first;
  String _selectedBillingType = AppConstants.billingMonthly;
  bool _isLoading = false;

  @override
  void dispose() {
    _toolNameController.dispose();
    _monthlyPriceController.dispose();
    _seatsController.dispose();
    _assignedSeatsController.dispose(); // [NEW]
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

      // Default assigned seats to total seats if not provided
      final seats = int.parse(_seatsController.text);
      final assignedSeatsText = _assignedSeatsController.text.trim();
      final assignedSeats = assignedSeatsText.isEmpty
          ? seats
          : int.parse(assignedSeatsText);

      final tool = ToolModel(
        id: const Uuid().v4(),
        userId: userId,
        toolName: _toolNameController.text.trim(),
        category: _selectedCategory,
        monthlyPrice: double.parse(_monthlyPriceController.text),
        seats: seats,
        assignedSeats: assignedSeats, // [NEW]
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
                  labelText: 'Monthly Price (Per Seat)',
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

              // Row for Seats and Assigned Seats
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _seatsController,
                      decoration: const InputDecoration(
                        labelText: 'Total Seats',
                        hintText: '0',
                        prefixIcon: Icon(Icons.event_seat),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final seats = int.tryParse(value);
                        if (seats == null || seats < 0) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing16),
                  Expanded(
                    child: TextFormField(
                      controller: _assignedSeatsController,
                      decoration: const InputDecoration(
                        labelText: 'Active Users',
                        hintText: 'Optional',
                        prefixIcon: Icon(Icons.people),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) return null;
                        final assigned = int.tryParse(value);
                        final total = int.tryParse(_seatsController.text) ?? 0;
                        if (assigned == null || assigned < 0) return 'Invalid';
                        if (assigned > total) return '> Total';
                        return null;
                      },
                    ),
                  ),
                ],
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
