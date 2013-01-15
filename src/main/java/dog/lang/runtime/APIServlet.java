
package dog.lang.runtime;

import dog.lang.Runtime;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.*;

import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.servlet.*;

public class APIServlet extends HttpServlet {

	private Runtime runtime;

	public APIServlet(Runtime runtime) {
		this.runtime = runtime;
	}

	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
	    resp.getWriter().print("Hello from Dog!\n");
	}

	public static Server createServer(int port, Runtime runtime) {
		Server server = new Server(port);
		
		ServletContextHandler context = new ServletContextHandler(ServletContextHandler.SESSIONS);
		context.setContextPath("/");
		server.setHandler(context);

		context.addServlet(new ServletHolder(new APIServlet(runtime)), "/*");

		return server;
	}
}