FROM  ubuntu:16.04
WORKDIR /opt
USER root
ENV LC_ALL=en_US.UTF-8 
ENV PYTHONIOENCODING=UTF-8
RUN apt update && apt install -y openssh-server git locales ruby tmux sudo ruby-dev && rm -rf /var/lib/apt/lists/* \
    && sed -i "s|#PermitRootLogin prohibit-password|PermitRootLogin yes|g"  /etc/ssh/sshd_config && locale-gen en_US.UTF-8 \
    && wget https://bootstrap.pypa.io/ez_setup.py -O - | python
RUN easy_install pip && pip install --upgrade pip &&　pip install --no-cache-dir pwntools capstone ropgadget formatStringExploiter ipython  && gem install one_gadget seccomp-tools
RUN git clone https://github.com/ChristopherKai/myLibcSearcher.git && cd myLibcSearcher && python setup.py develop && cd - \ 
    && git clone https://github.com/ChristopherKai/mypwndbg.git && cd mypwndbg && ./setup.sh && cd - \
    && git clone https://github.com/ChristopherKai/coolpwn.git && cd coolpwn && python setup.py install && cd -\
    && git clone https://github.com/ChristopherKai/mytools.git && ln /opt/mytools/gentemplate/gentemplate.py /usr/local/bin/gentemplate
RUN echo "root:root" | chpasswd && echo "nameserver 8.8.8.8" >> /etc/resolv.conf
COPY entrypoint.sh /opt
RUN chmod +x /opt/entrypoint.sh
EXPOSE 22
ENTRYPOINT [ "/opt/entrypoint.sh" ]
