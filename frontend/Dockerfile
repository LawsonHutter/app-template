# Bare bones Flutter web Dockerfile
# This builds a Flutter web app and serves it with nginx

# Stage 1: Build the Flutter web app
FROM ghcr.io/cirruslabs/flutter:stable AS build

# Set working directory inside container
WORKDIR /app

# Copy dependency files first (this allows Docker to cache this layer)
COPY pubspec.yaml pubspec.lock ./

# Download Flutter dependencies (cached if pubspec files don't change)
RUN flutter pub get

# Copy the rest of the source code
COPY . .

# Optional build-time API URL for the Flutter web app
# Example:
#   docker build --build-arg API_BASE_URL=http://localhost:8000/api/counter/ .
ARG API_BASE_URL=http://localhost:8000/api/counter/

# Build the Flutter app for web
# Note: --web-renderer flag was removed in Flutter 3.10+
# Flutter now automatically uses HTML renderer for web builds
RUN flutter build web --release --dart-define=API_BASE_URL=$API_BASE_URL

# Stage 2: Serve the built app with nginx
FROM nginx:alpine

# Copy the built web files from the build stage to nginx's html directory
COPY --from=build /app/build/web /usr/share/nginx/html

# Expose port 80 (default nginx port)
EXPOSE 80

# Start nginx in foreground (required for Docker containers)
CMD ["nginx", "-g", "daemon off;"]
