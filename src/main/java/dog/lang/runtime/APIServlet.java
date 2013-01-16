package dog.lang.runtime;

import dog.lang.Runtime;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.*;

import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.servlet.*;
import org.eclipse.jetty.server.handler.ResourceHandler;
import org.eclipse.jetty.server.handler.HandlerList;
import org.eclipse.jetty.server.Handler;

import org.apache.commons.io.FilenameUtils;

public class APIServlet extends HttpServlet {

	public Runtime runtime;

	public String prefix;
	public String filePath;

	public APIServlet(Runtime runtime, String prefix, String filePath) {
		this.runtime = runtime;
		this.prefix = prefix;
		this.filePath = filePath;
	}

	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
	    
		resp.getWriter().println("Hello!");
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
		handlers.setHandlers(new Handler[] { resourceHandler, context });
		server.setHandler(handlers);

		return server;
	}
}