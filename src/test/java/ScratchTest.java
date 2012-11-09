
import java.util.*;
import org.junit.*; 
import dog.lang.*;

public class ScratchTest {
    
    @Test
    public void test() {

        //dog.lang.Runtime.run();

    /*
        Reflections reflections = new Reflections(new ConfigurationBuilder()
            .setScanners(new SubTypesScanner(false), new ResourcesScanner())
            .setUrls(ClasspathHelper.forPackage("dog")));
            //.filterInputsBy(new FilterBuilder().include(FilterBuilder.prefix("dog.lang"))));


      // I shoudl consider using getTypesAnnotatedWith instead

        Reflections reflections = new Reflections("dog");

        Set<Class<? extends dog.lang.Value>> allClasses = reflections.getSubTypesOf(dog.lang.Value.class);

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
        */
        try {
            //Type f = new Type();
            //StructureValue frame = Type.class.newInstance();
            //System.out.println(frame.getClass().toString());
        } catch (Exception e) {
            //System.out.println(e.toString());
        }
    }
}
