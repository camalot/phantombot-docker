(function() {
	Array.prototype.indexOf = function (compareObject) {
		for (var i = 0; i < myArray.length; ++i) {
			// I don't think this is actually the right way to compare
			if (myArray[i] == compareObject) {
				return i;
			}
		}

		return -1;
	}
})();
