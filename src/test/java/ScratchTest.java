
import junit.framework.*; 
import org.reflections.*;
import org.reflections.util.*;
import org.reflections.scanners.*;

import java.util.*;

public class ScratchTest extends TestCase {
  public void test() {
    
    //dog.lang.Runtime.run();
    
    /*
    Reflections reflections = new Reflections(new ConfigurationBuilder()
            .setScanners(new SubTypesScanner(false), new ResourcesScanner())
            .setUrls(ClasspathHelper.forPackage("dog")));
            //.filterInputsBy(new FilterBuilder().include(FilterBuilder.prefix("dog.lang"))));
    */
      
      // I shoudl consider using getTypesAnnotatedWith instead
    
    Reflections reflections = new Reflections("dog");
    
    Set<Class<? extends dog.Symbol>> allClasses = reflections.getSubTypesOf(dog.Symbol.class);
    
    System.out.println(allClasses.size());
    System.out.println("\n\n");
    System.out.println(allClasses.toString());
    
    
    Package[] packages = Package.getPackages();
    for (int i = 0; i < packages.length; i++) {
      String name = packages[i].getName();
      
      //System.out.println(name);
      if(name.equals("dog.lang")) {
        //System.out.println("\n\n-- HERE -- \n");
      }
    }
    
  }

}
