ENGINE_OBJS = pba.o ../dpif.o ../engine.o ../dot.o
FS_OBJS     = ${ENGINE_OBJS} ../fsMain.o ../fsCore.o
MEXICO_OBJS = ${FS_OBJS} mexico.o

%: %.o #Please don't build xyz from xyz.o
	

mexico:	mexicow \
	mexres mexicoch.cgi \
	mexicotbo.cgi mexicop50.cgi mexicorss.cgi

mexicow: mexicow0.cgi mexicow1.cgi mexicow2.cgi mexicow3.cgi \
	mexicowa.cgi mexicowb.cgi

mexres: mexres.cgi mexresho.cgi mexphoto.cgi

mx: mx.cgi mx-count.cgi map-demo.cgi mx-pix.cgi

p70r: p70r1.cgi p70r2.cgi p70r3.cgi p70r4.cgi p70r5.cgi

clean: 
	rm *.o
	rm *.cgi
	rm fs-mex7e

fs-mex7e: ../dp.o ${ENGINE_OBJS} ../map.o
	/usr/bin/gcc -o fs-mex7e ../dp.o ${ENGINE_OBJS} ../map.o

mexicow0.cgi: mexicow0.o ${MEXICO_OBJS}
	/usr/bin/gcc -o mexicow0.cgi mexicow0.o ${MEXICO_OBJS}

mexicow1.cgi: mexicow1.o ${MEXICO_OBJS}
	/usr/bin/gcc -o mexicow1.cgi mexicow1.o ${MEXICO_OBJS}

mexicow2.cgi: mexicow2.o ${MEXICO_OBJS}
	/usr/bin/gcc -o mexicow2.cgi mexicow2.o ${MEXICO_OBJS}

mexicow3.cgi: mexicow3.o ${MEXICO_OBJS}
	/usr/bin/gcc -o mexicow3.cgi mexicow3.o ${MEXICO_OBJS}

mexicowa.cgi: mexicowa.o ${MEXICO_OBJS}
	/usr/bin/gcc -o mexicowa.cgi mexicowa.o ${MEXICO_OBJS}

mexicowb.cgi: mexicowb.o ${MEXICO_OBJS}
	/usr/bin/gcc -o mexicowb.cgi mexicowb.o ${MEXICO_OBJS}

mexicog.cgi: mexicog.o ${MEXICO_OBJS}
	/usr/bin/gcc -o mexicog.cgi mexicog.o ${MEXICO_OBJS}

mexicotbo.cgi: mexicotbo.o ${MEXICO_OBJS}
	/usr/bin/gcc -o mexicotbo.cgi mexicotbo.o ${MEXICO_OBJS}

mexicop50.cgi: mexicop50.o ${MEXICO_OBJS}
	/usr/bin/gcc -o mexicop50.cgi mexicop50.o ${MEXICO_OBJS}

mexres.cgi: mexres.o ${MEXICO_OBJS}
	/usr/bin/gcc -o mexres.cgi mexres.o ${MEXICO_OBJS}

mexresho.cgi: mexresho.o ${MEXICO_OBJS}
	/usr/bin/gcc -o mexresho.cgi mexresho.o ${MEXICO_OBJS}

mexphoto.cgi: mexphoto.o ${MEXICO_OBJS}
	/usr/bin/gcc -o mexphoto.cgi mexphoto.o ${MEXICO_OBJS}

mexicoch.cgi: mexicoch.o ${MEXICO_OBJS}
	/usr/bin/gcc -o mexicoch.cgi mexicoch.o ${MEXICO_OBJS}

mexicorss.cgi: mexicorss.o ${MEXICO_OBJS}
	/usr/bin/gcc -o mexicorss.cgi mexicorss.o ${MEXICO_OBJS}

offline.cgi: offline.o
	/usr/bin/gcc -o offline.cgi offline.o

mx.cgi: mx.o ${MEXICO_OBJS}
	/usr/bin/gcc -o mx.cgi mx.o ${MEXICO_OBJS}

util.cgi: util.o ${MEXICO_OBJS}
	/usr/bin/gcc -o util.cgi util.o ${MEXICO_OBJS}

p70r1.cgi: p70r1.o ${FS_OBJS}
	/usr/bin/gcc -o p70r1.cgi p70r1.o ${FS_OBJS}

p70r2.cgi: p70r2.o ${FS_OBJS}
	/usr/bin/gcc -o p70r2.cgi p70r2.o ${FS_OBJS}

p70r3.cgi: p70r3.o ${FS_OBJS}
	/usr/bin/gcc -o p70r3.cgi p70r3.o ${FS_OBJS}

p70r4.cgi: p70r4.o ${FS_OBJS}
	/usr/bin/gcc -o p70r4.cgi p70r4.o ${FS_OBJS}

p70r5.cgi: p70r5.o ${FS_OBJS}
	/usr/bin/gcc -o p70r5.cgi p70r5.o ${FS_OBJS}

mx-count.cgi: mx-count.o ${FS_OBJS}
	/usr/bin/gcc -o mx-count.cgi mx-count.o ${FS_OBJS}

map-demo.cgi: map-demo.o ${MEXICO_OBJS}
	/usr/bin/gcc -o map-demo.cgi map-demo.o ${MEXICO_OBJS}

mx-pix.cgi: mx-pix.o ${FS_OBJS}
	/usr/bin/gcc -o mx-pix.cgi mx-pix.o ${FS_OBJS}

mexico.o: mexico.h
mexicow.o: mexico.h
mexicow0.o: mexico.h
mexicow1.o: mexico.h
mexicow2.o: mexico.h
mexicow3.o: mexico.h
mexicowa.o: mexico.h
mexicowb.o: mexico.h
mx.o: mexico.h
mexres.o: mexico.h
map-demo.o: mexico.h
mexicotbo.o: mexico.h
mexicorss.o: mexico.h

deploy-test: 
	ln -f *.cgi ~/sanbachs.net/cgi-bin/mexico

deploy-prod:
	ln -f *.cgi ~/knowmexico.com/cgi-bin

p72.cgi: p72.o ${MEXICO_OBJS}
	/usr/bin/gcc -o p72.cgi p72.o ${MEXICO_OBJS}
