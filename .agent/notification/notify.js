(function () {
  var title = "Codex/Claude";
  var message = "Processing completed.";
  var timeoutSeconds = 5;

  try {
    if (WScript.Arguments.length > 0) {
      var raw = WScript.Arguments.Item(WScript.Arguments.length - 1);
      var payload = JSON.parse(raw);
      if (payload && payload.type === "agent-turn-complete") {
        message = "Processing completed.";
      }
    }
  } catch (e) {
    // Ignore payload parse errors and keep the default message.
  }

  try {
    var shell = WScript.CreateObject("WScript.Shell");
    shell.Popup(message, timeoutSeconds, title, 64);
  } catch (e) {
    // Do not fail the caller if the notification cannot be displayed.
  }
})();
