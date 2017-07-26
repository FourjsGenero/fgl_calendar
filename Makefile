TOP=../../..

BINS=\
 fglcalendar.42m\
 fglcalendar_demo.42m\
 fglcalendar_demo.42f

all: $(BINS) doc

run:: $(BINS)
	fglrun fglcalendar_demo

doc:
	fglcomp --build-doc fglcalendar.4gl
	mv fglcalendar.html docs

fglcalendar.42m: fglcalendar.4gl
	fglcomp -M fglcalendar.4gl

fglcalendar_demo.42m: fglcalendar_demo.4gl
	fglcomp -M fglcalendar_demo.4gl

fglcalendar_demo.42f: fglcalendar_demo.per
	fglform -M fglcalendar_demo.per

fglcalendar_demo.gar: $(BINS)
	fglgar gar --application fglcalendar_demo.42m -o fglcalendar_demo.gar

fglcalendar_demo.war: fglcalendar_demo.gar
	fglgar war --input-gar fglcalendar_demo.gar --output fglcalendar_demo.war

runjgas: fglcalendar_demo.war
	fglgar run --war fglcalendar_demo.war

clean::
	rm -f *.42m *.42f *.gar *.war fglcalendar.html fglcalendar.xa
