FROM forexappbase
WORKDIR /forex
ADD lib /forex/lib
ADD web /forex/web
ADD services.dart /forex/services.dart
RUN pub build
CMD []
ENTRYPOINT ["/usr/bin/dart","services.dart","release"]