import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class ESIMRecommenderModel extends ChangeNotifier {
  Map<String, dynamic> formData = {};
  Map<String, dynamic> recommendation = {};
  bool isLoading = false;
  bool isLoadingScreenVisible = false;
  String? errorMessage;

  void updateFormData(Map<String, dynamic> data) {
    formData = data;
    notifyListeners();
  }

  void setLoading(bool loading) {
    isLoading = loading;
    notifyListeners();
  }
  
  void setLoadingScreenVisible(bool visible) {
    isLoadingScreenVisible = visible;
    notifyListeners();
  }

  void setRecommendation(Map<String, dynamic> data) {
    recommendation = data;
    if (data.isEmpty) {
      formData = {};
      errorMessage = null;
    }
    notifyListeners();
  }
  
  void setErrorMessage(String? message) {
    errorMessage = message;
    notifyListeners();
  }

  // Öneri alma işlemi
  Future<void> getRecommendation() async {
    setLoading(true);
    setLoadingScreenVisible(true);
    setErrorMessage(null);
    
    try {
      // Ülke kontrolü
      final String country = formData['country']?.toString() ?? '';
      if (country.isEmpty) {
        throw Exception('Lütfen bir ülke seçin');
      }
      
      // String'ten int/double dönüşümü
      final int tripDuration = int.tryParse(formData['duration']?.toString() ?? '0') ?? 0;
      final double dataNeeded = double.tryParse(formData['data_needed']?.toString() ?? '0') ?? 0;
      final double budget = double.tryParse(formData['budget']?.toString() ?? '0') ?? 0;
      
      // Ek kontroller
      if (tripDuration <= 0) {
        throw Exception('Kalış süresi en az 1 gün olmalıdır');
      }
      
      if (dataNeeded <= 0) {
        throw Exception('İhtiyaç duyulan veri miktarı belirtilmelidir');
      }
      
      if (budget <= 0) {
        throw Exception('Geçerli bir bütçe belirtilmelidir');
      }
      
      print('Öneri isteniyor: Ülke=$country, Süre=$tripDuration, Veri=$dataNeeded, Bütçe=$budget');
      
      // Yapay zeka deneyimini simüle etmek için kısa bir bekleme ekleyelim
      await Future.delayed(const Duration(seconds: 5));
      
      final recommendation = await FirebaseService.getESIMRecommendation(
        country: country,
        tripDuration: tripDuration,
        dataNeeded: dataNeeded,
        budget: budget,
      );
      
      setRecommendation(recommendation);
    } catch (e) {
      // Hata durumunda basit bir hata mesajı göster
      setErrorMessage(e.toString());
      setRecommendation({
        'error': true,
        'message': 'Öneri alınırken bir hata oluştu: ${e.toString()}',
      });
    } finally {
      setLoading(false);
      setLoadingScreenVisible(false);
    }
  }
} 