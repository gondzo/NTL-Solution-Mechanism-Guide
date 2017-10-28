FROM centos:7.2.1511

RUN yum -y install gcc-c++ make wget\
	bzip2 freetype-devel libpng-devel libjpeg-devel libtiff-devel libxml2-devel&&\
    curl -sL https://rpm.nodesource.com/setup_6.x | bash - &&\
	yum -y install nodejs rsync &&\
	wget ftp://ftp.graphicsmagick.org/pub/GraphicsMagick/GraphicsMagick-LATEST.tar.bz2 &&\
	tar -jxvf GraphicsMagick-LATEST.tar.bz2

RUN cd GraphicsMagick-* &&\
	./configure --prefix=/usr &&\
	make &&\
	make install &&\
	cd ..


ENV USER_NAME app

RUN useradd -ms /bin/bash $USER_NAME && \
	mkdir app 

WORKDIR ./app

# Install app dependencies
COPY package.json ./

RUN npm install

# Bundle app source
COPY . .

RUN chmod +x wait-for-it.sh &&\
	chown -R $USER_NAME .

USER $USER_NAME

EXPOSE 3000


CMD ["node", "app"]
