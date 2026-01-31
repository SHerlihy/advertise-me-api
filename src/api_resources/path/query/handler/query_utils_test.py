import unittest
from . import Text_To_Sentance_Array

class TerminatedIdcsShould(unittest.TestCase):
    def test_return_empty_array_for_empty_string(self):
        to_sentances = Text_To_Sentance_Array("", 1)
        terminator_idcs = to_sentances.find_terminated_idcs()

        self.assertEqual(terminator_idcs, [])

    def test_return_empty_array_for_non_terminating_string(self):
        to_sentances = Text_To_Sentance_Array("nio[vron903u90t2niowv", 1)
        terminator_idcs = to_sentances.find_terminated_idcs()

        self.assertEqual(terminator_idcs, [])

    def test_return_empty_array_for_non_terminating_terminators_string(self):
        to_sentances = Text_To_Sentance_Array('vow...vniw"vw"""p', 1)
        terminator_idcs = to_sentances.find_terminated_idcs()

        self.assertEqual(terminator_idcs, [])

class TerminatedIdcsShouldReturnCorrectIdcs(unittest.TestCase):
    def test_for_period_string(self):
        to_sentances = Text_To_Sentance_Array("0123. 67. 101112.", 1)
        terminator_idcs = to_sentances.find_terminated_idcs()

        self.assertEqual(terminator_idcs, [5,9])

    def test_for_punctuation_string(self):
        to_sentances = Text_To_Sentance_Array("012? 5678! 12. 56?", 1)
        terminator_idcs = to_sentances.find_terminated_idcs()

        self.assertEqual(terminator_idcs, [4,10,14])

    def test_for_quotes_string(self):
        to_sentances = Text_To_Sentance_Array('01234 "789"\n2345', 1)
        terminator_idcs = to_sentances.find_terminated_idcs()

        self.assertEqual(terminator_idcs, [12])

    def test_for_newline_string(self):
        to_sentances = Text_To_Sentance_Array("012?\n5678!\n12.\n56?", 1)
        terminator_idcs = to_sentances.find_terminated_idcs()

        self.assertEqual(terminator_idcs, [5,11,15])

    def test_for_excess_string(self):
        sentances = [
            'vavvaniovwip.\n',
            'vavvaniovwip?\n',
            ]

        multi_punctuation = "".join(sentances)

        to_sentances = Text_To_Sentance_Array(multi_punctuation, 1)
        terminator_idcs = to_sentances.find_terminated_idcs()

        self.assertEqual(terminator_idcs, [14, 28])

class SplitByLineCountShouldReturnStringArray(unittest.TestCase):
    def test_for_single_strings(self):
        sentances = [
            'vavvaniovwip.\n',
            'vavvaniovwip?\n',
            'vavvaniovwip!\n',
            'vavvanio "vwip"\n',
            'vavvaniovwip!\n',
            'vavvaniovwip?\n'
            ]
        multi_punctuation = "".join(sentances)

        to_sentances = Text_To_Sentance_Array(multi_punctuation, 1)
        segments = to_sentances.get_sentances()

        self.assertEqual(len(segments), len(sentances))

        self.assertEqual(segments, sentances)

    def test_for_double_strings(self):
        sentances = [
            'vavvaniovwip.\n',
            'vavvaniovwip?\n',
            'vavvaniovwip!\n',
            'vavvanio "vwip"\n',
            'vavvaniovwip!\n',
            'vavvaniovwip?\n'
            ]
        multi_punctuation = "".join(sentances)

        to_sentances = Text_To_Sentance_Array(multi_punctuation, 2)
        segments = to_sentances.get_sentances()
    
        self.assertEqual(len(segments), 3)
    
        self.assertEqual(segments, [
            sentances[0]+sentances[1],
            sentances[2]+sentances[3],
            sentances[4]+sentances[5]
            ])

    def test_for_triple_strings(self):
        sentances = [
            'vavvaniovwip.\n',
            'vavvaniovwip?\n',
            'vavvaniovwip!\n',
            'vavvanio "vwip"\n',
            'vavvaniovwip!\n',
            'vavvaniovwip?\n'
            ]
        multi_punctuation = "".join(sentances)

        to_sentances = Text_To_Sentance_Array(multi_punctuation, 3)
        segments = to_sentances.get_sentances()
    
        self.assertEqual(len(segments), 2)
    
        self.assertEqual(segments, [
            sentances[0]+sentances[1]+sentances[2],
            sentances[3]+sentances[4]+sentances[5]
            ])

    def test_for_underfill(self):
        sentances = [
            'vavvaniovwip.\n',
            'vavvaniovwip?\n'
            ]
        multi_punctuation = "".join(sentances)

        to_sentances = Text_To_Sentance_Array(multi_punctuation, 3)
        segments = to_sentances.get_sentances()
    
        self.assertEqual(len(segments), 1)
    
        self.assertEqual(segments, [
            sentances[0]+sentances[1]
            ])

    def test_for_overfill(self):
        sentances = [
            'vavvaniovwip.\n',
            'vavvaniovwip?\n',
            'vavvaniovwip!\n',
            'vavvanio "vwip"\n',
            ]
        multi_punctuation = "".join(sentances)

        to_sentances = Text_To_Sentance_Array(multi_punctuation, 3)
        segments = to_sentances.get_sentances()
    
        self.assertEqual(len(segments), 2)
    
        self.assertEqual(segments, [
            sentances[0]+sentances[1]+sentances[2],
            sentances[3]
            ])
