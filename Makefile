
# File listing ordered pairs contianing class label and document name
#LABELS?="examples.label"
LABELS?="SPAMTrain.label"

# Directory contain message files
#CORPUS?="examples"
CORPUS?="TRAINING"

# SPM is a list of spam email files
# HAM is a list of ham email files

SPM=$(shell awk '$$1 == 0 {printf("%s/%s ", $(CORPUS), $$2)}' $(LABELS))
HAM=$(shell awk '$$1 == 1 {printf("%s/%s ", $(CORPUS), $$2)}' $(LABELS))

# Count of number or spam and ham documents
ms=$(words $(SPM))
mh=$(words $(HAM))
mu=$(words $(HAM) $(SPM))

threshold ?= 1

.PRECIOUS: %.text %.body %.term %.tfidf %.csv %.class

all: rules.spam rules.ham url from report

report: graphs.txt samples.txt pairs.txt
	@echo -n "Finished '$@' target at"
	@date

graphs.txt: document_similarity.csv average_term_similarity.csv top_ten_term_similarity.csv average_tfidf_similarity.csv
	# draw cluster plot
	R --silent --vanilla < plot.R > $@
	@echo -n "Finished '$@' target at"
	@date


# show some examples of documents and associated term vectors
samples.txt: $(HAM) $(SPM)
	-rm $@
	for f in $^; \
	do \
		head -v -n 20 $$f >> $@; \
	done
	for f in $(^:%.eml=%.term); \
	do \
		echo "==>> $$f <<==" >> $@; \
		sort -nr $$f | head  -n 40  >> $@; \
	done
	for f in $(^:%.eml=%.tfidf); \
	do \
		echo "==>> $$f <<==" >> $@; \
		sort -nr $$f | head  -n 40  >> $@; \
	done
	@echo -n "Finished '$@' target at"
	@date

