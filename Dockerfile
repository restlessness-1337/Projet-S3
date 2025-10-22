# Stage 1 — Build (Maven+JDK17)
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app

# Préparer le cache des dépendances
COPY pom.xml .
RUN --mount=type=cache,target=/root/.m2 mvn -B -q -e -DskipTests dependency:go-offline

# Copier le code et packager
COPY src ./src
ARG WAR_NAME=Projet_S3.war
RUN --mount=type=cache,target=/root/.m2 mvn -B clean package -DskipTests \
 && test -f "target/${WAR_NAME}" || (echo "WAR introuvable (target/${WAR_NAME})" && ls -lah target && false)

# Stage 2 — Runtime (Tomcat 10 + JDK17)
FROM tomcat:10.1-jdk17
RUN rm -rf /usr/local/tomcat/webapps/*
ARG WAR_NAME=Projet_S3.war
COPY --from=build /app/target/${WAR_NAME} /usr/local/tomcat/webapps/ROOT.war

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=5 \
  CMD wget -qO- http://127.0.0.1:8080/ >/dev/null 2>&1 || exit 1

EXPOSE 8080
CMD ["catalina.sh", "run"]
