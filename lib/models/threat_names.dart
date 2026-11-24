/// Single mapping table for threat codes as specified in the test requirements
const Map<String, String> threatNames = {
  'ROOT_DETECTED': 'Rooted device',
  'JAILBREAK_DETECTED': 'Jailbroken iPhone',
  'HOOKING_FRAMEWORK': 'Hooking tool (like Frida)',
  'SCREEN_OVERLAY': 'Screen overlay',
  'APP_TAMPERED': 'App was modified',
  'EMULATOR': 'Running on an emulator',
  'DEBUGGER_ATTACHED': 'Debugger attached',
};

/// Helper function: returns mapped friendly name, or the raw code if not found
String getThreatDisplayName(String code) {
  return threatNames[code] ?? code;
}
