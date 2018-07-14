/**
 * topCommand.js
 *
 * Build and announce lists of top viewers (Highest points)
 */
(function () {
	var bots = $.readFile("./addons/ignorebots.txt");
	var amountPoints = $.getSetIniDbNumber("settings", "topListAmountPoints", 5);

	/*
	 * @function reloadTop
	 */
	function reloadTop() {
		amountPoints = $.getIniDbNumber("settings", "topListAmountPoints");
	}

	/*
	 * @function isTwitchBot
	 * @param {string} username
	 * @returns {Boolean}
	 */
	function isTwitchBot(username) {
		var i;
		for (i in bots) {
			if (bots[i].equalsIgnoreCase(username)) {
				return true;
			}
		}
		return false;
	}

	/*
	 * @function getTop
	 *
	 * @returns {Array}
	 */
	function getTop( count ) {
		var topCount = isNaN(count) ? amountPoints : count;
		if ( topCount < 1 ) {
			topCount = 1;
		} else if ( topCount > 10 ) {
			topCount = 10;
		}

		var keys = $.inidb.GetKeysByNumberOrderValue("points", "", "DESC", (topCount + bots.length + 1), 0);
		var list = [];
		var i;
		for (i in keys) {
			if (!$.isBot(keys[i]) && !$.isOwner(keys[i]) && !isTwitchBot(keys[i])) {
				list.push({
					username: keys[i],
					value: $.inidb.get("points", keys[i])
				});
			}
		}

		list.sort(function (a, b) {
			return (b.value - a.value);
		});

		return list.slice(0, topCount);
	}

	/*
	 * @event command
	 */
	$.bind("command", function (event) {
		var command = event.getCommand();
		var args = event.getArgs();
		var sender = event.getSender();
		var action = args[0] || "5";
		var i;
		/**
		 * @commandpath top - Display the top people with the most points
		 */
		if (command.equalsIgnoreCase("top")) {
			if (!$.bot.isModuleEnabled("./systems/pointSystem.js")) {
				return;
			}

			var topCount = parseInt(action);
			var temp = getTop(topCount);
			var top = [];
			for (i in temp) {
				top.push((parseInt(i) + 1) + ") " + $.resolveRank(temp[i].username) + " " + $.getPointsString(temp[i].value));
			}
			$.say($.lang.get("top5.default", topCount, $.pointNameMultiple, top.join(", ")));

			return;
		}
	});

	/**
	 * @event initReady
	 */
	$.bind("initReady", function () {
		if ($.bot.isModuleEnabled("./points/topSystem.js")) {
			$.registerChatCommand("./points/topSystem.js", "top", 7);
		}
	});
})();
