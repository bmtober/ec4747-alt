
# SPM is a list of spam email files
# HAM is a list of ham email files

SPM=$(shell awk '$$1 == 0 {printf("TRAINING/%s ", $$2)}' SPAMTrain.label)
HAM=$(shell awk '$$1 == 1 {printf("TRAINING/%s ", $$2)}' SPAMTrain.label)

# Count of number or spam and ham documents
ms=$(shell awk '$$1 == 0 {n = n + 1}; END {print n}' SPAMTrain.label)
mh=$(shell awk '$$1 == 1 {n = n + 1}; END {print n}' SPAMTrain.label)

.PRECIOUS: %.text %.body %.tfidf 

all: rules.spam rules.ham url document_frequency.spam document_frequency.ham document_similarity 

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
	trap 'rm .vunit.s' EXIT
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
	trap 'rm .vunit.h' EXIT
	for f in $^; \
	do \
		echo "computing ham document frequency for $$f"; \
		vunit $$f > .vunit.h; \
		vsum .vunit.h $@  > .$@; \
		mv .$@ $@; \
	done


# term-frequency/inverse-document frequency
%.tfidf.spam: %.term.spam
	vtfidf $(ms) $< document_frequency.spam > $@

%.tfidf.ham: %.term.ham
	vtfidf $(mh) $< document_frequency.ham  > $@

%.tfidf: %.tfidf.spam %.tfidf.ham
	mv $< $@

# cosine similarity for spam documents
document_similarity.spam: $(SPM:%.eml=%.tfidf.spam)
	-rm $@
	touch $@
	for f in $^; \
	do \
		echo "computing spam cosine similarity for $$f"; \
		vcosine $$f document_frequency.spam; \
	done
    
# cosine similarity for ham documents
document_similarity.ham: $(HAM:%.eml=%.tfidf.ham)
	-rm $@
	touch $@
	for f in $^; \
	do \
		echo "computing ham cosine similarity for $$f"; \
		vcosine $$f document_frequency.ham; \
	done

# cosine similarity for spam documents
document_similarity: document_similarity.spam document_similarity.ham 
	sort -k2 $^ > $@


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


