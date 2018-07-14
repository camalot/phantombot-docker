(function () {
	var emoteTime = $.getSetIniDbNumber("emoteOnlyMode", "emoteOnlyTimer", 30);
	$.bind("twitchPrimeSubscriber", function (event) {
		changeEmotes();
	});
	$.bind("twitchReSubscriber", function (event) {
		changeEmotes();
	});
	$.bind("twitchSubscriber", function (event) {
		changeEmotes();
	});
	$.bind("twitchSubscriptionGift", function (event) {
		changeEmotes();
	});
	$.bind("twitchBits", function (event) {
		changeEmotes();
	});
	$.bind("twitchFollow", function (events) {
		changeEmotes();
	});



	/**
	 * @event command
	 */
	$.bind("command", function (event) {
		var sender = event.getSender().toLowerCase();
		var command = event.getCommand();
		var args = event.getArgs();
		var action = args[0];
		var actionArg1 = args[1];
		if (command.equalsIgnoreCase("emoteonly")) {
			changeEmotes();
			return;
		}

		/**
		 * @commandpath emotetime - Allows an admin (or higher) to change the duration (in seconds) 
		 * of the emoteonly command.
		 */
		if (command.equalsIgnoreCase("emotetime")) {
			var waitTime = parseInt(action);
			if (action === undefined || isNaN(waitTime)) {
				return;
			}

			$.inidb.set("emoteOnlyMode", "emoteOnlyTimer", waitTime);
			$.say("Emote only mode timer set to " + waitTime + " seconds.");
		}
	});

	function changeEmotes(time) {
		if ($.bot.isModuleEnabled("./emoteonly/emoteonlySystem.js")) {
			var delay = time == null ? emoteTime : time;
			$.say("Chat is now in emote only mode for the next " + emoteTime + " seconds. Get some HYPE in the chat! BloodTrail DendiFace bleedPurple KAPOW");

			$.say("/emoteonly");
			var t = setTimeout(function () {
				$.say("/emoteonlyoff");
				$.say("Chat is no longer in emote only mode. KAPOW");
			}, delay * 1e3);
		}
	}

	/**
	 * @event initReady
	 */
	$.bind("initReady", function () {
		if ($.bot.isModuleEnabled("./emoteonly/emoteonlySystem.js")) {
			$.registerChatCommand("./emoteonly/emoteonlySystem.js", "emoteonly", 2);
			$.registerChatCommand("./emoteonly/emoteonlySystem.js", "emotetime", 2);
		}
	});
})();
