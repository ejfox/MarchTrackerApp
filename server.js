//setup Dependencies
var connect = require('connect')
    , express = require('express')
    , io = require('socket.io')
    , mustache = require('mustache')
	, underscore = require('underscore')
    , port = (process.env.PORT || 8081);
    
require('moment');


var databaseUrl = "marchtrackertest"; // "username:password@example.com/mydb"
var db = require("mongojs").connect(databaseUrl, ['marchtrackertest']);    
    
var tmpl = {
    compile: function (source, options) {
        if (typeof source == 'string') {
            return function(options) {
                options.locals = options.locals || {};
                options.partials = options.partials || {};
                if (options.body) // for express.js > v1.0
                    locals.body = options.body;
                return mustache.to_html(
                    source, options.locals, options.partials);
            };
        } else {
            return source;
        }
    },
    render: function (template, options) {
        template = this.compile(template, options);
        return template(options);
    }
};    

//Setup Express
var server = express.createServer();
server.configure(function(){
    server.set('views', __dirname + '/views');
    server.set('view options', { layout: false });
    server.use(connect.bodyParser());
    server.use(express.cookieParser());
    server.use(express.session({ secret: "shhhhhhhhh!"}));
    server.use(connect.static(__dirname + '/static'));
    server.use(server.router);
    server.register(".html", tmpl)
});

//setup the errors
server.error(function(err, req, res, next){
    if (err instanceof NotFound) {
        res.render('404.jade', { locals: { 
                  title : '404 - Not Found'
                 ,description: ''
                 ,author: ''
                 ,analyticssiteid: 'XXXXXXX' 
                },status: 404 });
    } else {
        res.render('500.jade', { locals: { 
                  title : 'The Server Encountered an Error'
                 ,description: ''
                 ,author: ''
                 ,analyticssiteid: 'XXXXXXX'
                 ,error: err 
                },status: 500 });
    }
});
server.listen( port);

//Setup Socket.IO
var io = io.listen(server);
io.sockets.on('connection', function(socket){
  console.log('Client Connected');
  socket.on('message', function(data){
    socket.broadcast.emit('server_message',data);
    socket.emit('server_message',data);
  });
  socket.on('disconnect', function(){
    console.log('Client Disconnected.');
  });
});


///////////////////////////////////////////
//              Routes                   //
///////////////////////////////////////////

/////// ADD ALL YOUR ROUTES HERE  /////////

server.get('/', function(req,res){
    
    var eventid = 4
    
    if(req.query['eventid'] != null && req.query['eventid'] != undefined) {
        eventid = req.query['eventid'];
    }
    
    res.render("index.html", {
            locals: {
                eventnumber: eventid
            }
    })
});

server.get('/newevent', function(req,res){
    console.log("new event");
    
    var eLocation = req.query['location'],
        eTime = req.query['time'],
        eDescription = req.query['shortdescription'],
        eImage = req.query['imageurl']
        ,eID = req.query['eventid']
        
    parsetime = Date.parse(eTime);
    
    console.log("ETIME!", eTime);
    
    
        
    db.marchtrackertest.save({
        eventid: eID,
        location: eLocation,
        time: parsetime//.toString('dddd, MMMM d, yyyy'),
        ,
        text: eDescription,
        img: eImage
    })    
    
    res.render("index.html", {
            locals: {
                eventadded: true,
                eventaddedtext: "Event added!",
                location: eLocation,
                time: eTime,
                description: eDescription,
                imageurl: eImage,
                eventnumber: eID
            }
    })
});

server.get('/listevents', function(req,res){
	var allresults = [];
        
    var eventID = 4
    
    if(req.query['eventid'] != null && req.query['eventid'] != undefined) {
        eventID = req.query['eventid'];
    }
        
//    var results = db.marchtrackertest.find({eventid: eventID}, function(error, result){	
    var results = db.marchtrackertest.find({eventid: eventID}, function(error, result){	
//        res.set('Access-Control-Allow-Origin',"*")
		console.log(">",error, result)		
		res.send(result);
	})
	

});

//A Route for Creating a 500 Error (Useful to keep around)
server.get('/500', function(req, res){
    throw new Error('This is a 500 Error');
});

//The 404 Route (ALWAYS Keep this as the last route)
server.get('/*', function(req, res){
    throw new NotFound;
});

function NotFound(msg){
    this.name = 'NotFound';
    Error.call(this, msg);
    Error.captureStackTrace(this, arguments.callee);
}


console.log('Listening on http://0.0.0.0:' + port );
