(function () {
	$.bind("command", function (event) {
		var sender = event.getSender();
		var command = event.getCommand();
		var args = event.getArgs();
		var action = args[0];

		if (command.equalsIgnoreCase("marker")) {
			$.say("/marker");
			$.say($.whisperPrefix(sender) + "I have added a marker to the video.");
		}
	});

	$.bind("initReady", function () {
		if ($.bot.isModuleEnabled("./marker/markerCommand.js")) {
			$.registerChatCommand("./marker/markerCommand.js", "marker", 2);
		}
	});
})();
