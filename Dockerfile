FROM google/dart

WORKDIR /forex
ADD pubspec.* /forex/
RUN pub get
ADD . /app
RUN pub get --offline

CMD []
ENTRYPOINT ["/usr/bin/dart", "services.dart"]