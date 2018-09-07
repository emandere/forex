FROM forexappbase
WORKDIR /forex
ADD lib /forex/lib
ADD web /forex/web
ADD services.dart /forex/services.dart
RUN pub build

RUN addgroup --S appuser && adduser -S -G  appuser appuser
USER appuser
CMD []
ENTRYPOINT ["su","-","appuser","/usr/bin/dart","services.dart","release"]