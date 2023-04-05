FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt upgrade -y 


#apt-get install -y --no-install-recommends 


#sudo \
#vim \
#git \
#less \
#jq 

# RUN chsh -s /usr/bin/zsh

# RUN git clone https://github.com/ZerbaZiege/ziege.git ~/.ziege

# RUN source $HOME/.ziege/init.zsh

CMD tail -f /dev/null

