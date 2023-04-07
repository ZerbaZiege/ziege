FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt upgrade -y 

# Run this separately to avoid errors on the next install commands
RUN apt-get install -y --no-install-recommends apt-utils ca-certificates 

RUN apt-get install -y --no-install-recommends \
    zsh  \
    sudo \
    vim \
    git \
    less \
    jq \
    curl 

RUN chsh -s /usr/bin/zsh

# RUN git clone https://github.com/ZerbaZiege/ziege.git ~/.ziege

# RUN echo "source $HOME/.ziege/init.zsh" >> ~/.zshrc

CMD tail -f /dev/null

