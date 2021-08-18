
JAR=./target/nexus-scheduler-0.0.1-SNAPSHOT.jar
rm -rf ${JAR}
mvn clean
mvn package
ls -alt ${JAR}

## mvn spring-boot:run
## gradle bootRun
