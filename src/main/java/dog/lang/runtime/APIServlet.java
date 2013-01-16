package dog.lang.runtime;

import dog.lang.Runtime;
import dog.lang.StackFrame;

import com.mongodb.DBObject;
import com.mongodb.BasicDBObject;
import org.bson.types.ObjectId;
import org.json.JSONObject;
import org.json.JSONException;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.*;

import java.io.StringWriter;
import java.io.StringReader;
import java.util.regex.Pattern;
import java.util.regex.Matcher;
import java.util.ArrayList;
import java.util.Arrays;

import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.servlet.*;
import org.eclipse.jetty.server.handler.ResourceHandler;
import org.eclipse.jetty.server.handler.HandlerList;
import org.eclipse.jetty.server.Handler;
import org.eclipse.jetty.server.handler.DefaultHandler;

import org.apache.commons.io.FilenameUtils;

//import ro.isdc.wro.model.resource.processor.impl.js.JSMinProcessor;

public class APIServlet extends HttpServlet {

	public Runtime runtime;
	public String prefix;
	public String filePath;

	public String dogJS;

	Pattern ACCOUNT_STATUS;
	Pattern ACCOUNT_LOGIN;
	Pattern ACCOUNT_LOGOUT;
	Pattern DOG_JS;
	Pattern FRAME_GET;
	Pattern FRAME_POST;

	public APIServlet(Runtime runtime, String prefix, String filePath) {
		this.runtime = runtime;
		this.prefix = FilenameUtils.normalize("/" + prefix);
		this.filePath = filePath;

		ACCOUNT_STATUS = Pattern.compile(String.format("^%s/account/status$", this.prefix));
		ACCOUNT_LOGIN = Pattern.compile(String.format("^%s/account/login$", this.prefix));
		ACCOUNT_LOGOUT = Pattern.compile(String.format("^%s/account/logout$", this.prefix));
		DOG_JS = Pattern.compile(String.format("^%s/dog.js$", this.prefix));
		FRAME_GET = Pattern.compile(String.format("^%s/frame/([a-zA-Z0-9]+)$", this.prefix));
		FRAME_POST = Pattern.compile(String.format("^%s/frame/([a-zA-Z0-9]+)/([a-zA-Z0-9]+)$", this.prefix));

		this.dogJS = "";

		ArrayList<String> files = new ArrayList<String>(Arrays.asList("jquery.js", "json2.js", "handlebars.js", "dog-base.js"));
		for(String file : files) {
			String contents = dog.util.Helper.readResource("/dog/server/javascripts/" + file);
			this.dogJS += "\n\n\n" + contents;
		}

		/* TODO: Get this to work...
		JSMinProcessor processor = new JSMinProcessor();
		StringWriter output = new StringWriter();
		StringReader input = new StringReader(this.dogJS);

		processor.process(input, output);
		this.dogJS = output.toString();
		*/
	}

	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		String requestPath = req.getPathInfo();
		String output = null;
		Matcher match = null;

		if((match = ACCOUNT_STATUS.matcher(requestPath)).matches()) {
			output = "Account Status!";
		} else if((match = ACCOUNT_LOGIN.matcher(requestPath)).matches()) {
			output = "Account Login!";
		} else if((match = ACCOUNT_LOGOUT.matcher(requestPath)).matches()) {
			output = "Account Logout!";
		} else if((match = FRAME_GET.matcher(requestPath)).matches()) {
			String id = match.group(1);

			// TODO: Remove this as well and move to the constructor.
			StackFrame frame = new StackFrame();
			frame.setRuntime(runtime);

			Boolean found = false;
			if(id.equals("root")) {
				found = frame.findOne(new BasicDBObject("symbol_name", runtime.getStartUpSymbol()));
			} else {
				found = frame.findOne(new BasicDBObject("_id", new ObjectId(id)));
			}

			if(found) {
				JSONObject object = new JSONObject();
				try {
					object.put("original_frame", Helper.stackFrameAsJsonForAPI(frame));
					object.put("frame", Helper.stackFrameAsJsonForAPI(frame));	
				} catch(JSONException e) {
					System.out.println(e);
				}
				
				output = object.toString();
			} else {
				resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
			}
		} else if((match = DOG_JS.matcher(requestPath)).matches()) {
			resp.setContentType("application/javascript");
			resp.getWriter().println(this.dogJS);
			return;
		} else {
			resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
			return;
		}

