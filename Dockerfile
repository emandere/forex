FROM forexappbase
WORKDIR /forex
ADD lib /forex/lib
ADD web /forex/web
ADD services.dart /forex/services.dart
RUN pub build

RUN adduser --disabled-password --gecos '' docker
RUN adduser docker sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER docker
RUN sudo apt-get
CMD []
ENTRYPOINT ["su","-","docker","/usr/bin/dart","services.dart","release"]