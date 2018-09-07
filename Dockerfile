FROM forexappbase
RUN groupadd -g 999 appuser && \
    useradd -r -u 999 -g appuser appuser
USER appuser
WORKDIR /forex
ADD lib /forex/lib
ADD web /forex/web
ADD services.dart /forex/services.dart
RUN pub build
CMD []
ENTRYPOINT ["/usr/bin/dart","services.dart","release"]