FROM lambci/lambda:build-python3.6

ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

ENV PACKAGE_PREFIX /tmp/python

RUN pip3 install rasterio -t $PACKAGE_PREFIX -U

################################################################################
#                            REDUCE PACKAGE SIZE                               #
################################################################################
RUN find $PACKAGE_PREFIX -name "*-info" -type d -exec rm -rdf {} +
RUN rm -rdf $PACKAGE_PREFIX/boto3/ \
  && rm -rdf $PACKAGE_PREFIX/botocore/ \
  && rm -rdf $PACKAGE_PREFIX/docutils/ \
  && rm -rdf $PACKAGE_PREFIX/dateutil/ \
  && rm -rdf $PACKAGE_PREFIX/jmespath/ \
  && rm -rdf $PACKAGE_PREFIX/s3transfer/ \
  && rm -rdf $PACKAGE_PREFIX/numpy/doc/

# Leave module precompiles for faster Lambda startup
RUN find $PACKAGE_PREFIX -type f -name '*.pyc' | while read f; do n=$(echo $f | sed 's/__pycache__\///' | sed 's/.cpython-36//'); cp $f $n; done;
RUN find $PACKAGE_PREFIX -type d -a -name '__pycache__' -print0 | xargs -0 rm -rf
RUN find $PACKAGE_PREFIX -type f -a -name '*.py' -print0 | xargs -0 rm -f


COPY handler.py $PACKAGE_PREFIX/handler.py

################################################################################
#                              CREATE ARCHIVE                                  #
################################################################################
RUN cd $PACKAGE_PREFIX && zip -r9q /tmp/package.zip *
