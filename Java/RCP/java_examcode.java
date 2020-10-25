import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
//            System.out.println("PATH: " + System.getenv("PATH"));
//            System.out.println(MCRConfiguration.isInstalledMCR());
//
//            System.out.println("PROXY LIBRARY DIR: " + MCRConfiguration.getProxyLibraryDir());
//            System.out.println("MCRROOT from file: " + MCRConfiguration.getMCRRoot().getAbsolutePath());
//            System.out.println("MCRROOT PARENT NAME: " + MCRConfiguration.getMCRRoot().getParent());

//            MWCharArray test = new MWCharArray("Test");
            
//private static final String MCREXPORT = ":/home/mnadvornik/bin/MATLAB_Runtime/v83/runtime/glnxa64:/home/mnadvornik/bin/MATLAB_Runtime/v83/bin/glnxa64:/home/mnadvornik/bin/MATLAB_Runtime/v83/sys/os/glnxa64:";            
            //private static final String PATHEXPORT = ":/home/mnadvornik/bin/MATLAB_Runtime/v85/runtime/glnxa64:/home/mnadvornik/bin/MATLAB_Runtime/v85/bin";




            String initLDLIBRARY = System.getenv("LD_LIBRARY_PATH");
//            String initPATH = System.getenv("PATH");
            
            List<String > argus = new ArrayList<String>();
            argus.add("/bin/sh");            
            //argus.add(args[0]);
            //argus.add("export PATH=".concat(initPATH.concat(PATHEXPORT)));
            
            ProcessBuilder pathpb = new ProcessBuilder(argus);
            
            Map<String, String> envVars = pathpb.environment();
            for(String var : envVars.keySet())
            {
                System.out.println("var");
            }
            //envVars.put("LD_LIBRARY_PATH",initLDLIBRARY.concat(MCREXPORT));
                        
            try{
                Process p = pathpb.start();
//                p.waitFor();
//                int resval = p.exitValue();
                //System.out.println("Resval "+resval);
//                InputStreamReader isr = new InputStreamReader(p.getInputStream());
//                char[] buf = new char[1024];
//                while (!isr.ready()) {
//                   ;
//                }
//                while (isr.read(buf) != -1) {
//                    System.out.println(buf);
//                }
                System.out.println(System.getenv("LD_LIBRARY_PATH"));



            }
            catch ( IOException ex )
            //catch ( IOException|InterruptedException ex )
            {
                System.err.println(ex.getMessage());
                System.exit(1);
            }