pairs.txt:
	# illustrate term vector dot product and cosine similarity
	# limit to 5 because doing all would take forever
	# since it is O(n^2) 
	echo "==>> dot products <<==" > $@; \
	ls $(CORPUS)/*.term | head -n 5 | pairs | while read a b;do echo -n "vdot $$a $$b = ";vdot $$a $$b;done >> $@
	echo "==>> cosine similarity <<==" >> $@; \
	ls $(CORPUS)/*.term | head -n 5 | pairs | while read a b;do echo -n "vcosine $$a $$b = ";vcosine $$a $$b;done >> $@
	@echo -n "Finished '$@' target at"
	@date


url: $(SPM:%.eml=%.url) $(HAM:%.eml=%.url) 
	@echo -n "Finished '$@' target at"
	@date

from: $(SPM:%.eml=%.from) $(HAM:%.eml=%.from) 
	@echo -n "Finished '$@' target at"
	@date

# Hack out From
%.from: %.eml
	grep 'From:' $< >> $@ || :

# Goes thru each file looking for a URL and pulling it out
%.url: %.body
	grep 'http://'  $< >  $@ || :
	grep 'https://' $< >> $@ || :
	
# Extract the email body
%.body: %.eml
	./ExtractBody.py $< > $@


# this was for lab 3
rules.spam: subjects.spam
	python ./lab3.py subjects.spam > rules.spam

rules.ham: subjects.ham
	python ./lab3.py subjects.ham  > rules.ham


# create spam file containing email subject lines
subjects.spam: $(SPM:%.eml=%.subj)
	-rm $@
	touch $@
	for f in $^; \
	do \
		cat $$f | tr '[:cntrl:]' ' ' | sed -f stopwords.sed  >> $@; \
		echo >> $@; \
	done
	@echo -n "Finished '$@' target at"
	@date

# create ham file containing email subject lines
subjects.ham: $(HAM:%.eml=%.subj)
	-rm $@
	touch $@
	for f in $^; \
	do \
		cat $$f | tr '[:cntrl:]' ' ' | sed -f stopwords.sed  >> $@; \
		echo >> $@; \
	done
	@echo -n "Finished '$@' target at"
	@date

# Extract the email subject
%.subj: %.eml stopwords.sed
	./ExtractSubj.py $< > $@

#
# term frequency statistics
#
# https://en.wikipedia.org/wiki/Tf-idf
#

acc: document_similarity.acc average_term_similarity.acc top_ten_term_similarity.acc average_tfidf_similarity.acc
	@echo -n "Finished '$@' target at"
	@date

%.acc: %.csv
	# compute performance 
	body $< | awk -v t=$(threshold) '{m00=m00+($$5==0 && $$4==0)}; {m01=m01+($$5==0 && $$4==1)}; {m10=m10+($$5==1 && $$4==0)}; {m11=m11+($$5==1 && $$4==1)}; END {print("$<", m00, m01, m10, m11, (m00+m11)/NR, t)}' >> $@

%.csv: %.spam %.ham
	# Since spam is listed first above, the joined file below will 
	# three columns: filename, spamminess, and hamminess.
	# The output of awk is: filename, hamminess, spamminess, (h/s)>t ?
	-rm $(@:%.csv=%.class)
	$(MAKE)	$(@:%.csv=%.class)
	printf "%s\t%s\t%s\t%s\t%s\t%s\n" "document" "spamminess" "hamminess" "prediction" "class" "color" > $@
	join -j 2 $^ | join - $(@:%.csv=%.class) | awk -v t=$(threshold) '{printf("%s\t%f\t%f\t%i\t%i\t%s\n", $$1, $$2, $$3, ($$3>$$2*t), $$4, $$4==1?"green":"red")}' >> $@

%.class: 
	cat $(LABELS) | sed -e 's/\.eml/\.tfidf/'| awk '{printf("%s/%s\t%d\n", $(CORPUS), $$2, $$1)}' > $@
	

# cosine similarity for spam documents
document_similarity.spam: $(SPM:%.eml=%.tfidf) $(HAM:%.eml=%.tfidf)
	-rm .$@
	touch .$@
	$(MAKE) document_frequency.spam
	for f in $^; \
	do \
		printf "%f\t%s\n" $$(vcosine $$f document_frequency.spam) $(basename $(notdir $$f)) >> .$@; \
	done
	sort -k2 .$@ > $@
	@echo -n "Finished '$@' target at"
	@date
    
# cosine similarity for ham documents
document_similarity.ham: $(SPM:%.eml=%.tfidf) $(HAM:%.eml=%.tfidf)
	-rm .$@
	touch .$@
	$(MAKE) document_frequency.ham
	for f in $^; \
	do \
		printf "%f\t%s\n" $$(vcosine $$f document_frequency.ham) $(basename $$f) >> .$@; \
	done
	sort -k2 .$@ > $@
	@echo -n "Finished '$@' target at"
	@date


average_term_similarity.spam: $(SPM:%.eml=%.tfidf) $(HAM:%.eml=%.tfidf)
	-rm .$@
	touch .$@
	$(MAKE) average_term_frequency.spam
	for f in $^; \
	do \
		printf "%f\t%s\n" $$(vcosine $$f average_term_frequency.spam) $(basename $$f) >> .$@; \
	done
	sort -k2 .$@ > $@
	@echo -n "Finished '$@' target at"
	@date
    
# cosine similarity for ham documents
average_term_similarity.ham: $(SPM:%.eml=%.tfidf) $(HAM:%.eml=%.tfidf)
	-rm .$@
	touch .$@
	$(MAKE) average_term_frequency.ham
	for f in $^; \
	do \
		printf "%f\t%s\n" $$(vcosine $$f average_term_frequency.ham) $(basename $$f) >> .$@; \
	done
	sort -k2 .$@ > $@
	@echo -n "Finished '$@' target at"
	@date

# cosine similarity for ham documents
average_tfidf_similarity.ham: $(SPM:%.eml=%.tfidf) $(HAM:%.eml=%.tfidf)
	-rm .$@
	touch .$@
	$(MAKE) average_tfidf_frequency.ham
	for f in $^; \
	do \
		printf "%f\t%s\n" $$(vcosine $$f average_tfidf_frequency.ham) $(basename $$f) >> .$@; \
	done
	sort -k2 .$@ > $@
	@echo -n "Finished '$@' target at"
	@date

average_tfidf_similarity.spam: $(SPM:%.eml=%.tfidf) $(HAM:%.eml=%.tfidf)
	-rm .$@
	touch .$@
	$(MAKE) average_tfidf_frequency.spam
	for f in $^; \
	do \
		printf "%f\t%s\n" $$(vcosine $$f average_tfidf_frequency.spam) $(basename $$f) >> .$@; \
	done
	sort -k2 .$@ > $@
	@echo -n "Finished '$@' target at"
	@date
    
top_ten_term_similarity.spam: $(SPM:%.eml=%.tfidf) $(HAM:%.eml=%.tfidf)
	-rm .$@
	touch .$@
	$(MAKE) average_term_frequency.spam
	for f in $^; \
	do \
		sort -n $$f | head -100 | sort -k 2 > .top_ten.tfidf ; \
		printf "%f\t%s\n" $$(vcosine .top_ten.tfidf average_term_frequency.spam) $(basename $$f) >> .$@; \
	done
	sort -k2 .$@ > $@
	@echo -n "Finished '$@' target at"
	@date
    
# cosine similarity for ham documents
top_ten_term_similarity.ham: $(SPM:%.eml=%.tfidf) $(HAM:%.eml=%.tfidf)
	-rm .$@
	touch .$@
	$(MAKE) average_term_frequency.ham
	for f in $^; \
	do \
		sort -n $$f | head -100 | sort -k 2 > .top_ten.tfidf ; \
		printf "%f\t%s\n" $$(vcosine .top_ten.tfidf average_term_frequency.ham) $(basename $$f) >> .$@; \
	done
	sort -k2 .$@ > $@
	@echo -n "Finished '$@' target at"
	@date

# document frequency (number of documents a term appears in)
document_frequency.spam: $(SPM:%.eml=%.term)
	-rm $@
	touch $@
	for f in $^; \
	do \
  	vunit $$f > .vunit.s; \
		vsum .vunit.s $@  > .$@; \
		mv .$@ $@; \
	done
	@echo -n "Finished '$@' target at"
	@date

document_frequency.ham: $(HAM:%.eml=%.term)
	-rm $@
	touch $@
	for f in $^; \
	do \
		vunit $$f > .vunit.h; \
		vsum .vunit.h $@  > .$@; \
		mv .$@ $@; \
	done
	@echo -n "Finished '$@' target at"
	@date


# average term frequency
average_term_frequency.spam: $(SPM:%.eml=%.term)
	-rm $@
	touch $@
	for f in $^; \
	do \
		vsum $$f $@  > .$@; \
		mv .$@ $@; \
	done
	vscale $(shell bc -l <<< "1./$(ms)") $@ > .$@
	mv .$@ $@
	@echo -n "Finished '$@' target at"
	@date

average_term_frequency.ham: $(HAM:%.eml=%.term)
	-rm $@
	touch $@
	for f in $^; \
	do \
		vsum $$f $@  > .$@; \
		mv .$@ $@; \
	done
	vscale $(shell bc -l <<< "1./$(mh)") $@ > .$@ 
	mv .$@ $@
	@echo -n "Finished '$@' target at"
	@date

# average tfidf frequency
average_tfidf_frequency.spam: $(SPM:%.eml=%.tfidf)
	-rm $@
	touch $@
	for f in $^; \
	do \
		vsum $$f $@  > .$@; \
		mv .$@ $@; \
	done
	vscale $(shell bc -l <<< "1./$(ms)") $@ > .$@
	mv .$@ $@
	@echo -n "Finished '$@' target at"
	@date

average_tfidf_frequency.ham: $(HAM:%.eml=%.tfidf)
	-rm $@
	touch $@
	for f in $^; \
	do \
		vsum $$f $@  > .$@; \
		mv .$@ $@; \
	done
	vscale $(shell bc -l <<< "1./$(mh)") $@ > .$@ 
	mv .$@ $@
	@echo -n "Finished '$@' target at"
	@date


# term-frequency/inverse-document frequency
%.tfidf: %.term document_frequency.uber
	@echo "tf-idf spam document count $(mu) $<"
	vtfidf $(mu) $< document_frequency.uber > $@

document_frequency.uber: document_frequency.spam document_frequency.ham 
	vsum $^  > .$@; \
	vscale $(shell bc -l <<< "1./$(mu)") .$@ | sort -k2 .$@ > $@
	@echo -n "Finished '$@' target at"
	@date


# strip out html tags
%.text: %.body
	cat $< | w3m -T text/html -dump > $@

# term frequency (term count per document)
%.term: %.text
	cat $< | tr '[:punct:]' ' ' | perl -0777 -lape 's/\s+/\n/g' | sort | uniq -c | sort -k2 > $@


clean:
	-rm document_similarity.*
	-rm top_ten_term_similarity.*
	-rm average_term_similarity.*
	-rm average_tfidf_similarity.*
	-rm pairs.txt graphs.txt samples.txt

clean-freq: clean
	-rm document_frequency.*
	-rm top_ten_term_frequency.*
	-rm average_term_frequency.*
	-rm average_tfidf_frequency.*

clean-all: clean-freq
	-rm rules.*
	-rm subjects.*
	-rm $(SPM:%.eml=%.url)  $(HAM:%.eml=%.url)
	-rm $(SPM:%.eml=%.term) $(HAM:%.eml=%.term)
	-rm $(SPM:%.eml=%.text) $(HAM:%.eml=%.text)
	-rm $(SPM:%.eml=%.tfidf) $(HAM:%.eml=%.tfidf)
	-rm $(SPM:%.eml=%.subj) $(HAM:%.eml=%.subj)
	-rm $(SPM:%.eml=%.body) $(HAM:%.eml=%.body)
	-rm $(SPM:%.eml=%.from) $(HAM:%.eml=%.from)


