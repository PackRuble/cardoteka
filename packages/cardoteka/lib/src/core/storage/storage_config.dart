// todo(11.02.2026, @PackRuble): remove
class StorageConfig {
  const StorageConfig({
    this.path,
  });

  /// Путь до файла. Null если используется SP экземпляр
  final String? path;
}
