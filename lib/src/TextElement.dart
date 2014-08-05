import "dart:html";
import "dart:async";

class TextElement extends HtmlElement {

  // Completer generating future used to signal element attached to DOM
  Completer<TextElement> _completer;

  TextElement.created() : super.created() {
    style.position = "absolute";
    style.visibility = "hidden";
  }

  void attached() {
    super.attached();
    _completer.complete(this);
  }

  /**
   * Attach element to DOM and return future referencing element once attached
   */
  Future<TextElement> attach() {
    _completer = new Completer<TextElement>();
    document.body.append(this);
    return _completer.future;
  }
}