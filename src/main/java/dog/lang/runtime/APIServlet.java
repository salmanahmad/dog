package dog.lang.runtime;

import dog.lang.Runtime;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.*;

import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.servlet.*;

public class APIServlet extends HttpServlet {

	private Runtime runtime;

	private String prefix;
	private String filePath;

	public APIServlet(Runtime runtime, String prefix, String filePath) {
		this.runtime = runtime;
		this.prefix = prefix;
		this.filePath = filePath;
	}

	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
	    String path = req.getPathInfo();

	    if(path == "" || path == "/") {
	    	path = "index.html";
	    }

	    
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

		ServletContextHandler context = new ServletContextHandler(ServletContextHandler.SESSIONS);
		context.setContextPath("/");
		server.setHandler(context);

		context.addServlet(new ServletHolder(servlet), "/*");

		return server;
	}
}