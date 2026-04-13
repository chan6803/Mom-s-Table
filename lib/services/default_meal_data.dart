import '../models/meal_model.dart';

class DefaultMealData {
  static List<MealItem> breakfast() => [
    MealItem(name: '공깃밥', type: '주식', kcal: 300, dotColor: 'main',
      ingredients: ['쌀 180g', '물 200ml'],
      steps: ['쌀을 30분 불린다.', '전기밥솥에 취사한다.', '뜸 들인 후 주걱으로 섞는다.']),
    MealItem(name: '된장국', type: '국', kcal: 60, dotColor: 'soup',
      ingredients: ['된장 1.5T', '두부 100g', '애호박 60g', '다시마육수 400ml'],
      steps: ['육수를 끓인다.', '된장을 풀고 두부·호박을 넣는다.', '5분 끓이고 파를 올린다.']),
    MealItem(name: '계란후라이', type: '반찬', kcal: 90, dotColor: 'side',
      ingredients: ['계란 1개', '식용유 1t', '소금 약간'],
      steps: ['팬을 중약불로 달군다.', '기름 두르고 계란을 깬다.', '흰자가 익으면 소금을 뿌린다.']),
    MealItem(name: '김치', type: '반찬', kcal: 15, dotColor: 'side',
      ingredients: ['배추김치 70g'],
      steps: ['냉장고에서 꺼내 담는다.']),
    MealItem(name: '멸치볶음', type: '반찬', kcal: 55, dotColor: 'side',
      ingredients: ['잔멸치 40g', '마늘 1t', '간장 1t', '설탕 0.5t', '참기름', '통깨'],
      steps: ['멸치를 먼저 볶는다.', '간장·설탕·마늘을 넣고 볶는다.', '참기름·통깨로 마무리한다.']),
  ];

  static List<MealItem> lunch() => [
    MealItem(name: '공깃밥', type: '주식', kcal: 300, dotColor: 'main',
      ingredients: ['쌀 180g'], steps: ['쌀을 씻어 취사한다.']),
    MealItem(name: '김치찌개', type: '찌개', kcal: 120, dotColor: 'soup',
      ingredients: ['신김치 150g', '돼지고기 80g', '두부 100g', '고추장 1t', '다진마늘 1t', '물 400ml'],
      steps: ['고기를 볶다가 김치를 넣고 볶는다.', '물을 붓고 고추장·마늘을 넣는다.', '두부 넣고 10분 끓인다.']),
    MealItem(name: '콩나물무침', type: '반찬', kcal: 35, dotColor: 'side',
      ingredients: ['콩나물 100g', '소금', '참기름', '깨', '다진마늘'],
      steps: ['콩나물을 데친다.', '물기를 빼고 양념에 무친다.']),
    MealItem(name: '김구이', type: '반찬', kcal: 20, dotColor: 'side',
      ingredients: ['조미김 5장'], steps: ['꺼내서 담는다.']),
    MealItem(name: '깍두기', type: '반찬', kcal: 20, dotColor: 'side',
      ingredients: ['깍두기 70g'], steps: ['냉장고에서 꺼내 담는다.']),
  ];

  static List<MealItem> dinner() => [
    MealItem(name: '공깃밥', type: '주식', kcal: 300, dotColor: 'main',
      ingredients: ['쌀 180g'], steps: ['쌀을 씻어 취사한다.']),
    MealItem(name: '미역국', type: '국', kcal: 45, dotColor: 'soup',
      ingredients: ['마른미역 10g', '참기름 1T', '간장 2t', '다진마늘 0.5t', '물 500ml'],
      steps: ['미역을 불려 참기름에 볶는다.', '물을 붓고 간장·마늘로 간한다.', '15분 끓인다.']),
    MealItem(name: '잡채', type: '반찬', kcal: 180, dotColor: 'side',
      ingredients: ['당면 60g', '시금치 50g', '당근 30g', '양파 40g', '간장 2T', '설탕 1T', '참기름', '통깨'],
      steps: ['당면 삶아 참기름에 무친다.', '채소를 각각 볶는다.', '당면과 채소를 합쳐 양념해 볶는다.']),
    MealItem(name: '두부조림', type: '반찬', kcal: 90, dotColor: 'side',
      ingredients: ['두부 150g', '간장 2T', '고춧가루 1T', '설탕 1t', '대파', '참기름'],
      steps: ['두부를 1cm로 썬다.', '앞뒤로 굽는다.', '양념장으로 조린다.']),
    MealItem(name: '시금치나물', type: '반찬', kcal: 40, dotColor: 'side',
      ingredients: ['시금치 150g', '참기름 1t', '소금', '통깨', '다진마늘'],
      steps: ['데쳐서 물기를 뺀다.', '양념에 무친다.']),
  ];

  static DayMeal defaultDay() => DayMeal(
    breakfast: breakfast(),
    lunch: lunch(),
    dinner: dinner(),
  );
}
