FROM ubuntu:latest

RUN apt update \
    && apt install apt-utils wget unzip procps -y
RUN apt install git -y
ARG url
WORKDIR /app
RUN cd /app && git clone ${url}


#Create maven directory and install

ENV MAVEN_VERSION 3.3.9

RUN apt install curl -y
RUN mkdir -p /usr/share/maven \
    && curl -fsSL http://apache.osuosl.org/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz \
      | tar -xzC /usr/share/maven --strip-components=1 \
    && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn



#Installing OpenJdk

RUN apt-get update \
    && apt-get install software-properties-common -y \
    && apt-add-repository 'deb http://security.debian.org/debian-security stretch/updates main' \
    && apt-get update \
    && apt-get install openjdk-8-jdk -y

ARG artifactid
ARG version
ENV artifact ${artifactid}-${version}.jar
WORKDIR /app
RUN cd /app/java-getting-started/ && mvn package

#Install tomcat
RUN mkdir /usr/local/tomcat
RUN cd /tmp && wget https://downloads.apache.org/tomcat/tomcat-9/v9.0.46/bin/apache-tomcat-9.0.46.tar.gz
RUN cd /tmp && tar -zxvf apache-tomcat-9.0.46.tar.gz
RUN cp -Rv /tmp/apache-tomcat-9.0.46/* /usr/local/tomcat/
RUN cp /app/java-getting-started/target/${artifact} /usr/local/tomcat/webapps/

EXPOSE 8080
ENTRYPOINT ["sh", "-c"]
RUN chmod +x /usr/local/tomcat/bin/startup.sh
CMD ["/usr/local/tomcat/bin/startup.sh"]
