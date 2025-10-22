# syntax=docker/dockerfile:1.6

# ===== Stage 1 — Build =====
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app

# Copie l'ensemble du projet (plus simple/fiable que go-offline)
COPY . .

# Compile et package (WAR attendu dans target/)
RUN mvn -B clean package -DskipTests

# ===== Stage 2 — Runtime (Tomcat 10 + JDK17) =====
FROM tomcat:10.1-jdk17
RUN rm -rf /usr/local/tomcat/webapps/*
ARG WAR_NAME=Projet_S3.war
COPY --from=build /app/target/${WAR_NAME} /usr/local/tomcat/webapps/ROOT.war

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=5 \
  CMD wget -qO- http://127.0.0.1:8080/ >/dev/null 2>&1 || exit 1

EXPOSE 8080
CMD ["catalina.sh", "run"]
