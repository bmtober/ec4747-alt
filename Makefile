
# SPM is a list of spam email files
# HAM is a list of ham email files

SPM=$(shell awk '$$1 == 0 {printf("TRAINING/%s ", $$2)}' SPAMTrain.label)
HAM=$(shell awk '$$1 == 1 {printf("TRAINING/%s ", $$2)}' SPAMTrain.label)

# Count of number or spam and ham documents
ms=$(shell awk '$$1 == 0 {n = n + 1}; END {print n}' SPAMTrain.label)
mh=$(shell awk '$$1 == 1 {n = n + 1}; END {print n}' SPAMTrain.label)

.PRECIOUS: %.text %.body %.tfidf.spam %.tfidf.ham

all: rules.spam rules.ham url document_frequency.spam document_frequency.ham document_similarity.spam document_similarity.ham average_term_frequency.spam average_term_frequency.ham average_term_similarity.spam average_term_similarity.ham


url: $(SPM:%.eml=%.url) $(HAM:%.eml=%.url) 

# Extract the email subject
%.subj: %.eml
	./ExtractSubj.py $< > $@

# Extract the email body
%.body: %.eml
	./ExtractBody.py $< > $@

# Goes thru each file looking for a URL and pulling it out
%.url: %.body
	grep 'http://'  $< >  $@ || :
	grep 'https://' $< >> $@ || :


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

%.term.spam: %.term
	mv $< $@

%.term.ham: %.term
	mv $< $@

# document frequency (number of documents a term appears in)
document_frequency.spam: $(SPM:%.eml=%.term.spam)
	-rm $@
	touch $@
	for f in $^; \
	do \
		echo "computing spam document frequency for $$f"; \
  	vunit $$f > .vunit.s; \
		vsum .vunit.s $@  > .$@; \
		mv .$@ $@; \
	done

document_frequency.ham: $(HAM:%.eml=%.term.ham)
	-rm $@
	touch $@
	for f in $^; \
	do \
		echo "computing ham document frequency for $$f"; \
		vunit $$f > .vunit.h; \
		vsum .vunit.h $@  > .$@; \
		mv .$@ $@; \
	done


# term-frequency/inverse-document frequency
%.tfidf.spam: %.term.spam
	@echo "tf-idf $(ms) $<"
	vtfidf $(ms) $< document_frequency.spam > $@

%.tfidf.ham: %.term.ham
	@echo "tf-idf $(ms) $<"
	vtfidf $(mh) $< document_frequency.ham  > $@


# average term frequency
average_term_frequency.spam: $(SPM:%.eml=%.term.spam)
	-rm $@
	touch $@
	for f in $^; \
	do \
		vsum $$f $@  > .$@; \
		mv .$@ $@; \
	done
	vscale $(shell bc -l <<< "1./$(ms)") $@ > .$@
	mv .$@ $@

average_term_frequency.ham: $(HAM:%.eml=%.term.ham)
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
document_similarity.spam: $(SPM:%.eml=%.tfidf.spam) $(HAM:%.eml=%.tfidf.ham)
	-rm .$@
	touch .$@
	for f in $^; \
	do \
		echo "computing spam cosine similarity for $$f"; \
		printf "%f\t%s\n" $$(vcosine $$f document_frequency.spam) $$f >> .$@; \
	done
	sort -k2 .$@ > $@
    
# cosine similarity for ham documents
document_similarity.ham: $(SPM:%.eml=%.tfidf.spam) $(HAM:%.eml=%.tfidf.ham)
	-rm .$@
	touch .$@
	for f in $^; \
	do \
		echo "computing ham cosine similarity for $$f"; \
		printf "%f\t%s\n" $$(vcosine $$f document_frequency.ham) $$f >> .$@; \
	done
	sort -k2 .$@ > $@


average_term_similarity.spam: $(SPM:%.eml=%.tfidf.spam) $(HAM:%.eml=%.tfidf.ham)
	-rm .$@
	touch .$@
	for f in $^; \
	do \
		echo "computing spam cosine similarity for $$f"; \
		printf "%f\t%s\n" $$(vcosine $$f average_term_frequency.spam) $$f >> .$@; \
	done
	sort -k2 .$@ > $@
    
# cosine similarity for ham documents
average_term_similarity.ham: $(SPM:%.eml=%.tfidf.spam) $(HAM:%.eml=%.tfidf.ham)
	-rm .$@
	touch .$@
	for f in $^; \
	do \
		echo "computing ham cosine similarity for $$f"; \
		printf "%f\t%s\n" $$(vcosine $$f average_term_frequency.ham) $$f >> .$@; \
	done
	sort -k2 .$@ > $@

clean:
	-rm rules.spam rules.ham 
	-rm corpus.spam corpus.ham 
	-rm document_frequency.spam document_frequency.ham
	-rm document_similarity.spam document_similarity.ham document_similarity
	-rm $(SPM:%.eml=%.url)  $(HAM:%.eml=%.url)
	-rm $(SPM:%.eml=%.term) $(HAM:%.eml=%.term)
	-rm $(SPM:%.eml=%.text) $(HAM:%.eml=%.text)
	-rm $(SPM:%.eml=%.tfidf) $(HAM:%.eml=%.tfidf)
	-rm $(SPM:%.eml=%.tfidf.s) $(HAM:%.eml=%.tfidf.h)
	-rm $(SPM:%.eml=%.subj) $(HAM:%.eml=%.subj)
	-rm $(SPM:%.eml=%.body) $(HAM:%.eml=%.body)
	-rm TRAINING/*.spam TRAINING/*.ham


