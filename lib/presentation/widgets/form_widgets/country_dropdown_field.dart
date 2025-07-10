import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:country_flags/country_flags.dart';
import 'package:provider/provider.dart';

import '../form_widgets/form_field_container.dart';
import '../../utils/styles/form_styles.dart';
import '../../services/country_service.dart';
import '../../services/country_iso_codes.dart';

/// Country selection dropdown widget
class CountryDropdownField extends StatefulWidget {
  /// Callback when selected country changes
  final Function(String?)? onCountrySelected;
  
  /// Initial selected country code
  final String? initialCountryCode;
  
  /// Initial selected country name
  final String? initialCountryName;

  const CountryDropdownField({
    super.key,
    this.onCountrySelected,
    this.initialCountryCode,
    this.initialCountryName,
  });

  @override
  State<CountryDropdownField> createState() => _CountryDropdownFieldState();
}

class _CountryDropdownFieldState extends State<CountryDropdownField> {
  String? selectedCountryCode;
  String? selectedCountryName;

  @override
  void initState() {
    super.initState();
    selectedCountryCode = widget.initialCountryCode;
    selectedCountryName = widget.initialCountryName;
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Get current selected country information from CountryService
    final countryService = Provider.of<CountryService>(context);
    if (countryService.selectedCountryName != null && 
        countryService.selectedCountryCode != null) {
      // If there is a selected country, update local state
      setState(() {
        selectedCountryName = countryService.selectedCountryName;
        selectedCountryCode = countryService.selectedCountryCode;
      });
    }
  }

  void _onCountrySelected(String? countryName) {
    if (countryName == null) return;
    
    final countryService = Provider.of<CountryService>(context, listen: false);
    countryService.selectCountry(countryName);
    
    setState(() {
      selectedCountryName = countryName;
      selectedCountryCode = countryService.selectedCountryCode;
    });
    
    if (widget.onCountrySelected != null) {
      widget.onCountrySelected!(selectedCountryCode);
    }
    
    // Haptic feedback
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    final countryService = Provider.of<CountryService>(context);
    final countryMap = countryService.countryMap;
    final countryNameToCode = countryService.countryNameToCode;
    final isLoading = countryService.isLoadingCountries;
    
    // Get selected country info from CountryService and update if necessary
    if (countryService.selectedCountryName != null && 
        countryService.selectedCountryName != selectedCountryName) {
      Future.microtask(() {
        setState(() {
          selectedCountryName = countryService.selectedCountryName;
          selectedCountryCode = countryService.selectedCountryCode;
        });
      });
    }

    return FormFieldContainer(
      child: isLoading
      ? Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                const CircularProgressIndicator(
                  color: FormStyles.primaryColor,
                  strokeWidth: 3,
                ),
                const SizedBox(height: 16),
                Text(
                  'Loading countries...',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        )
      : FormBuilderField<String>(
          name: 'country',
          initialValue: selectedCountryCode,
          onChanged: (value) {
            selectedCountryCode = value;
          },
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(errorText: 'Please select a country'),
          ]),
          builder: (FormFieldState<String> field) {
            return DropdownSearch<String>(
              popupProps: PopupProps.menu(
                showSelectedItems: true,
                showSearchBox: true,
                itemBuilder: _buildCountryItem(countryNameToCode),
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                menuProps: MenuProps(
                  backgroundColor: Colors.white,
                  elevation: 16,
                  shadowColor: Colors.black.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                searchFieldProps: TextFieldProps(
                  decoration: InputDecoration(
                    hintText: 'Search country name...',
                    prefixIcon: const Icon(Icons.search, color: FormStyles.primaryColor),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: FormStyles.primaryColor),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  ),
                  cursorColor: FormStyles.primaryColor,
                ),
                title: Container(
                  decoration: const BoxDecoration(
                    color: FormStyles.primaryColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.travel_explore, color: Colors.white),
                      SizedBox(width: 12),
                      Text(
                        'Select Country',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                emptyBuilder: (context, searchEntry) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No results found for "$searchEntry"',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              items: (String filter, LoadProps? props) {
                final sortedItems = countryMap.keys.toList()..sort();
                if (filter.isEmpty) {
                  return sortedItems;
                } else {
                  return sortedItems.where((country) => 
                    country.toLowerCase().contains(filter.toLowerCase())).toList();
                }
              },
              decoratorProps: DropDownDecoratorProps(
                decoration: InputDecoration(
                  labelStyle: TextStyle(
                    color: field.errorText != null ? FormStyles.errorColor : Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                  errorText: field.errorText,
                  prefixIcon: Icon(
                    Icons.public, 
                    color: field.errorText != null ? FormStyles.errorColor : FormStyles.primaryColor,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: field.errorText != null ? FormStyles.errorColor : Colors.grey.shade300,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: FormStyles.primaryColor, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: FormStyles.errorColor, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                ),
              ),
              selectedItem: selectedCountryName,
              dropdownBuilder: _buildSelectedItem(countryNameToCode),
              onChanged: (value) {
                if (value != null) {
                  _onCountrySelected(value);
                  field.didChange(countryNameToCode[value]);
                }
              },
            );
          },
        ),
    );
  }
  
  // Creates a country list item
  Widget Function(BuildContext, String, bool, bool) _buildCountryItem(Map<String, String> countryNameToCode) {
    return (context, country, isSelected, isFocused) {
      final countryCode = countryNameToCode[country];
      final isoCode = CountryISOCodes.getISOCode(countryCode);
      
      return Container(
        decoration: BoxDecoration(
          color: isSelected ? FormStyles.primaryColor.withOpacity(0.1) : 
                  (isFocused ? Colors.grey.shade100 : null),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            // Country flag
            if (isoCode.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: CountryFlag.fromCountryCode(
                  isoCode,
                  height: 24,
                  width: 32,
                  shape: const RoundedRectangle(4),
                ),
              ),
            // Country name
            Expanded(
              child: Text(
                country,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? FormStyles.primaryColor : Colors.black87,
                ),
              ),
            ),
            // Selected indicator
            if (isSelected)
              const Icon(
                Icons.check_circle, 
                color: FormStyles.primaryColor, 
                size: 20,
              ),
          ],
        ),
      );
    };
  }
  
  // Creates a view for the selected country
  Widget Function(BuildContext, String?) _buildSelectedItem(Map<String, String> countryNameToCode) {
    return (context, selectedItem) {
      final countryCode = selectedItem != null ? countryNameToCode[selectedItem] : null;
      final isoCode = CountryISOCodes.getISOCode(countryCode);
      
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            // Flag indicator
            if (isoCode.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CountryFlag.fromCountryCode(
                    isoCode,
                    height: 32,
                    width: 40,
                    shape: const RoundedRectangle(4),
                  ),
                ),
              )
            else
              // Selection indicator (when no country is selected)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.grey,
                  size: 18,
                ),
              ),
            const SizedBox(width: 12),
            // Country name or selection text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    selectedItem ?? "Please select a country",
                    style: TextStyle(
                      color: selectedItem == null ? Colors.grey : Colors.black87,
                      fontWeight: selectedItem == null ? FontWeight.normal : FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (selectedItem != null)
                    Text(
                      "Country to visit",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    };
  }
} 