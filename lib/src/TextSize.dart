part of textent;

class TextSize {
  double width;
  double height;

  TextSize(double this.width, double this.height);

  bool operator == (TextSize size) {
    return size != null && height == size.height && width == size.width;
  }

  String toString() {
    return "$width x $height";
  }
}