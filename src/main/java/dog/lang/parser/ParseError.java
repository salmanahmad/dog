package dog.lang.parser;
public class ParseError extends RuntimeException
{
	public ParseError(String message){
		super(message);
	}
};
