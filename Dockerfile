FROM alpine:3.14 as base
MAINTAINER Yusuf Murodov "yusuf.murodov1@gmail.com"
RUN  apk update \
  && apk upgrade \
  && apk add --update openjdk11 tzdata curl unzip bash \
  && rm -rf /var/cache/apk/*
WORKDIR /app
COPY . .
RUN chmod +x ./gradlew
RUN ./gradlew build

FROM base as development
CMD ["./gradlew", "bootRun", "-Dspring.profiles.active=dev", "-Dspring-boot.run.jvmArguments='-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:8001'"]

FROM base as build
RUN ./gradlew jar

FROM openjdk:11-jre-slim as production
COPY --from=build /app/build/libs/service-discovery-*.jar /service-discovery-service.jar
CMD ["java", "-Dspring.profiles.active=prod", "-jar", "/service-discovery-service.jar"]
