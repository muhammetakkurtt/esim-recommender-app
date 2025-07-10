import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;

import '../../models/esim_recommender_model.dart';
import '../widgets/map_location_selector.dart';
import '../services/country_service.dart';
import '../utils/styles/form_styles.dart';
import '../utils/extensions/form_extensions.dart';
import '../widgets/form_widgets/form_field_container.dart';
import '../widgets/form_widgets/text_input_field.dart';
import '../widgets/form_widgets/country_dropdown_field.dart';
import '../widgets/form_widgets/submit_button.dart';

class TripInfoForm extends StatefulWidget {
  const TripInfoForm({super.key});

  @override
  State<TripInfoForm> createState() => _TripInfoFormState();
}

class _TripInfoFormState extends State<TripInfoForm> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormBuilderState>();
  
  // Selected country values 
  String? selectedCountryCode;
  String? selectedCountryName;
  
  // Only for UI animations
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  
  // Map controller
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    
    // Create animation controller 
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 100),
    );
    
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_animationController);
    
    // Start animation
    _animationController.repeat();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Get current selected country info from CountryService
    final countryService = Provider.of<CountryService>(context);
    if (countryService.selectedCountryName != null && 
        countryService.selectedCountryCode != null) {
      // Update local state if there is a selected country
      setState(() {
        selectedCountryName = countryService.selectedCountryName;
        selectedCountryCode = countryService.selectedCountryCode;
      });
      
      // Update the form field as well (if form is already created)
      if (_formKey.currentState != null) {
        _formKey.updateFieldValue('country', selectedCountryCode);
      }
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // When country is selected
  void _onCountrySelected(String? countryCode) {
    setState(() {
      selectedCountryCode = countryCode;
    });
  }
  
  // When selection is made from the map
  void _onMapTap(LatLng point) {
    final countryService = Provider.of<CountryService>(context, listen: false);
    
    // Save previous values
    final previousCountryName = selectedCountryName;
    
    // Notify CountryService about the new location
    countryService.selectLocation(point);
    
    // Get new country information
    final countryCode = countryService.selectedCountryCode;
    final countryName = countryService.selectedCountryName;
    
    if (countryCode != null) {
      // If a new country is selected, update state and form field
      if (countryName != previousCountryName) {
        setState(() {
          selectedCountryName = countryName;
          selectedCountryCode = countryCode;
        });
        
        // Update form field
        _formKey.updateFieldValue('country', countryCode);
        
        // Haptic feedback
        HapticFeedback.selectionClick();
      }
    }
  }
  
  // When form is submitted
  void _handleSubmit(ESIMRecommenderModel model) {
    if (_formKey.validateAndSave()) {
      final formData = _formKey.formData;
      
      // Check if country is selected
      if (formData['country'] == null || formData['country'].toString().isEmpty) {
        context.showErrorSnackBar('Please select a country');
        return;
      }
      
      // Success haptic feedback
      context.hapticFeedback(HapticFeedbackType.success);
      
      model.updateFormData({...formData});
      model.getRecommendation();
    } else {
      // Notify user if form validation fails
      final errorText = _formKey.getFieldValue('country') == null
          ? 'Please select a country'
          : 'Please fill in all fields correctly';
      
      // Show error
      context.showErrorSnackBar(errorText);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final model = Provider.of<ESIMRecommenderModel>(context);
    final countryService = Provider.of<CountryService>(context);
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Colors.blue.shade100, Colors.blue.shade50],
          stops: const [0.0, 0.7, 1.0],
        ),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Form title
              FormStyles.buildGradientTitle('Enter Your Travel Information'),
              const SizedBox(height: 10),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Text(
                  'You can choose from ${countryService.countryMap.length} countries',
                  key: ValueKey(countryService.countryMap.length),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    fontStyle: FontStyle.italic
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 25),
              
              // Map component
              MapLocationSelector(
                externalMapController: _mapController,
                onMapTap: _onMapTap,
              ),
              
              // Country selection
              CountryDropdownField(
                initialCountryCode: selectedCountryCode,
                initialCountryName: selectedCountryName,
                onCountrySelected: _onCountrySelected,
              ),
              
              // Duration field
              TextInputField.number(
                name: 'duration',
                label: 'Duration of Stay (days)',
                prefixIcon: Icons.calendar_today,
                suffixIcon: Icons.nights_stay,
                minValue: 1,
              ),
              
              // Data amount field
              TextInputField.number(
                name: 'data_needed',
                label: 'Data Needed (GB)',
                prefixIcon: Icons.data_usage,
                suffixIcon: Icons.wifi,
                minValue: 0.1,
              ),
              
              // Budget field
              TextInputField.number(
                name: 'budget',
                label: 'Budget (USD)',
                prefixIcon: Icons.attach_money,
                suffixIcon: Icons.account_balance_wallet,
                minValue: 1,
                textInputAction: TextInputAction.done,
              ),
              
              // Submit button
              SubmitButton(
                text: 'Get Recommendation',
                icon: Icons.travel_explore,
                isLoading: model.isLoading,
                onPressed: () => _handleSubmit(model),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 