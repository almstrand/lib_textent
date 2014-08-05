textent
===========

Simple Dart library to determine the size of texts to be rendered in the DOM.

Sample usage:

  Textent.measureTexts(["Measure me", "Me too!"], "15px arial,sans-serif").then((Map<String, TextSize> textSizes) {
    print("Our sizes are $textSizes");
  });

  Textent.measureText("Measure me", "15px arial,sans-serif").then((TextSize textSize) {
    print("My size is $textSize");
  });
