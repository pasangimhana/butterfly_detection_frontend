import 'package:foodie/models/meal_model.dart';

Meal getSampleData(String food) {
  late Meal meal;
  switch (food) {
    case 'Bread':
      {
        meal = Meal(type: food, nutritions: {
          "Carbs": "50%",
          "Protein": "10%",
          "Fat": "5%",
          "Sugar": "5%",
        }, diseases: []);
        return meal;
      }
    case 'Dairy product':
      {
        meal = Meal(type: food, nutritions: {
          "Carbs": "10%",
          "Protein": "20%",
          "Fat": "30%",
          "Sugar": "5%",
        }, diseases: []);
        return meal;
      }
    case 'Dessert':
      {
        meal = Meal(type: food, nutritions: {
          "Carbs": "40%",
          "Protein": "5%",
          "Fat": "25%",
          "Sugar": "50%",
        }, diseases: ['Diabetes']);
        return meal;
      }
    case 'Egg':
      {
        meal = Meal(type: food, nutritions: {
          "Carbs": "2%",
          "Protein": "70%",
          "Fat": "28%",
          "Sugar": "1%",
        }, diseases: []);
        return meal;
      }
    case 'Fried food':
      {
        meal = Meal(type: food, nutritions: {
          "Carbs": "30%",
          "Protein": "15%",
          "Fat": "50%",
          "Sugar": "2%",
        }, diseases: []);
        return meal;
      }
    case 'Meat':
      {
        meal = Meal(type: food, nutritions: {
          "Carbs": "0%",
          "Protein": "80%",
          "Fat": "20%",
          "Sugar": "0%",
        }, diseases: []);
        return meal;
      }
    case 'Noodles-Pasta':
      {
        meal = Meal(type: food, nutritions: {
          "Carbs": "70%",
          "Protein": "12%",
          "Fat": "2%",
          "Sugar": "2%",
        },diseases: []);
        return meal;
      }
    case 'Rice':
      {
        meal = Meal(type: food, nutritions: {
          "Carbs": "80%",
          "Protein": "7%",
          "Fat": "1%",
          "Sugar": "0%",
        },diseases: []);
        return meal;
      }
    case 'Seafood':
      {
        meal = Meal(type: food, nutritions: {
          "Carbs": "5%",
          "Protein": "70%",
          "Fat": "25%",
          "Sugar": "1%",
        },diseases: []);
        return meal;
      }
    case 'Soup':
      {
        meal = Meal(type: food, nutritions: {
          "Carbs": "40%",
          "Protein": "10%",
          "Fat": "5%",
          "Sugar": "5%",
        },diseases: []);
        return meal;
      }
    case 'Vegetable-Fruit':
      {
        meal = Meal(type: food, nutritions: {
          "Carbs": "90%",
          "Protein": "2%",
          "Fat": "1%",
          "Sugar": "7%",
        },diseases: []);
        return meal;
      }
    default:
      {
        return meal = Meal(type: food, nutritions: {},diseases: []);
      }
  }
}
