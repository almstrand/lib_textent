library textent;

import 'src/TextElement.dart';

import 'dart:async';
import 'dart:html';

part 'src/TextSize.dart';

class Textent {

  // Tracks whether custom element is registered to ensure it is only done once
  static bool isTextElementRegistered = false;

  // Cache of sizes of previously measured texts given various CSS font properties. TODO: support clearing cache and/or individual entries
  static final Map<String /*CSS font property*/, Map<String /* text to measure */, TextSize>> _cache = new Map<String, Map<String, TextSize>>();

  /**
   * Register text element if not already done
   */
  static void _registerTextElement() {
    if (!isTextElementRegistered) {
      isTextElementRegistered = true;
      document.registerElement('lib-extent-text-element', TextElement);
    }
  }

  /**
   * Create text element with specified CSS font attributes and text
   */
  static TextElement _getTextElement(String text, String font) {
    TextElement textElement = document.createElement("lib-extent-text-element");
    textElement.text = text;
    textElement.style.font = font;
    return textElement;
  }

  /**
   * Get cache containing sizes of texts given specified CSS font property value.
   */
  static Map<String, TextSize> _getCache(String cssFontProperty) {
    Map<String, TextSize> cache = _cache[cssFontProperty];
    if (cache == null) {
      cache = new Map<String, TextSize>();
      _cache[cssFontProperty] = cache;
    }
    return cache;
  }

  /**
   * Measure specified [text] with specified CSS font property [cssFontProperty].
   *
   * For example:
   *
   *     Textent.measureText("Measure me", "15px arial,sans-serif").then((TextSize textSize) {
   *       print("My size is $textSize");
   *     });
   *
   */
  static Future<TextSize> measureText(String text, String cssFontProperty) {

    // Reference, or create if non-existent, cache relevant to specified CSS font property
    Map<String, TextSize> cache = _getCache(cssFontProperty);

    // Return cached value if available
    TextSize cachedValue = cache[text];
    if (cachedValue != null) {
      return new Future<TextSize>.value(cachedValue);
    }

    // Define completer used to generate future
    var completer = new Completer<TextSize>();

    // Ensure text elementy is registered
    _registerTextElement();

    // Add text element to DOM and wait for it to be added to DOM
    _getTextElement(text, cssFontProperty).attach().then((TextElement elementAddedToDom) {

      // Caculate text size excluding any padding, margin, border
      Rectangle clientRect = elementAddedToDom.getBoundingClientRect();
      num width = clientRect.width;
      num height = clientRect.height;

      // Create Dimension capturing dimensions
      TextSize textSize = new TextSize(width.toDouble(), height.toDouble());

      // Add result to cache
      cache[text] = textSize;

      // Complete future
      completer.complete(textSize);

      // Remove element from DOM
      elementAddedToDom.remove();
    });
    return completer.future;
  }

  /**
   * Measure specified set of [texts] with specified CSS font property [cssFontProperty].
   *
   * For example:
   *
   *     Textent.measureTexts(["Measure me", "Me too!"], "15px arial,sans-serif").then((Map<String, TextSize> textSizes) {
   *       print("Our sizes are $textSizes");
   *     });
   *
   */
  static Future<Map<String, TextSize>> measureTexts(List<String> texts, String cssFontProperty) {

    // Reference, or create if non-existent, cache relevant to specified CSS font property
    Map<String, TextSize> cache = _getCache(cssFontProperty);

    // Define completer used to generate future
    var completer;

    // Ensure text elementy is registered
    _registerTextElement();

    // Measure texts whose sizes are not yet cached
    int numMeasurementsPending = 0;
    int numTotalMeasurementsPending = 0;
    for (String text in texts) {
      TextSize cachedValue = cache[text];
      if (cachedValue == null) {

        // Create completer used to return future to be completed once all new texts have been measured
        if (completer == null) {
          completer = new Completer<Map<String, TextSize>>();
        }

        // Increment counter tracking number of pending measurements
        numMeasurementsPending++;
        numTotalMeasurementsPending++;

        // Add text element to DOM and wait for it to be added to DOM
        _getTextElement(text, cssFontProperty).attach().then((TextElement elementAddedToDom) {

          // Caculate text size excluding any padding, margin, border
          Rectangle clientRect = elementAddedToDom.getBoundingClientRect();
          num width = clientRect.width;
          num height = clientRect.height;

          // Create Dimension capturing dimensions
          TextSize textSize = new TextSize(width.toDouble(), height.toDouble());

          // Add result to cache
          cache[text] = textSize;

          // Remove element from DOM
          elementAddedToDom.remove();

          // Complete future if no more pending measurements
          if (--numMeasurementsPending == 0) {
            completer.complete(cache);
          }
        });
      }
    }

    // Were all sizes in cache?
    if (numTotalMeasurementsPending == 0) {

      // Yes, return cache right away
      return new Future<Map<String, TextSize>>.value(cache);
    } else {

      // No return future that will complete once all new texts have been measured
      return completer.future;
    }
  }

}