var keyMapping = [
	["right", [39]],
	["left", [37]],
	["up", [38]],
	["down", [40]],
	["a", [88, 74]],
	["b", [90, 81, 89]],
	["select", [16]],
	["start", [13]]
];

function cout(text) {
	console.log(text);
}

function handleKeyPress(e, callback) {
	var keyCode = e.keyCode;
	var keyMapLength = keyMapping.length;
	for (var keyMapIndex = 0; keyMapIndex < keyMapLength; ++keyMapIndex) {
		var keyCheck = keyMapping[keyMapIndex];
		var keysMapped = keyCheck[1];
		var keysTotal = keysMapped.length;
		for (var index = 0; index < keysTotal; ++index) {
			if (keysMapped[index] == keyCode) {
				callback(keyCheck[0]);
				try {
					e.preventDefault();
				}
				catch (error) { }
			}
		}
	}
}

function updateStatus(text) {
	document.getElementById("status").innerText = text;
}

window.addEventListener("load", function() {
	updateStatus("Downloading game...");

	var romRequest = new XMLHttpRequest();
	romRequest.overrideMimeType('text\/plain; charset=x-user-defined');
	romRequest.addEventListener("load", function() {
		document.getElementById("status").style.display = "none";
		start(document.querySelector("canvas"), romRequest.responseText);
	});
	romRequest.open("GET", "game.gb");
	romRequest.send();
});

window.addEventListener("keydown", function(e) {
	handleKeyPress(e, GameBoyKeyDown);
});

window.addEventListener("keyup", function(e) {
	handleKeyPress(e, GameBoyKeyUp);
});