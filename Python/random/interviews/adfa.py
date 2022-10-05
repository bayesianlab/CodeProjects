import numpy as np
import nltk


class TFIDF:
    def term_frequency(self, term, sentence):
        # please use nltk.word_tokenize
        wlist = nltk.word_tokenize(sentence)
        wfreq = {}
        for w in wlist:
            wfreq(w)
    
        pass

    def inverse_document_frequency(self, term, corpus):
        # please use nltk.word_tokenize
        pass

    def tfidf(self, term, sentence, corpus):
        pass



test = 'the quick brown fox jumps over the lazy dog'
x = TFIDF()
term = 'quick'
x.term_frequency(term, test)