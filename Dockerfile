# Calculadora CBS/IBS (fork BigPar) — imagem para o Coolify.
# 1) gera o banco SQLite a partir dos scripts Flyway da Receita
# 2) roda os testes da Receita (se algum quebrar após um "Sync fork", o deploy falha e a versão antiga continua no ar)
# 3) imagem final só com o JRE, o .jar e o banco (somente leitura)

FROM maven:3.9.11-eclipse-temurin-25 AS build
WORKDIR /src
COPY pom.xml mvnw ./
COPY .mvn .mvn
RUN mvn -B -q dependency:go-offline || true
COPY flyway flyway
RUN mkdir -p calculadora/db \
 && mvn -B -q flyway:migrate -Dflyway.configFiles=./flyway/flyway-pro.conf --errors
COPY src src
ARG RODAR_TESTES=true
RUN if [ "$RODAR_TESTES" = "true" ]; then mvn -B -q test; fi \
 && mvn -B -q package -DskipTests

FROM eclipse-temurin:25-jre
RUN apt-get update && apt-get install -y --no-install-recommends curl && rm -rf /var/lib/apt/lists/* \
 && useradd -r -u 10001 calc
WORKDIR /app
COPY --from=build /src/target/api-regime-geral.jar app.jar
COPY --from=build /src/calculadora/db/calculadora-pro.db calculadora/db/calculadora-pro.db
RUN chmod 444 calculadora/db/calculadora-pro.db
USER calc
ENV SPRING_PROFILES_ACTIVE=offline \
    JAVA_TOOL_OPTIONS="-XX:MaxRAMPercentage=70 -XX:+ExitOnOutOfMemoryError"
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
  CMD curl -fsS http://localhost:9101/health || exit 1
CMD ["java", "-jar", "app.jar"]
