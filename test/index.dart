import 'package:lib_extent/Textent.dart';

main() {

  Textent.measureTexts(["Measure me", "Me too!"], "15px arial,sans-serif").then((Map<String, TextSize> textSizes) {
    Textent.measureTexts(["Measure me", "Me too!"], "15px arial,sans-serif").then((Map<String, TextSize> textSizes) {
      print("Our sizes are $textSizes");
    });
  });

  Textent.measureText("Measure me", "15px arial,sans-serif").then((TextSize textSize) {
    print("My size is $textSize");
  });
}