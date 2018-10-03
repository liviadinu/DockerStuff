const http = require("http"),
      url = require("url"),
      path = require("path"),
      fs = require("fs"),

      port = process.argv[2] || 8050,
      basedir = process.cwd();

http.createServer(function(request, response) {

	var uri = url.parse(request.url, true);
    var filename = path.join(basedir, uri.pathname);

	var contentTypesByExtension = {
		'.html': "text/html",
		'.css':  "text/css",
		'.js':   "text/javascript"
	};

	if (request.method == 'GET') {
		var item = uri.pathname.slice(1);
		fs.exists(filename, function(exists) {
			if(!exists) {
				console.log(uri);	
				console.log('not found: '+filename);  
				response.writeHead(404, {"Content-Type": "text/plain"});
				response.write("404 Not Found\n");
				response.end();
				return;
			}

			if (fs.statSync(filename).isDirectory()) filename += '/index.html';

			fs.readFile(filename, "binary", function(err, file) {
				if(err) {        
				response.writeHead(500, {"Content-Type": "text/plain"});
				response.write(err + "\n");
				response.end();
				return;
				}

				var headers = {};
				var contentType = contentTypesByExtension[path.extname(filename)];
				if (contentType) headers["Content-Type"] = contentType;
				response.writeHead(200, headers);
				response.write(file, "binary");
				response.end();
			});
		});
	};

	if (request.method == "POST") {
		var body = '';

		request.on('data', function (data) {
				body += data;

				// Too much POST data, kill the connection!
				// 1e6 === 1 * Math.pow(10, 6) === 1 * 1000000 ~~~ 1MB
				if (body.length > 1e6)
						request.connection.destroy();
		});

		request.on('end', function () {
			if (uri == '/notes') {
				fs.writeFile(filename+'.json', body, function(err) {
					if(err) {  
						console.log(err);      
					}
	
				});
			};
				//	var post = qs.parse(body);
				// use post['blah'], etc.
				//response.writeHead(200, {});
				response.end();

		});		
	}

}).listen(parseInt(port, 10));

console.log("Static file server running at\n  => http://localhost:" + port + "/\nCTRL + C to shutdown");