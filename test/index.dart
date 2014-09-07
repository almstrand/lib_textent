import 'package:textent/textent.dart';

main() {

  Textent.measureTexts(["Measure me", "Me too!"], "150px arial,sans-serif").then((Map<String, TextSize> textSizes) {
    Textent.measureTexts(["Measure me", "Me too!"], "150px arial,sans-serif").then((Map<String, TextSize> textSizes) {
      print("Our sizes are $textSizes");
    });
  });

//  Textent.measureText("Measure me", "15px arial,sans-serif").then((TextSize textSize) {
//    print("My size is $textSize");
//  });
}