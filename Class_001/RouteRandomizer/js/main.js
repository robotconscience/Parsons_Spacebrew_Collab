var app = null;

$(document).ready(function(){
	app = new RouteRandomizer();
});

var RouteRandomizer = function(){
	this.currentPub = null;
	this.currentSub = null;
	this.sb 	= null;

	this.setupSpacebrew();
}

RouteRandomizer.prototype.setupSpacebrew = function() {
	// setup with default paramz
	this.sb = new Spacebrew.Client();

	// we'll listen to a boolean to say "randomize!"
	// 1 - full random route
	this.sb.addSubscribe("doRandomize", "boolean" );
	// 2 - IF previous entry exists + it has a pub/sub, attaches its pub to random sub
	this.sb.addSubscribe("doRandomJump", "boolean" );	

	// add admin functionality
	this.sb.extend(Spacebrew.Admin);
	this.sb.onBooleanMessage = this.onBooleanMessage.bind(this);

	this.sb.onOpen = function(){
		$("#status").html("Connected");
	}
	this.sb.onClose = function(){
		$("#status").html("Disconnected");
	}

	this.typeToRandomize = getQueryString("type") == "" ? "boolean" : getQueryString("type");

	this.sb.connect();
};

RouteRandomizer.prototype.randomize = function() {
	// break old connections
	if ( this.currentSub || this.currentPub ){
		this.sb.removeRoute( this.currentPub, this.currentSub );
	}

	// get most current list
	var currentPublishers = this.sb.publishListByType(this.typeToRandomize);
	var currentSubscribers = this.sb.subscribeListByType(this.typeToRandomize);

	// remove ourselves from these lists
	for( var p in currentPublishers ){
		if ( this.sb.isThisApp(currentPublishers[p].clientName, currentPublishers[p].remoteAddress) ){
			currentPublishers.splice(currentPublishers.indexOf(p),1);
		}
	}
	for( var p in currentSubscribers ){
		if ( this.sb.isThisApp(currentSubscribers[p].clientName, currentSubscribers[p].remoteAddress) ){
			currentSubscribers.splice(currentSubscribers.indexOf(p),1);
		}
	}

	// randomize!
	var pubKeys = Object.keys(currentPublishers);
	this.currentPub = currentPublishers[pubKeys[pubKeys.length * Math.random() << 0]];

	var subKeys = Object.keys(currentSubscribers);
	this.currentSub = currentSubscribers[subKeys[subKeys.length * Math.random() << 0]];

	this.sb.addRoute( this.currentPub, this.currentSub );
	this.setHTML();
};

RouteRandomizer.prototype.randomJump = function() {
	// need to randomize if we don't have a starting point
	if ( !this.currentSub ){
		this.randomize();
		return;
	}

	// make sure our current subscriber has a publisher of our type
	var currentPublishers = this.sb.publishListByType(this.typeToRandomize);
	var currentSubscribers = this.sb.subscribeListByType(this.typeToRandomize);

	var bHasPublishers = false;
	var publisherOptions = [];

	for ( var p in currentPublishers ){
		if ( currentPublishers[p].clientName == this.currentSub.clientName &&
			 currentPublishers[p].remoteAddress == this.currentSub.remoteAddress ){
			bHasPublishers = true;
			publisherOptions.push( p );
		}
	}

	if ( !bHasPublishers || publisherOptions.length == 0 ){
		console.log( "no pubz" )
		this.randomize();
		return;
	} else {

		if ( this.currentSub || this.currentPub ){
			this.sb.removeRoute( this.currentPub, this.currentSub );
		}
		
		this.currentPub = currentPublishers[ publisherOptions[publisherOptions.length * Math.random() << 0 ] ];

		var subKeys = Object.keys(currentSubscribers);
		for ( var i=subKeys.length-1; i>=subKeys.length; i--){
			if ( subKeys[i].clientName == this.currentPub.clientName &&
				 subKeys[i].remoteAddress == this.currentPub.remoteAddress ){
				subKeys.splice(i,1);
			}
		}
		this.currentSub = currentSubscribers[subKeys[subKeys.length * Math.random() << 0]];
		this.sb.addRoute( this.currentPub, this.currentSub );
		this.setHTML();
	}

};

RouteRandomizer.prototype.setHTML = function() {
	$("#pub").html(this.currentPub.clientName+" :" +this.currentPub.name);
	$("#sub").html(this.currentSub.clientName+" :" +this.currentSub.name);
};

RouteRandomizer.prototype.onBooleanMessage = function( name, value ) {
	console.log("got boolean message!");
	if ( name == "doRandomize" && value == true){
		this.randomize();
	} else if ( name == "doRandomJump" && value == true ){
		this.randomJump();
	}
};