enum FileTypeEnum { video, image, pdf }

FileTypeEnum getFileTypeEnumFromString(String str) {
  return FileTypeEnum.values.firstWhere((e) => (e?.toString() == 'FileTypeEnum.' + str) || (e?.toString() == str), orElse: () => null);
}
