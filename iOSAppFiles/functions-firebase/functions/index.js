const functions = require('firebase-functions');
let admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

exports.sendPush = functions.database.ref('/SchoolData/{school}/ClassData/{classID}/Messages/{messageID}').onWrite(event => {
	let projectData = event.data.val();
	let classID = event.params.classID;
	let school = event.params.school;
	let messageType = projectData.messageType;
	let messageText = projectData.message;
	let userFirstName = projectData.userFirstName;
	let userLastName = projectData.userLastName;
	let uid = projectData.uid;
	let messageID = projectData.messageID;
	
	//finishedUserBlockStatus(userIsBlocked(uid, ""));
	
	
	if ((projectData.notificationSent !== "TRUE")) {
		var ref = event.data.ref;
		
		ref.update({
			"notificationSent": "TRUE"
		});
		createArrayOfUsersInClassID(classID , school , uid).then(users => {
			//console.log("Users: " + users);
			prepareTokenArray(users).then(tokenArrayToNotify => {
				//console.log("THIS IS THE TOKEN ARRAY: " + tokenArrayToNotify);
				if (messageType == "text") {
					let payload = {
						notification: {
							title: (''.concat(userFirstName , ' ' , userLastName)),
							body: messageText,
							sound: 'default',
							badge: '1',
							threadIdentifier: classID,
							categoryIdentifier: classID
						}
					};
					
					//console.log("Message Being Sent TO: " + tokenArrayToNotify + " with payload: " + payload);
					if (Array.isArray(tokenArrayToNotify) && tokenArrayToNotify.length) {
						console.log("Message ID: " + messageID + ", Users: " + users + "Tokens: " + tokenArrayToNotify);
						return admin.messaging().sendToDevice(tokenArrayToNotify, payload);
					}
				} else {
					let payload = {
						notification: {
							title: (''.concat(userFirstName , ' ' , userLastName)),
							body: "Photo Message",
							sound: 'default',
							badge: '1',
							threadIdentifier: classID,
							categoryIdentifier: classID
						},
						data: {
						  id: classID
						}
					};
					
					//console.log("Message Being Sent TO: " + tokenArrayToNotify + " with payload: " + payload);
					if (Array.isArray(tokenArrayToNotify) && tokenArrayToNotify.length) {
						console.log("Message ID: " + messageID + ", Users: " + users + "Tokens: " + tokenArrayToNotify);
						return admin.messaging().sendToDevice(tokenArrayToNotify, payload);
					}
				}
				
			});
		});
	}
});
	
	function finishedUserBlockStatus(result) {
		console.log("RESULTING VALUE: ".concat(result));
		return result;
	}
	
	function userIsBlocked(currentUser , blockedUser) {
		if (currentUser == blockedUser) {
			return false;
		}
		
		let refPath = "/users/".concat(currentUser).concat("/BlockedUsers");
		let blockedUsersRef = admin.database().ref(refPath);
		blockedUsersRef.once('value', (snap)=> {
			console.log("User Is Blocked once: ");
			let data = snap.val();
			console.log(data);
			var BlockedUsersArray = [];
			for (var key in data) {
				BlockedUsersArray.push(data[key]);
			}
			console.log("Array");
			console.log(BlockedUsersArray);
			console.log("Current User: ".concat(currentUser));
			if (BlockedUsersArray.includes(blockedUser)) {
				//User Blocked
				return true ;
			} else {
				//User NOT blocked
				return false;
			}
		});
	}
	
	
	
	function prepareTokenArray(users) {
		let tokenArrayToNotify = [];
		let defer = new Promise((resolve, reject) => {
			users.forEach(function(listItem, index){
				getDeviceTokenForUser(users[index]).then(token => {
					if ((token !== "DONOTINCLUDE") && (token !== "") && (token !== null) && (token)) {
						tokenArrayToNotify.push(token);
					} else {
					}
					if (index == (users.length - 1)) {
						resolve(tokenArrayToNotify);
					}
				});
			});
		}, (err) => {
			reject(err);
		});
		return defer;
	}
	
	
function getDeviceTokenForUser(userID) {
	let dbRefStr = ('/users/'.concat(userID).concat('/info'));
	let dbRef = admin.database().ref(dbRefStr);
	let defer = new Promise((resolve, reject) => {
		dbRef.once('value', (snap) => {
			let data = snap.val();
			if (data.readyToReceive == "TRUE") {
				resolve(data.pushToken);
			} else {
				resolve("DONOTINCLUDE");
			}
		}, (err) => {
			reject(err);
		});
	});
	return defer;
}


function createArrayOfUsersInClassID(classID , school , uid) {
	let dbRefString = ('/SchoolData/'.concat(school, '/classMembers/', classID));
	let dbRef = admin.database().ref(dbRefString);
	let defer = new Promise((resolve, reject) => {
		dbRef.once('value', (snap) => {
			let data = snap.val();
			var values = Object.keys(data).map(function(key){
				return data[key];
			});
			
			
			if (values.indexOf(uid) > -1) {
				//In the array!
				values.splice(values.indexOf(uid), 1);
			} else {
				//Not in the array
			}
			
			resolve(values);
		}, (err) => {
			reject(err);
		});
	});
	return defer;
}