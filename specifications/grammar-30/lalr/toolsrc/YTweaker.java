import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;

/*
 * Created on Dec 23, 2003
 */

/**
 * @author scott_boag
 */
public class YTweaker {
	static String array1_start = "final static short yycheck[] = {";
	static char array1_end = '}';
	static final char EOF = 0xFFFF;
	// static final String yycheckClassName = "YYCheckTable";
	static final String yycheckClassOpen = "public class YYCheckTable {\n";
	static final String yycheckClassClose = "}\n";
	static final String nlAndIndent = "\n    ";
	
    static String initString1 =
        "	yycheck = new short[arraySizeCount];\n"
            + "	java.io.DataInputStream dis = null;\n"
            + "	try {\n"
            + "		java.io.InputStream in = this.getClass().getResourceAsStream(yycheckTableFileName);\n"
            + "		dis =\n"
            + "			new java.io.DataInputStream(in);\n"
            + "		for (int i = 0; i < arraySizeCount; i++) {\n"
            + "			yycheck[i] = dis.readShort();\n"
            + "			// System.out.println(yycheck[i]);\n"
            + "		}\n"
            + "	}\n"
            + "	catch (java.io.FileNotFoundException e) {\n"
            + "		e.printStackTrace();\n"
            + "	}\n"
            + "	catch (java.io.IOException e) {\n"
            + "		e.printStackTrace();\n"
            + "	}\n"
            + "	finally {\n"
            + "		if (dis != null) {\n"
            + "			try {\n"
            + "				dis.close();\n"
            + "			}\n"
            + "			catch (java.io.IOException e1) {\n"
            + "				e1.printStackTrace();\n"
            + "			}\n"
            + "		}\n"
            + "	}\n";


    public static void main(String[] args) 
    	throws IOException, FileNotFoundException {
        if (args.length < 2)
            System.out.println("Usage YTweaker yaccfile table1file");

        System.out.println("Tweaking "+args[0]);
        
        File inFile = new File(args[0]);
		System.out.println("parent is "+inFile.getAbsoluteFile().getParentFile());

		File table1file = new File(args[1]);
		System.out.println("output table file is "+table1file.getAbsoluteFile());
        
        File tempFile =
            File.createTempFile(
                "Temp",
                args[0],
                inFile.getAbsoluteFile().getParentFile());
        System.out.println("Writing to: "+tempFile.getAbsolutePath());

        FileReader fr = null;
        FileWriter fw = null;
		DataOutputStream tableClassFW = null;
        
		FileReader tempFileReader = null;
		FileWriter parserFileWriter = null;
        
        try
        {
			fr = new FileReader(inFile);
			fw = new FileWriter(tempFile);
		
			tableClassFW = new DataOutputStream(new FileOutputStream(table1file));
			// tableClassFW.write(yycheckClassOpen);

	        int matchPos = 0;
	        boolean inBigArrayContent = false;
	        boolean doneWithSearch = false;
	        StringBuffer accumulatedNumberString = new StringBuffer();
	        // Have to accumulate yycheck string, to remove the "final " if we find it.
			StringBuffer failedSearchAccumulator = new StringBuffer();
	        int arraySizeCount = 0;
	        // int blockCount = 0;
	        for(char c = (char)fr.read(); c != EOF; c = (char)fr.read())
	        {
	            if (doneWithSearch == false) {
	                if (inBigArrayContent == false) {
	                    if (c == array1_start.charAt(matchPos)) {
	                        matchPos++;
							failedSearchAccumulator.append(c);
	                        if (matchPos == array1_start.length()) {
	                            inBigArrayContent = true;
	                            matchPos++; // force error if you try to use
								failedSearchAccumulator.setLength(0); // just clean up to be clean
	                            fw.write("static short yycheck[] = null;\n");  
	                        }
							continue; // with the for loop
	                    }
	                    else if(matchPos > 0) {                   	
	                    	fw.write(failedSearchAccumulator.toString());
							failedSearchAccumulator.setLength(0);
	                        matchPos = 0;
	                    }
	                }
	                else if (c == array1_end) {
	                    matchPos = 0;
	                    inBigArrayContent = false;
	                    doneWithSearch = true;
						c = (char)fr.read(); // skip past ';' terminator
						fw.write("\n{"); // open static init block
						fw.write("	int arraySizeCount = "+arraySizeCount+";\n");
						fw.write("	String yycheckTableFileName = \""+table1file.getName()+"\";\n");
						fw.write(initString1);
						fw.write("}\n\n"); // close static init block
						// tableClassFW.write("};\n"+yycheckClassClose);
						tableClassFW.close();
						tableClassFW = null;
						// writeInit(arraySizeCount, yycheckTableFileName);
						continue; // with the for loop
	                }
					if(inBigArrayContent == true)
					{
						if(Character.isDigit((char)c))
						{
							// System.out.println("appending: "+ c);
							accumulatedNumberString.append(c);
						}
						else if(c == ',')
						{
							// tableClassFW.writeShort(s.shortValue());
							// System.out.print(s.shortValue()+", ");
							if(arraySizeCount % 10 == 0)
							{
								// tableClassFW.write(nlAndIndent);
							}
							
							if(arraySizeCount % 400 == 0)
							{
								// if(blockCount != 0)
								//	tableClassFW.write("  };\n\n");
								// tableClassFW.write("  final static short yycheck"+blockCount+"[] = {");
								// tableClassFW.write(nlAndIndent);
								// blockCount++;
							}
							// tableClassFW.write(accumulatedNumberString.toString());
							// tableClassFW.write(", ");
							short s = Short.parseShort(accumulatedNumberString.toString());
							tableClassFW.writeShort(s);
							
							arraySizeCount++;
							accumulatedNumberString.setLength(0);
						}
					
					}
	            }
	            if(inBigArrayContent == false)
					fw.write(c);
	        }
	        			
			fr.close();
			fr = null;
			fw.close();
			fw = null;
			
			parserFileWriter = new FileWriter(inFile);
			tempFileReader = new FileReader(tempFile);

			for(char cc = (char)tempFileReader.read(); cc != EOF; cc = (char)tempFileReader.read())
			{
				parserFileWriter.write(cc);
			}
			
			parserFileWriter.close();
			parserFileWriter = null;
			tempFileReader.close();
			tempFileReader = null;
			
			tempFile.delete();
			
			System.out.println("Success! yycheck has "+arraySizeCount+" elements.");
        }
        finally
        {     
        	if(fr != null)   
	        	fr.close();
			if(fw != null)
	        	fw.close();
	        if(tableClassFW != null)
				tableClassFW.close();
			if(tempFileReader != null)
				tempFileReader.close();
			if(parserFileWriter != null)
				parserFileWriter.close();

        }
        
    }
    
    static void writeInit(int arraySizeCount, String yycheckTableFileName) {
        short yycheck[] = new short[arraySizeCount];
        DataInputStream dis = null;
        try {
            dis =
                new DataInputStream(new FileInputStream(yycheckTableFileName));
            for (int i = 0; i < arraySizeCount; i++) {
                yycheck[i] = dis.readShort();
                System.out.println(yycheck[i]);
            }
        }
        catch (FileNotFoundException e) {
            e.printStackTrace();
        }
        catch (IOException e) {
            e.printStackTrace();
        }
        finally {
            if (dis != null) {
                try {
                    dis.close();
                }
                catch (IOException e1) {
                    e1.printStackTrace();
                }
            }

        }
    }
}
