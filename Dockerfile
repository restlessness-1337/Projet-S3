# Stage 1: Build
FROM maven:3.9-eclipse-temurin-20 AS build
WORKDIR /app

COPY pom.xml .
COPY src ./src

RUN mvn clean package -DskipTests

# Stage 2: Runtime avec Tomcat
FROM tomcat:10.1-jdk17

# Supprimer les apps par défaut
RUN rm -rf /usr/local/tomcat/webapps/*

# Copier le WAR
COPY --from=build /app/target/Projet_S3.war /usr/local/tomcat/webapps/ROOT.war

# Exposer le port
EXPOSE 8080

# Lancer Tomcat
CMD ["catalina.sh", "run"]
```

### Étape 2 : Créer .dockerignore
```
target/
.git/
.gitignore
.idea/
*.iml
README.md
Jenkinsfile
k8s/
