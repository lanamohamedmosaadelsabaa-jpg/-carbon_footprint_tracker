class CarbonCalculator {
  // Estimated monthly kgCO2e per category choice — simplified averages
  // inspired by typical EPA/DEFRA category-level emission figures,
  // scaled down to rough monthly buckets for onboarding-level estimates.

  static const Map<String, double> transport = {
    'Car (petrol/diesel)': 250,
    'Electric vehicle': 60,
    'Public transport': 90,
    'Walking / cycling': 5,
  };

  static const Map<String, double> diet = {
    'Meat in most meals': 210,
    'Meat a few times a week': 150,
    'Vegetarian': 100,
    'Vegan': 75,
  };

  static const Map<String, double> energy = {
    'Grid electricity (standard)': 180,
    'Some solar/renewable': 120,
    'Mostly solar/renewable': 40,
    'Not sure': 150,
  };

  static const Map<String, double> waste = {
    'I recycle regularly': 20,
    'I recycle sometimes': 40,
    "I don't really recycle": 70,
    "Not sure what's recyclable": 55,
  };

  static const Map<String, double> flights = {
    'None this year': 0,
    '1–2 flights': 42,
    '3–5 flights': 100,
    '6+ flights': 200,
  };
static const Map<String, double> dailyDiet = {
    'Vegan today': 2,
    'Vegetarian today': 3,
    '1 meat meal today': 4.5,
    '2 meat meals today': 6,
    '3+ meat meals today': 8,
  };
  static const Map<String, double> water = {
    'Short showers, mindful usage': 10,
    'Average household usage': 20,
    'Long showers / frequent baths': 35,
    'Not sure': 20,
  };

  static const Map<String, double> shopping = {
    'I buy only what I need': 20,
    'Occasional non-essential purchases': 45,
    'I shop often for clothes/gadgets': 80,
    'I shop very frequently': 120,
  };

  static const Map<String, double> outingFrequency = {
    'Rarely (0–1 times a month)': 10,
    'A few times a month (2–4x)': 25,
    'Weekly (1–2 times a week)': 45,
    'Very often (3+ times a week)': 70,
  };

  /// Takes the user's saved onboarding data and returns a category
  /// breakdown plus a total estimated monthly kgCO2e figure.
  static Map<String, dynamic> calculate(Map<String, dynamic> userData) {
    final breakdown = <String, double>{
      'Transport': transport[userData['transport']] ?? 0,
      'Diet': diet[userData['diet']] ?? 0,
      'Home energy': energy[userData['energy']] ?? 0,
      'Waste & recycling': waste[userData['waste']] ?? 0,
      'Flights': flights[userData['flightsPerYear']] ?? 0,
      'Water usage': water[userData['waterUsage']] ?? 0,
      'Shopping': shopping[userData['shopping']] ?? 0,
      'Going out': outingFrequency[userData['outingFrequency']] ?? 0,
    };

    final total = breakdown.values.fold<double>(0, (sum, v) => sum + v);

    return {
      'breakdown': breakdown,
      'totalMonthlyKgCO2e': total,
    };
  }
}