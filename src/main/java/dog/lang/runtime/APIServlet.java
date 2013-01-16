package dog.lang.runtime;

import dog.lang.Runtime;

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

		ACCOUNT_STATUS = Pattern.compile(String.format("^%s/account/status$", prefix));
		ACCOUNT_LOGIN = Pattern.compile(String.format("^%s/account/login$", prefix));
		ACCOUNT_LOGOUT = Pattern.compile(String.format("^%s/account/logout$", prefix));
		FRAME_GET = Pattern.compile(String.format("^%s/frame/([a-zA-Z0-9]+)$", prefix));
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
			output = "Frame!";
		} else {
			resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
			return;
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