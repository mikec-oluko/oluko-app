class VideoFormatValidator {
  static List<String> videoFormats = ['.3gpp', '.mp4', '.webm', '.mov', '.m4v'];
  static bool formatValidator(String extension) {
    return videoFormats.contains(extension.toLowerCase());
    
  }
}
