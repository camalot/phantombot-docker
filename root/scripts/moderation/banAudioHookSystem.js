(function () {
	var banHook = $.getSetIniDbString("moderationAlerts", "banHook", "goaway");
	var timeoutHook = $.getSetIniDbString("moderationAlerts", "timeoutHook", "shhhh");
	var purgeHook = $.getSetIniDbString("moderationAlerts", "purgeHook", "purge");
	var purgeTime = $.getSetIniDbNumber("moderationAlerts", "purgeTime", 5);
	var availableHooks = ["ban", "timeout", "purge"];
	var purgeHookEnabled = $.getSetIniDbBoolean("moderationAlerts", "purgeHookEnabled", true);
	var timeoutHookEnabled = $.getSetIniDbBoolean("moderationAlerts", "timeoutHookEnabled", true);
	var banHookEnabled = $.getSetIniDbBoolean("moderationAlerts", "banHookEnabled", true);
	// https://community.phantombot.tv/t/bind-twitch-moderation-events-like-ban-timeout/4478
	// The events here are only triggered if you enable moderation logs to discord.
	// if you don't use discord, you will need to run this once to force the events to trigger for ban/timeout.
	// $.inidb.set('chatModerator', 'moderationLogs', 'true');
	$.bind("PubSubModerationBan", function (event) {
		var username = event.getUsername();
		var reason = event.getReason();
		var creator = event.getCreator();
		var message = event.getMessage();
		try {
			banHookEnabled = $.getIniDbBoolean("moderationAlerts", "banHookEnabled");
			if (!banHookEnabled) {
				return;
			}
			if ($.inidb.exists("audioCommands", banHook)) {
				$.panelsocketserver.triggerAudioPanel($.inidb.get("audioCommands", banHook));
				return;
			} else {
				$.say($.whisperPrefix(sender) + "Unable to play ban hook");
			}
		} catch (e) {
			$.say($.whisperPrefix(sender) + e);
		}
	});

	$.bind("PubSubModerationTimeout", function (event) {
		var username = event.getUsername();
		var reason = event.getReason();
		var creator = event.getCreator();
		var message = event.getMessage();
		var time = event.getTime();
		try {
			purgeHookEnabled = $.getIniDbBoolean("moderationAlerts", "purgeHookEnabled");
			timeoutHookEnabled = $.getIniDbBoolean("moderationAlerts", "timeoutHookEnabled");
			if (purgeHookEnabled && time <= purgeTime) {
				// purge
				if ($.inidb.exists("audioCommands", purgeHook)) {
					$.panelsocketserver.triggerAudioPanel($.inidb.get("audioCommands", purgeHook));
					return;
				} else {
					$.say($.whisperPrefix(sender) + "Unable to play purge hook");
				}
			} else {
				if (!timeoutHookEnabled) {
					return;
				}
				if ($.inidb.exists("audioCommands", timeoutHook)) {
					$.panelsocketserver.triggerAudioPanel(
						$.inidb.get("audioCommands", timeoutHook)
					);
					return;
				} else {
					$.say($.whisperPrefix(sender) + "Unable to play timeout hook");
				}
			}
		} catch (e) {
			$.say($.whisperPrefix(sender) + e);
		}
	});

	/**
	 * @event command
	 */
	$.bind("command", function (event) {
		var sender = event.getSender().toLowerCase();
		var command = event.getCommand();
		var args = event.getArgs();
		var action = args[0];
		var subAction = args[1];
		if (command.equalsIgnoreCase("banhook")) {
			setBanHook(sender, action);
			return;
		}

		if (command.equalsIgnoreCase("timeouthook")) {
			setTimeoutHook(sender, action);
			return;
		}
		if (command.equalsIgnoreCase("purgehook")) {
			setPurgeHook(sender, action);
			return;
		}
		if (command.equalsIgnoreCase("purgetime")) {
			var purgeSeconds = parseInt(action);
			setPurgeTime(sender, purgeSeconds);
			return;
		}
		if (command.equalsIgnoreCase("enablehook")) {
			try {
				$.say(availableHooks.indexOf(hook.toLowerCase()));
				var hook = action;
				var hookName = hook.toLowerCase() + "Hook";
				if (hook != null && hook != "") {
					if (subAction != null && subAction != "") {
						state = subAction.toLowerCase();
						var isEnabled = (state == "true" || state == 1 || state == true || state == "yes" || state == "1");
						if (availableHooks.indexOf(hook.toLowerCase()) >= 0) {
							setHookEnabled(sender, hookName, isEnabled);
							$.say($.whisperPrefix(sender) + "Set " + action + " hook enabled: " + isEnabled);
						} else {
							$.say($.whisperPrefix(sender) + "Cannot find " + hook + " hook");
						}
					} else {
						var currentState = $.getIniDbBoolean("moderationAlerts", hookName + "Enabled");
						$.say($.whisperPrefix(sender) + hook + " hook enabled is: " + currentState);
					}
				}
				return;
			} catch (e) {
				$.say($.whisperPrefix(sender) + e);
			}
		}
	});

	/**
	 * @event initReady
	 */
	$.bind("initReady", function () {
		if ($.bot.isModuleEnabled("./moderation/banAudioHookSystem.js")) {
			$.registerChatCommand("./moderation/banAudioHookSystem.js", "banhook", 2);
			$.registerChatCommand("./moderation/banAudioHookSystem.js", "timeouthook", 2);
			$.registerChatCommand("./moderation/banAudioHookSystem.js", "purgehook", 2);
			$.registerChatCommand("./moderation/banAudioHookSystem.js", "purgetime", 2);
			$.registerChatCommand("./moderation/banAudioHookSystem.js", "enablehook", 2);
		}
	});

	function setPurgeTime(sender, time) {
		if (time == null || isNaN(time)) {
			$.say($.whisperPrefix(sender) + "The purge time is " + purgeTime + " seconds.");
			return;
		}
		$.setIniDbNumber("moderationAlerts", "purgeTime", time);
		purgeTime = time;
		$.say($.whisperPrefix(sender) + "I have set the purge time to " + purgeTime + " seconds.");
		return;
	}

	function setHookEnabled(sender, name, state) {
		$.setIniDbBoolean("moderationAlerts", name + "Enabled", state);
		return state;
	}

	function setActionHook(sender, name, clip, defaultValue) {
		var audioClip = clip;

		if (audioClip == null || audioClip.length == 0) {
			$.say($.whisperPrefix(sender) + name + " clip is '!" + defaultValue + "'.");
			return;
		}

		if (!$.inidb.exists("audioCommands", audioClip)) {
			$.say($.whisperPrefix(sender) + "Unable to set the " + name + " to '" + audioClip + "' since that is not a valid clip.");
			return;
		}
		$.setIniDbString("moderationAlerts", name, audioClip);
		purgeHook = audioClip;
		$.say($.whisperPrefix(sender) + "I have set the " + name + " to '" + audioClip + "'.");

		return;
	}

	function setPurgeHook(sender, clip) {
		setActionHook(sender, "purgeHook", clip, purgeHook);
	}

	function setTimeoutHook(sender, clip) {
		setActionHook(sender, "timeoutHook", clip, timeoutHook);
	}

	function setBanHook(sender, clip) {
		setActionHook(sender, "banHook", clip, banHook);
	}
})();
