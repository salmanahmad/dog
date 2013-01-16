package dog.lang.runtime;

import dog.lang.Runtime;
import dog.lang.StackFrame;
import dog.lang.NullValue;
import dog.lang.StructureValue;
import dog.lang.Value;

import com.mongodb.DBObject;
import com.mongodb.BasicDBObject;
import org.bson.types.ObjectId;
import org.json.JSONObject;
import org.json.JSONArray;
import org.json.JSONException;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.*;

import java.io.BufferedReader;
import java.io.StringWriter;
import java.io.StringReader;
import java.util.regex.Pattern;
import java.util.regex.Matcher;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Map;
import java.util.List;

import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.servlet.*;
import org.eclipse.jetty.server.handler.ResourceHandler;
import org.eclipse.jetty.server.handler.HandlerList;
import org.eclipse.jetty.server.handler.HandlerCollection;
import org.eclipse.jetty.server.Handler;
import org.eclipse.jetty.server.handler.DefaultHandler;
import org.eclipse.jetty.server.handler.ContextHandlerCollection;
import org.eclipse.jetty.server.handler.ContextHandler;

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
		FRAME_POST = Pattern.compile(String.format("^%s/frame/([a-zA-Z0-9]+)/([a-zA-Z0-9_]+)$", this.prefix));

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

 	@Override
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
 	
 	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
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
				Map<String, Value> meta = frame.getMetaData();
				StructureValue listens = (StructureValue)meta.get("listens");

				if(listens != null) {
					Value value = listens.get(variable);
					if(!(value instanceof NullValue)) {
						value = value.get("channel");
						Value submittedValue = null;

						StringBuffer body = new StringBuffer();
						String line = null;
						
						BufferedReader reader = req.getReader();
						while ((line = reader.readLine()) != null) {
							body.append(line);
						}
						
						try {
							JSONObject jsonBody = new JSONObject(body.toString());
							submittedValue = Value.createFromJSON(jsonBody, this.runtime.getResolver());
						} catch(JSONException e) {
							System.out.println(e);
							e.printStackTrace();
						}

						StackFrame submissionFrame = new StackFrame("future.send_value:to:", this.runtime.getResolver(), new Value[] {submittedValue, value});
						/* Force it to generate an ObjectId. This may not be necessary */
						submissionFrame.getId();
						
						this.runtime.schedule(submissionFrame);

						ArrayList<StackFrame> frames = this.runtime.resume();

						List<JSONObject> spawns = new ArrayList<JSONObject>();
						StackFrame progressFrame = frame;

						

						for(StackFrame f : frames) {
							if(f.symbolName.equals("dog.wait:")) {
								f = f.parentStackFrame();
							}

							if(StackFrame.areFramesInSameTrace(frame, f)) {
								progressFrame = f;
							} else if(submissionFrame.getId().equals(f.getId())) {
								continue;
							} else {
								spawns.add(Helper.stackFrameAsJsonForAPI(f));
							}
						}

						JSONObject jsonOutput = new JSONObject();
						
						try {
							jsonOutput.put("original_frame", Helper.stackFrameAsJsonForAPI(frame));
							jsonOutput.put("frame",  Helper.stackFrameAsJsonForAPI(progressFrame));
							jsonOutput.put("spawns", new JSONArray(spawns.toArray()));
						} catch(JSONException e) {
							System.out.println(e);
							e.printStackTrace();
						}

						output = jsonOutput.toString();
					}
				}
			} else {
				resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
				return;
			}
		}

		resp.setContentType("application/json");
		resp.getWriter().println(output);
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

	    //ContextHandler resourceContext = new ContextHandler();
	    //resourceContext.setContextPath("/");
	    //resourceContext.setHandler(resourceHandler);


		ServletContextHandler context = new ServletContextHandler(ServletContextHandler.SESSIONS);
		context.setContextPath("/");
		context.addServlet(new ServletHolder(servlet), "/*");


		//HandlerList handlers = new HandlerList();
		//handlers.setHandlers(new Handler[] { resourceHandler, context, new DefaultHandler() });
		//server.setHandler(handlers);

		//ContextHandlerCollection contexts = new ContextHandlerCollection();
		//contexts.setHandlers(new Handler[] { context, resourceContext });
		//server.setHandler(contexts);

		HandlerCollection handlerList = new HandlerCollection();
		handlerList.setHandlers(new Handler[]{resourceHandler, context});
		server.setHandler(handlerList);


		return server;
	}
}