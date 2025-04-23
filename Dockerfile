# Stage 1: Build the application using Maven
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
# Copy pom.xml first to leverage Docker cache for dependencies
COPY pom.xml .
# Download dependencies (this layer is cached if pom.xml doesn't change)
RUN mvn dependency:go-offline
# Copy the rest of the source code
COPY src ./src
# Package the application (compile, test, create JAR)
RUN mvn package -DskipTests

# Stage 2: Create the final lightweight runtime image
FROM openjdk:17-jdk-slim
WORKDIR /app
# Copy *only* the application JAR from the build stage
COPY --from=build /app/target/my-cicd-app-*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","/app/app.jar"]