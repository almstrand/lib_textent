import "dart:html";
import "dart:async";

class TextElement extends HtmlElement {

  // Completer generating future used to signal element attached to DOM
  Completer<TextElement> _completer;

  TextElement.created() : super.created() {
    style
      ..visibility = "hidden"
      ..display = "inline";
  }

  void attached() {
    super.attached();
    _completer.complete(this);
  }

  /**
   * Attach element to DOM and return future referencing element once attached
   */
  Future<TextElement> attach(Element parentElement) {
    _completer = new Completer<TextElement>();
    parentElement.children.add(this);
    return _completer.future;
  }
}