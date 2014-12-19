textent
===========

Dart library to pre-determine the size of texts to be rendered in the DOM.

Sample usage
-----------

```
Textent.measureTexts(["Measure me", "Me too!"], "15px arial,sans-serif", cssMaxWidthProperty: "100px")
.then((Map<String, TextSize> textSizes) {
  print("Our sizes are $textSizes");
});

Textent.measureText("Measure me", "15px arial,sans-serif", cssMaxWidthProperty: "100px")
.then((TextSize textSize) {
  print("My size is $textSize");
});
```