		resp.setContentType("application/json");
		resp.getWriter().println(output);
	}

	protected void goPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		String requestPath = req.getPathInfo();
		String output = null;
		Matcher match = null;

		if((match = FRAME_POST.matcher(requestPath)).matches()) {
			String id = match.group(1);
			String variable = match.group(2);

			// TODO: Remove this as well and move to the constructor.
			StackFrame frame = new StackFrame();
			frame.setRuntime(runtime);

			Boolean found = false;
			if(id.equals("root")) {
				found = frame.findOne(new BasicDBObject("symbol_name", runtime.getStartUpSymbol()));
			} else {
				found = frame.findOne(new BasicDBObject("_id", new ObjectId(id)));
			}

			if(found) {

			} else {
				resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
				return;
			}
		}

		resp.setContentType("application/json");
		resp.getWriter().println(output);


/*

		post prefix + '/track/:id/:variable' do |id, variable|
          if id == "root" then
            track = ::Dog::Track.root
          else
            track = ::Dog::Track.find_by_id(id)
          end

          if track.nil? || (!track.is_root? && track.state == ::Dog::Track::STATE::FINISHED) then
            return 404
          else
            value = track.listens[variable]
            value = value["value"] if value

            request.body.rewind
            data = JSON.parse(request.body.read) rescue nil

            submitted_value = ::Dog::Value.from_ruby_value(data)
            submitted_value.person = find_or_generate_current_user()

            submission_track = ::Dog::Track.invoke("send:to:value", "future", [value, submitted_value])
            
            ::Dog::Runtime.schedule(submission_track)
            tracks = ::Dog::Runtime.resume

            spawns = []
            progress_track = track.to_hash_for_api_user()
            
            for t in tracks do
              if t.same_trace_as?(track) then
                progress_track = t.to_hash_for_api_user()
              elsif submission_track._id == t._id then
                next
              else
                spawns << t.to_hash_for_api_user()
              end
            end

            output = {
              "original_track" => track.to_hash_for_api_user(),
              "track" => progress_track,
              "spawns" => spawns,
              "account_status" => account_status
            }

            content_type 'application/json'
            return output.to_json


          end
        end
*/
	}

	public static Server createServer(int port, APIServlet servlet) {
		// Note: If I had wanted to seperate out servlets this is how I will do it:
		/*
			ServletContextHandler context = new ServletContextHandler(ServletContextHandler.SESSIONS);
			context.setContextPath("/");
			context.addServlet(new ServletHolder(new UserServlet(runtime)), "/user/*");
			context.addServlet(new ServletHolder(new StackFrames(runtime)), "/strackFrames/*");

			ResourceHandler resource_handler = new ResourceHandler();
			resource_handler.setDirectoriesListed(true);
			resource_handler.setWelcomeFiles(new String[]{ "index.html" });

			resource_handler.setResourceBase(".");

			HandlerList handlers = new HandlerList();
			handlers.setHandlers(new Handler[] { resource_handler, context_handler });
			server.setHandler(handlers);
		*/

		Server server = new Server(port);

		ResourceHandler resourceHandler = new ResourceHandler();
		resourceHandler.setDirectoriesListed(true);
		resourceHandler.setWelcomeFiles(new String[]{ "index.html" });
		resourceHandler.setResourceBase(FilenameUtils.normalize(servlet.filePath));

		ServletContextHandler context = new ServletContextHandler(ServletContextHandler.SESSIONS);
		context.setContextPath("/");
		context.addServlet(new ServletHolder(servlet), "/*");

		HandlerList handlers = new HandlerList();
		handlers.setHandlers(new Handler[] { resourceHandler, context, new DefaultHandler() });
		server.setHandler(handlers);

		return server;
	}
}