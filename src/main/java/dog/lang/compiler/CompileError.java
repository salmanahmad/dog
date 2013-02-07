package dog.lang.compiler;

public class CompileError extends RuntimeException
{
    public String file;
    public int line;

    public CompileError(String message, String file, int line){
	super(message);
	this.file = file;
	this.line = line;
    }
}
