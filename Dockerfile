# Flutter Web Build for Vercel
FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter
ENV FLUTTER_HOME=/opt/flutter
ENV PATH="$FLUTTER_HOME/bin:$PATH"
RUN git clone https://github.com/flutter/flutter.git -b stable ${FLUTTER_HOME}
RUN flutter doctor -v
RUN flutter config --enable-web

# Set working directory
WORKDIR /app

# Copy project files
COPY . .

# Build Flutter web app
RUN flutter pub get
RUN flutter build web --release --base-href=/app/

# Serve built files
CMD ["flutter", "build", "web", "--release", "--base-href=/app/"]
