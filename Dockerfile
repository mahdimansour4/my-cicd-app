# Use a slim Java Runtime base image (ensure JDK version matches your project)
FROM openjdk:17-jdk-slim

# Set working directory inside the container
WORKDIR /app

# Copy the executable JAR file created by Maven into the image's root
# This assumes the JAR is in the 'target' directory after the Maven build
# Use ARG for flexibility if needed, but this is simpler for now
COPY target/*.jar app.jar

# Expose the port the application runs on (default for Spring Boot is 8080)
# This is the port *inside* the container
EXPOSE 8080

# Command to run the application when the container starts
ENTRYPOINT ["java", "-jar", "/app/app.jar"]