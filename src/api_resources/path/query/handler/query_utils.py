import re

class Text_To_Sentance_Array():
    def __init__(self, text, count):
        self.text = text
        self.count = count

    def find_terminated_idcs(self):
        tIdcs = []
        terminators = re.compile('(?s:.)([\\.!?"])(?s:.)')
        matches = re.finditer(terminators, self.text)
    
        for m in matches:
            tIdx = m.start(1)
    
            prev = self.text[tIdx-1]
            term = self.text[tIdx]
            after = self.text[tIdx+1]
    
            if term == '"':
                if after != "\n":
                    continue
    
            if term == after or term == prev:
                continue
    
            if after == "\n":
                tIdx+=1
    
            tIdcs.append(tIdx+1)
    
        return tIdcs
    
    def get_sentances(self):
        splits = []
    
        tIdcs = self.find_terminated_idcs()
    
        if self.count > len(tIdcs):
            splits.append(self.text)
            return splits
    
        splits.append(self.text[:tIdcs[self.count-1]])
    
        tIdxLeft = self.count-1
        tIdxRight = tIdxLeft + self.count
        while tIdxRight < len(tIdcs):
            sIdxLeft = tIdcs[tIdxLeft]
            sIdxRight = tIdcs[tIdxRight]
    
            splits.append(self.text[sIdxLeft:sIdxRight])
            tIdxLeft = tIdxRight
            tIdxRight+=self.count
    
        finalTerminated = tIdcs[tIdxLeft]
    
        if finalTerminated < len(self.text):
            splits.append(self.text[finalTerminated:])
    
        return splits
