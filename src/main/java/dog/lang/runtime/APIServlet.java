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

import java.util.regex.Pattern;
import java.util.regex.Matcher;

import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.servlet.*;
import org.eclipse.jetty.server.handler.ResourceHandler;
import org.eclipse.jetty.server.handler.HandlerList;
import org.eclipse.jetty.server.Handler;
import org.eclipse.jetty.server.handler.DefaultHandler;

import org.apache.commons.io.FilenameUtils;

public class APIServlet extends HttpServlet {

	public Runtime runtime;
	public String prefix;
	public String filePath;

	Pattern ACCOUNT_STATUS;
	Pattern ACCOUNT_LOGIN;
	Pattern ACCOUNT_LOGOUT;
	Pattern FRAME_GET;

	public APIServlet(Runtime runtime, String prefix, String filePath) {
		this.runtime = runtime;
		this.prefix = FilenameUtils.normalize("/" + prefix);
		this.filePath = filePath;

		ACCOUNT_STATUS = Pattern.compile(String.format("^%s/account/status$", this.prefix));
		ACCOUNT_LOGIN = Pattern.compile(String.format("^%s/account/login$", this.prefix));
		ACCOUNT_LOGOUT = Pattern.compile(String.format("^%s/account/logout$", this.prefix));
		FRAME_GET = Pattern.compile(String.format("^%s/frame/([a-zA-Z0-9]+)$", this.prefix));
	}

	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		String requestPath = req.getPathInfo();
		String output = null;
		Matcher match = null;

		System.out.println(requestPath);

		System.out.println(ACCOUNT_STATUS);

		match = ACCOUNT_STATUS.matcher(requestPath);
		if(match.matches()) {
			System.out.println("Account status");
		} else {
			System.out.println("Else Account Status");
		}

		if((match = ACCOUNT_STATUS.matcher(requestPath)).matches()) {
			output = "Account Status!";
		} else if((match = ACCOUNT_LOGIN.matcher(requestPath)).matches()) {
			output = "Account Login!";
		} else if((match = ACCOUNT_LOGOUT.matcher(requestPath)).matches()) {
			output = "Account Logout!";
		} else if((match = FRAME_GET.matcher(requestPath)).matches()) {
			System.out.println(requestPath);

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
		} else {
			resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
			return;
		}

		System.out.println(output);

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

		System.out.println(servlet.filePath);

		ServletContextHandler context = new ServletContextHandler(ServletContextHandler.SESSIONS);
		context.setContextPath("/");
		context.addServlet(new ServletHolder(servlet), "/*");

		HandlerList handlers = new HandlerList();
		handlers.setHandlers(new Handler[] { resourceHandler, context, new DefaultHandler() });
		server.setHandler(handlers);

		return server;
	}
}