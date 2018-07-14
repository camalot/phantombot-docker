(function() {

	var defaultWinsType = $.getSetIniDbString("fortnitewins", "wintype", "all");
	var epicName = $.getSetIniDbString("fortnitewins", "epicname", "darthminos");

	// function getGameType(value) {
	// 	var valid = [ "all", "solo", "duo", "squad" ];
	// 	var key = (value || defaultWinsType).toLowerCase();
	// 	var index = valid.indexOf(key);
	// 	if(index >= 0) {
	// 		return valid[index];
	// 	} else {
	// 		return valid[0];
	// 	}
	// }

	// function getGameTypeName(value) {
	// 	var key = (value || defaultWinsType).toLowerCase();
	// 	var valid = { "all": "All", "solo": "Solos", "duo" : "Duos", "squad" : "Squads" };
	// 	if (valid[key]) {
	// 		return valid[key];
	// 	} else {
	// 		return valid.all;
	// 	}
	// }

	$.bind("command", function (event) {
		var sender = event.getSender();
		var command = event.getCommand();
		var args = event.getArgs();
		var action = args[0];

		if (command.equalsIgnoreCase("wins")) {
			var user = $.username.resolve($.channelName);
			var game = $.getGame($.channelName);
			//var gameType = getGameType(action);
			//var gameTypeName = getGameTypeName(action);
			//if ( game.equalsIgnoreCase("fortnite") ) {
				var HttpRequest = Packages.com.gmt2001.HttpRequest;
				var HashMap = Packages.java.util.HashMap;
				var h = new HashMap(1);
				var r = HttpRequest.getData(HttpRequest.RequestType.GET, "http://obs-gamestats.herokuapp.com/api/fortnite/pc/darthminos/all?fields=wins|matches", "", h);

				var data = JSON.parse(r.content);
				$.say(user + " -> " + $.channelName + " has " + data[0].display + " wins out of " + data[1].display + " matches played.Yeah.Not the best, but always working at improving.");
			//}
			return;
		}
	});

	$.bind("initReady", function () {
		if ($.bot.isModuleEnabled("./fortnite/fortniteSystem.js")) {
			$.registerChatCommand("./fortnite/fortniteSystem.js", "wins", 7);
		}
	});
})();
