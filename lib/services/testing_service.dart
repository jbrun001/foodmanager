// test logger used to print console information in a standard way
// allows this information to be turned off when development is complete
// when testMode is false no testing information is leaked to the console
bool testMode = true;

void testLog(String location, String description, Map<String, dynamic> data) {
  if (!testMode) return;

  String output = '[Test] $location | ';
  output += "$description  ";

  for (var entry in data.entries) {
    output += '| ${entry.key}: ${entry.value}';
  }

  print(output);
}
