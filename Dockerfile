FROM oraclelinux:7-slim

RUN yum -y install oracle-release-el7 && \
    yum-config-manager --enable ol7_oracle_instantclient && \
    yum -y install oracle-instantclient19.12-basic \
    yum clean all && \
    rm -rf /var/cache/yum

RUN yum -y install python3 && \
    yum clean all && \
    rm -rf /var/cache/yum

RUN python3 -m pip install cx_Oracle

RUN python3 -m pip install jupyter pandas

WORKDIR /work

EXPOSE 8888

CMD ["jupyter", "notebook", "--no-browser", "--port=8888", "--ip=0.0.0.0", "--allow-root", "--NotebookApp.token=''"]

#ENV NLS_LANG=Japanese_Japan.AL32UTF8
#ENV NLS_NCHAR_CHARSET=Japanese_Japan.AL16UTF16
