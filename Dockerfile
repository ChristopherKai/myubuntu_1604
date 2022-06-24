FROM phusion/baseimage:master-amd64
LABEL maintainer="kais <hjuj_91@163.com>"

ENV DEBIAN_FRONTEND noninteractive

ENV TZ Asia/Shanghai

ENV LC_ALL=en_US.UTF-8 

ENV PYTHONIOENCODING=UTF-8

RUN dpkg --add-architecture i386 && \
    apt-get -y update && \
    apt install -y \
    libc6:i386 \
    libc6-dbg:i386 \
    libc6-dbg \
    lib32stdc++6 \
    g++-multilib \
    cmake \
    ipython3 \
    vim \
    openssh-server \
    net-tools \
    iputils-ping \
    libffi-dev \
    libssl-dev \
    python3-dev \
    python3-pip \
    build-essential \
    ruby \
    ruby-dev \
    tmux \
    strace \
    locales \
    ltrace \
    nasm \
    wget \
    gdb \
    gdb-multiarch \
    netcat \
    socat \
    git \
    patchelf \
    gawk \
    file \
    python3-distutils \
    bison \
    rpm2cpio cpio \
    zstd \
    tzdata --fix-missing && \
    rm -rf /var/lib/apt/list/*

RUN sed -i "s|#PermitRootLogin prohibit-password|PermitRootLogin yes|g"  /etc/ssh/sshd_config && locale-gen en_US.UTF-8 


RUN ln -fs /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata 
    
# RUN version=$(curl https://github.com/radareorg/radare2/releases/latest | grep -P '/tag/\K.*?(?=")' -o) && \
#     wget https://github.com/radareorg/radare2/releases/download/${version}/radare2_${version}_amd64.deb && \
#     dpkg -i radare2_${version}_amd64.deb && rm radare2_${version}_amd64.deb

RUN python3 -m pip install -U pip && \
    python3 -m pip install --no-cache-dir \
    ropgadget \
    z3-solver \
    smmap2 \
    ipython \
    formatStringExploiter\
    apscheduler \
    ropper \
    unicorn \
    keystone-engine \
    capstone \
    angr \
    pebble \
    r2pipe

RUN gem install one_gadget seccomp-tools && rm -rf /var/lib/gems/2.*/cache/*

# RUN git clone --depth 1 https://github.com/pwndbg/pwndbg && \
#     cd pwndbg && chmod +x setup.sh && ./setup.sh

RUN git clone --depth 1 https://github.com/ChristopherKai/mypwndbg.git && cd mypwndbg && chmod +x setup.sh && ./setup.sh 

RUN git clone https://github.com/ChristopherKai/myLibcSearcher.git && cd myLibcSearcher && python setup.py develop 

RUN git clone https://github.com/ChristopherKai/coolpwn.git && cd coolpwn && python setup.py install 

RUN git clone https://github.com/ChristopherKai/mytools.git && ln /opt/mytools/gentemplate/gentemplate.py /usr/local/bin/gentemplate

RUN git clone --depth 1 https://github.com/scwuaptx/Pwngdb.git ~/Pwngdb && \
    cd ~/Pwngdb && mv .gdbinit .gdbinit-pwngdb && \
    sed -i "s?source ~/peda/peda.py?# source ~/peda/peda.py?g" .gdbinit-pwngdb && \
    echo "source ~/Pwngdb/.gdbinit-pwngdb" >> ~/.gdbinit

RUN wget -O ~/.gdbinit-gef.py -q http://gef.blah.cat/py

RUN git clone --depth 1 https://github.com/niklasb/libc-database.git libc-database && \
    cd libc-database && ./get ubuntu debian || echo "/libc-database/" > ~/.libcdb_path && \
    rm -rf /tmp/*

RUN echo "root:root" | chpasswd \
    && && printf "\nexport LC_ALL=en_US.UTF-8\nexport PYTHONIOENCODING=UTF-8" >> /etc/profile 


WORKDIR /ctf/work/

COPY --from=skysider/glibc_builder64:2.19 /glibc/2.19/64 /glibc/2.19/64
COPY --from=skysider/glibc_builder32:2.19 /glibc/2.19/32 /glibc/2.19/32

COPY --from=skysider/glibc_builder64:2.23 /glibc/2.23/64 /glibc/2.23/64
COPY --from=skysider/glibc_builder32:2.23 /glibc/2.23/32 /glibc/2.23/32

COPY --from=skysider/glibc_builder64:2.24 /glibc/2.24/64 /glibc/2.24/64
COPY --from=skysider/glibc_builder32:2.24 /glibc/2.24/32 /glibc/2.24/32

COPY --from=skysider/glibc_builder64:2.28 /glibc/2.28/64 /glibc/2.28/64
COPY --from=skysider/glibc_builder32:2.28 /glibc/2.28/32 /glibc/2.28/32

COPY --from=skysider/glibc_builder64:2.29 /glibc/2.29/64 /glibc/2.29/64
COPY --from=skysider/glibc_builder32:2.29 /glibc/2.29/32 /glibc/2.29/32

COPY --from=skysider/glibc_builder64:2.30 /glibc/2.30/64 /glibc/2.30/64
COPY --from=skysider/glibc_builder32:2.30 /glibc/2.30/32 /glibc/2.30/32

COPY --from=skysider/glibc_builder64:2.27 /glibc/2.27/64 /glibc/2.27/64
COPY --from=skysider/glibc_builder32:2.27 /glibc/2.27/32 /glibc/2.27/32

COPY linux_server linux_server64  /ctf/

RUN chmod a+x /ctf/linux_server /ctf/linux_server64

ARG PWNTOOLS_VERSION

RUN python3 -m pip install --no-cache-dir pwntools==${PWNTOOLS_VERSION}

EXPOSE 22

CMD ["/sbin/my_init"]