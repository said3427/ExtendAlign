FROM biocontainers/samtools:v1.7.0_cv3

################## METADATA ######################
LABEL base.image="biocontainers/samtools:v1.7.0_cv3"
LABEL version="1"
LABEL software="ExtendAligner"
LABEL software.version="NA"
LABEL about.summary="A computational algorithm for delivering multiple global alignment results originated from local alignments."
LABEL about.home="https://github.com/Flores-JassoLab/ExtendAlign"
LABEL about.documentation="https://github.com/Flores-JassoLab/ExtendAlign"
LABEL license="https://github.com/Flores-JassoLab/ExtendAlign"
LABEL about.tags="miRNA"

USER root

RUN apt-get update && apt-get install -y blast2 \
 coreutils\
 findutils\
 9base \
 ncbi-blast+

# S6 compilation

RUN cd /usr/src \
 && git clone https://github.com/skarnet/skalibs.git && cd skalibs \
 && ./configure --enable-clock --enable-monotonic \
 && make -j4 strip && make install 

RUN cd /usr/src \
 && git clone https://github.com/skarnet/execline.git && cd execline \
 && ./configure && make -j4 strip && make install 

RUN cd /usr/src \
 && git clone https://github.com/skarnet/s6.git && cd s6 \
 && ./configure && make -j4 strip && make install

ENV PATH=$PATH:/usr/lib/plan9/bin

RUN mkdir -p /home/github \
  && cd /home/github \
  && git clone https://github.com/Flores-JassoLab/ExtendAlign
