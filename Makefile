
# File listing ordered pairs contianing class label and document name
LABELS="examples.label"
#LABELS="SPAMTrain.label"

# Directory contain message files
CORPUS="examples"
#CORPUS="TRAINING"

# SPM is a list of spam email files
# HAM is a list of ham email files

SPM=$(shell awk '$$1 == 0 {printf("%s/%s ", $(CORPUS), $$2)}' $(LABELS))
HAM=$(shell awk '$$1 == 1 {printf("%s/%s ", $(CORPUS), $$2)}' $(LABELS))

# Count of number or spam and ham documents
ms=$(words $(SPM))
mh=$(words $(HAM))

threshold ?= 1

.PRECIOUS: %.text %.body %.term %.tfidf

all: rules.spam rules.ham url from report.txt 


url: $(SPM:%.eml=%.url) $(HAM:%.eml=%.url) 

from: $(SPM:%.eml=%.from) $(HAM:%.eml=%.from) 

# Extract the email subject
%.subj: %.eml stopwords.sed
	./ExtractSubj.py $< > $@

# Extract the email body
%.body: %.eml
	./ExtractBody.py $< > $@

# Goes thru each file looking for a URL and pulling it out
%.url: %.body
	grep 'http://'  $< >  $@ || :
	grep 'https://' $< >> $@ || :
	
# Hack out From
%.from: %.eml
	grep 'From:' $< >> $@ || :


# create spam file containing email subject lines
corpus.spam: $(SPM:%.eml=%.subj)
	-rm $@
	touch $@
	for f in $^; \
	do \
		cat $$f | tr '[:cntrl:]' ' ' | sed -f stopwords.sed  >> $@; \
		echo >> $@; \
	done

# create ham file containing email subject lines
corpus.ham: $(HAM:%.eml=%.subj)
	-rm $@
	touch $@
	for f in $^; \
	do \
		cat $$f | tr '[:cntrl:]' ' ' | sed -f stopwords.sed  >> $@; \
		echo >> $@; \
	done

# this was for lab 3
rules.spam: corpus.spam
	python ./lab3.py corpus.spam > rules.spam

rules.ham: corpus.ham
	python ./lab3.py corpus.ham  > rules.ham

#
# term frequency statistics
#
# https://en.wikipedia.org/wiki/Tf-idf
#

# strip out html tags
%.text: %.body
	cat $< | w3m -T text/html -dump > $@

# term frequency (term count per document)
%.term: %.text
	cat $< | perl -0777 -lape 's/\s+/\n/g' | sort | uniq -c | sort -k2 > $@

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

document_frequency.ham: $(HAM:%.eml=%.term)
	-rm $@
	touch $@
	for f in $^; \
	do \
		vunit $$f > .vunit.h; \
		vsum .vunit.h $@  > .$@; \
		mv .$@ $@; \
	done


# term-frequency/inverse-document frequency
%.tfidf.spam: %.term document_frequency.spam
	@echo "tf-idf spam document count $(ms) $<"
	vtfidf $(ms) $< document_frequency.spam > $@

%.tfidf.ham: %.term document_frequency.ham
	@echo "tf-idf ham document count $(mh) $<"
	vtfidf $(mh) $< document_frequency.ham  > $@

%.tfidf: %.tfidf.ham
%.tfidf: %.tfidf.spam
	mv $< $@

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

average_term_frequency.ham: $(HAM:%.eml=%.term)
	-rm $@
	touch $@
	for f in $^; \
	do \
		vsum $$f $@  > .$@; \
		mv .$@ $@; \
	done
	vscale $(shell bc -l <<< "1./$(mh)") $@ > .$@ 
	sort -k2 .$@ > $@
	mv .$@ $@


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


average_term_similarity.spam: $(SPM:%.eml=%.tfidf) $(HAM:%.eml=%.tfidf)
	-rm .$@
	touch .$@
	$(MAKE) average_term_frequency.spam
	for f in $^; \
	do \
		printf "%f\t%s\n" $$(vcosine $$f average_term_frequency.spam) $(basename $$f) >> .$@; \
	done
	sort -k2 .$@ > $@
    
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

%.csv: %.spam %.ham
	# Since spam is listed first above, the joined file below will 
	# three columns: filename, spamminess, and hamminess.
	# The output of awk is: filename, hamminess, spamminess, (h/s)>t ?
	printf "%s\t%s\t%s\t%s\n" "document" "spamminess" "hamminess" "class" > $@
	join -j 2 $^ | awk -v t=$(threshold) '{printf("%s\t%f\t%f\t%i\n", $$1, $$2, $$3, ($$3>$$2*t))}' >> $@

graphs.txt: document_similarity.csv average_term_similarity.csv top_ten_term_similarity.csv
	# draw cluster plot
	R --silent --vanilla < plot.R > $@

samples.txt: $(HAM) $(SPM)
	# show some examples of documents and associated term vectors
	#
	-rm $@
	for f in $^; \
	do \
		head -v -n 20 $$f >> $@; \
	done
	for f in $(^:%.eml=%.term); \
	do \
		echo "==>> $$f <<==" >> $@; \
		sort -nr $$f | head  -n 16  >> $@; \
	done
	for f in $(^:%.eml=%.tfidf); \
	do \
		echo "==>> $$f <<==" >> $@; \
		sort -nr $$f | head  -n 16  >> $@; \
	done

pairs.txt:
	# illustrate term vector dot product and cosine similarity
	#
	echo "==>> dot products <<==" > $@; \
	ls $(CORPUS)/*.term  | pairs | while read a b;do echo -n "vdot $$a $$b = ";vdot $$a $$b;done >> $@
	echo "==>> cosine similarity <<==" >> $@; \
	ls $(CORPUS)/*.term  | pairs | while read a b;do echo -n "vcosine $$a $$b = ";vcosine $$a $$b;done >> $@


report.txt: graphs.txt samples.txt pairs.txt
	# pull together illustrative material for report and presentation
	cat $^ > $@
	head *.csv >> $@


clean:
	-rm rules.spam rules.ham 
	-rm corpus.spam corpus.ham 
	-rm document_frequency.spam document_frequency.ham
	-rm document_similarity.spam document_similarity.ham document_similarity.csv
	-rm average_term_frequency.spam average_term_frequency.ham 
	-rm average_term_similarity.spam average_term_similarity.ham average_term_similarity.csv
	-rm top_ten_term_similarity.spam top_ten_term_similarity.ham top_ten_term_similarity.csv
	-rm pairs.txt graphs.txt samples.txt report.txt
	-rm $(SPM:%.eml=%.url)  $(HAM:%.eml=%.url)
	-rm $(SPM:%.eml=%.term) $(HAM:%.eml=%.term)
	-rm $(SPM:%.eml=%.text) $(HAM:%.eml=%.text)
	-rm $(SPM:%.eml=%.tfidf) $(HAM:%.eml=%.tfidf)
	-rm $(SPM:%.eml=%.subj) $(HAM:%.eml=%.subj)
	-rm $(SPM:%.eml=%.body) $(HAM:%.eml=%.body)
	-rm $(SPM:%.eml=%.from) $(HAM:%.eml=%.from)


