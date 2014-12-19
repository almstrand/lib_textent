library textent;

import 'src/TextElement.dart';

import 'dart:async';
import 'dart:html';

part 'src/TextSize.dart';

class Textent {

  // Tracks whether custom element is registered to ensure it is only done once
  static bool isTextElementRegistered = false;

  // Cache of sizes of previously measured texts given various CSS font properties. TODO: support clearing cache and/or individual entries
  static final Map<String /* CSS styles */, Map<String /* text to measure */, TextSize>> _cache = new Map<String, Map<String, TextSize>>();

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
  static TextElement _getTextElement(String text, String font, String maxWidth) {
    TextElement textElement = new Element.tag('lib-extent-text-element');
    textElement.text = text;
    textElement.style.font = font;
    return textElement;
  }

  /**
   * Get cache containing sizes of texts given specified CSS font and max-width property values.
   */
  static Map<String, TextSize> _getCache(String cssFontProperty, String cssMaxWidthProperty) {
    String key = "font:$cssFontProperty;${(cssMaxWidthProperty == null ? "" : "max-width:$cssMaxWidthProperty")}";
    Map<String, TextSize> cache = _cache[key];
    if (cache == null) {
      cache = new Map<String, TextSize>();
      _cache[key] = cache;
    }
    return cache;
  }

  /**
   * Measure specified [text] with specified CSS font property [cssFontProperty]. The optional [cssMaxWidthProperty]
   * parameter can be used to specify the CSS width property of a containing element such that the text will wrap if
   * extending beyond the specified width.
   *
   * For example:
   *
   *     Textent.measureText("Measure me", "15px arial,sans-serif", cssMaxWidthProperty: "100px")
   *     .then((TextSize textSize) {
   *       print("My size is $textSize");
   *     });
   *
   */
  static Future<TextSize> measureText(String text, String cssFontProperty, {String cssMaxWidthProperty: null}) {

    // Reference, or create if non-existent, cache relevant to specified CSS font property
    Map<String, TextSize> cache = _getCache(cssFontProperty, cssMaxWidthProperty);

    // Return cached value if available
    TextSize cachedValue = cache[text];
    if (cachedValue != null) {
      return new Future<TextSize>.value(cachedValue);
    }

    // Completer used to generate future
    Completer<TextSize> completer = new Completer<TextSize>();

    // Ensure text element is registered
    _registerTextElement();

    // Create container div if max width is specified
    Element containerElement;
    if (cssMaxWidthProperty == null) {
      containerElement = document.body;
    }
    else {
      containerElement = new DivElement();
      containerElement.style
        ..position = "absolute"
        ..width = cssMaxWidthProperty;
      document.body.append(containerElement);
    }

    // Add text element to DOM and wait for it to be added to DOM
    _getTextElement(text, cssFontProperty, cssMaxWidthProperty).attach(containerElement).then((TextElement elementAddedToDom) {

      // Calculate text size excluding any padding, margin, border
      num width = elementAddedToDom.offsetWidth;
      num height = elementAddedToDom.offsetHeight;

      // Create Dimension capturing dimensions
      TextSize textSize = new TextSize(width.toDouble(), height.toDouble());

      // Add result to cache
      cache[text] = textSize;

      // Complete future
      completer.complete(textSize);

      // Remove element from DOM
      if (cssMaxWidthProperty == null) {
        elementAddedToDom.remove();
      }
      else {
        containerElement.remove();
      }
    });
    return completer.future;
  }

  /**
   * Measure specified set of [texts] with specified CSS font property [cssFontProperty]. The optional
   * [cssMaxWidthProperty] parameter can be used to specify the CSS width property of a containing element such that the
   * text will wrap if extending beyond the specified width.
   *
   * For example:
   *
   *     Textent.measureTexts(["Measure me", "Me too!"], "15px arial,sans-serif", cssMaxWidthProperty: "100px")
   *     .then((Map<String, TextSize> textSizes) {
   *       print("Our sizes are $textSizes");
   *     });
   *
   */
  static Future<Map<String, TextSize>> measureTexts(List<String> texts, String cssFontProperty, {String cssMaxWidthProperty: null}) {

    // Reference, or create if non-existent, cache relevant to specified CSS font property
    Map<String, TextSize> cache = _getCache(cssFontProperty, cssMaxWidthProperty);

    // Completer used to generate future
    Completer<Map<String, TextSize>> completer;

    // Ensure custom text element is registered
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

        // Create container div if max width is specified
        Element containerElement;
        if (cssMaxWidthProperty == null) {
          containerElement = document.body;
        }
        else {
          containerElement = new DivElement();
          containerElement.style
            ..position = "absolute"
            ..width = cssMaxWidthProperty;
          document.body.append(containerElement);
        }

        // Add text element to DOM and wait for it to be added to DOM
        _getTextElement(text, cssFontProperty, cssMaxWidthProperty).attach(containerElement).then((TextElement elementAddedToDom) {

          // Calculate text size excluding any padding, margin, border
          Rectangle clientRect = elementAddedToDom.getBoundingClientRect();
          num width = clientRect.width;
          num height = clientRect.height;

          // Create Dimension capturing dimensions
          TextSize textSize = new TextSize(width.toDouble(), height.toDouble());

          // Add result to cache
          cache[text] = textSize;

          // Remove element from DOM
          if (cssMaxWidthProperty == null) {
            elementAddedToDom.remove();
          }
          else {
            containerElement.remove();
          }

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