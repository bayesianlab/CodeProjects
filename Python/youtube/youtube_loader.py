__author__ = 'dillonflannery-valadez'

import pafy


def download_video():
    url = raw_input("Input or paste URL: ")
    vid = pafy.new(url)
    best = vid.getbest()
    return best.download()

download_video()