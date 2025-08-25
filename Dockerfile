FROM alpine:3.20
# Create non-root user
RUN adduser -D app
USER app
WORKDIR /app
COPY app/hello.sh ./
ENTRYPOINT ["sh","./hello.sh"]
