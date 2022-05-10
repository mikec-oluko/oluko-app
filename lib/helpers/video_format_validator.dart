class VideoFormatValidator {
  static List<String> videoFormats = ['.3gpp', '.mp4', '.webm', '.mov', '.m4v'];
  static bool formatValidator(String extension) {
    bool existe = videoFormats.contains(extension);
    return existe;
  }
}
