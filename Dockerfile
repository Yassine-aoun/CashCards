# Use an official OpenJDK runtime as a parent image
FROM openjdk:17-jdk-slim AS build

# Set the working directory inside the container
WORKDIR /app

# Copy the Gradle wrapper and build scripts
COPY gradlew build.gradle settings.gradle /app/
COPY gradle /app/gradle

# Ensure the gradlew has execution permissions
RUN chmod +x gradlew

# Download dependencies before copying the source code
RUN ./gradlew dependencies

# Copy the source code
COPY src /app/src

# Build the application
RUN ./gradlew build

# Stage for running tests
FROM build AS test

# Run the tests
RUN ./gradlew test

# Stage for running the application
FROM openjdk:17-jdk-slim AS runtime

# Set the working directory inside the container
WORKDIR /app

# Copy the built jar file from the build stage
COPY --from=build /app/build/libs/*.jar /app/app.jar

# Expose the port the app runs on
EXPOSE 8080

# Set the entry point to run the application
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
