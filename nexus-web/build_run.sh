
JAR=./target/nexusweb-0.0.1-SNAPSHOT.jar
/usr/libexec/java_home -V

export JAVA_HOME=$(/usr/libexec/java_home -v 11.0.12)
echo "JAVA_HOME=$JAVA_HOME"
export PATH=$JAVA_HOME/bin:$PATH
java -version

##./mvnw clean spring-boot:run

##mvn clean spring-boot:run
rm -rf ${JAR} || echo "${JAR} not found, Ok to proceed "
mvn clean
mvn package
ls -alt ${JAR}


##mvn clean
##./mvnw spring-boot:run
##mvn package
##mvn install -DskipTests=false
