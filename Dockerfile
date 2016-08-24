FROM google/dart

WORKDIR /forex
ADD pubspec.* /forex/
ADD lib /forex/lib
ADD web /forex/web
ADD services.dart /forex/services.dart
RUN pub get --trace
ADD . /forex
RUN pub get --offline
RUN pub build
CMD []
ENTRYPOINT ["/usr/bin/dart", "services.dart"]