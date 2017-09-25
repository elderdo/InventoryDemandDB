FOR  %%p in (*.java) Do javac -classpath classes -d classes %%p
cd classes
@echo Making new Amd2Xml.jar file
del Amd2Xml.jar
jar cf Amd2Xml.jar *.class
move /Y Amd2Xml.jar ..\Scripts\Amd2Xml.jar
cd ..

