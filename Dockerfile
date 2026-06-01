# k8s-whodis/Dockerfile

# Stage 1: Use official nginx alpine image for small size
FROM nginx:stable-alpine

# Install curl for health checks (optional but recommended)
RUN apk add --no-cache curl

# Remove default nginx static files
RUN rm -rf /usr/share/nginx/html/*

# Remove ALL default config files from conf.d
RUN rm -f /etc/nginx/conf.d/*

# Copy our custom HTML file to nginx serve directory
COPY html/index.html /usr/share/nginx/html/

# Copy custom nginx config (optional - uncomment if needed)
COPY nginx.conf /etc/nginx/nginx.conf

# Create a non-root user to run nginx (security best practice)
RUN adduser -D -H -u 1000 -s /sbin/nologin wwwuser && \
    chown -R wwwuser:wwwuser /usr/share/nginx/html && \
    chown -R wwwuser:wwwuser /var/cache/nginx && \
    chown -R wwwuser:wwwuser /var/log/nginx && \
    chown -R wwwuser:wwwuser /etc/nginx && \
    # Create /run directory with proper permissions
    mkdir -p /var/run/nginx && \
    chown -R wwwuser:wwwuser /var/run/nginx

# Switch to non-root user
USER wwwuser

# Expose port 80
EXPOSE 80

# Health check to verify server is running
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 CMD curl -f http://localhost/ || exit 1

# Start nginx (daemon off to keep container running)
CMD [ "nginx", "-g", "daemon off;" ]