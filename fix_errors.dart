import 'dart:io';

void main() {
  final analyzeOutput = File('analyze_output.txt').readAsLinesSync();
  final fileFixes = <String, List<int>>{};
  
  for (var line in analyzeOutput) {
    if (line.contains('invalid_constant') || line.contains('non_constant_list_element')) {
      var parts = line.split(' • ');
      if (parts.length >= 3) {
        var filePath = parts[2].split(':').first;
        var lineNumStr = parts[2].split(':')[1];
        var lineNum = int.tryParse(lineNumStr);
        if (filePath != null && lineNum != null && fileFixes[filePath]?.contains(lineNum) != true) {
          fileFixes.putIfAbsent(filePath, () => []).add(lineNum);
        }
      }
    }
  }

  for (var entry in fileFixes.entries) {
    var file = File(entry.key);
    if (!file.existsSync()) continue;
    var lines = file.readAsLinesSync();
    
    for (var ln in entry.value) {
      int idx = ln - 1;
      for (int i = idx; i >= 0 && i >= idx - 5; i--) {
        if (lines[i].contains('const ')) {
          lines[i] = lines[i].replaceFirst('const ', '');
          break;
        }
      }
    }
    file.writeAsStringSync(lines.join('\n'));
  }

  var screens = Directory('lib/screens').listSync().whereType<File>();
  for (var file in screens) {
    if (!file.path.endsWith('.dart')) continue;
    var c = file.readAsStringSync();
    if (c.contains('class _HomeScreenState extends State<HomeScreen> {') && !c.contains('AppColors get colors => AppColors(context);')) {
       c = c.replaceFirst('class _HomeScreenState extends State<HomeScreen> {', 'class _HomeScreenState extends State<HomeScreen> {\n  AppColors get colors => AppColors(context);');
    }
    if (c.contains('class _SettingsScreenState extends State<SettingsScreen> {') && !c.contains('AppColors get colors => AppColors(context);')) {
       c = c.replaceFirst('class _SettingsScreenState extends State<SettingsScreen> {', 'class _SettingsScreenState extends State<SettingsScreen> {\n  AppColors get colors => AppColors(context);');
    }
    if (c.contains('class _LogsScreenState extends State<LogsScreen> {') && !c.contains('AppColors get colors => AppColors(context);')) {
       c = c.replaceFirst('class _LogsScreenState extends State<LogsScreen> {', 'class _LogsScreenState extends State<LogsScreen> {\n  AppColors get colors => AppColors(context);');
    }
    if (file.path.contains('specs_screen.dart')) {
       if (!c.contains('AppColors colors, String header')) {
         c = c.replaceAll('_buildDetailItem(', '_buildDetailItem(colors, ');
         c = c.replaceAll('Widget _buildDetailItem(colors, String header', 'Widget _buildDetailItem(AppColors colors, String header');
       }
       if (!c.contains('AppColors colors, IconData icon')) {
         c = c.replaceAll('_buildTag(', '_buildTag(colors, ');
         c = c.replaceAll('Widget _buildTag(colors, IconData icon', 'Widget _buildTag(AppColors colors, IconData icon');
       }
    }
    file.writeAsStringSync(c);
  }
}
