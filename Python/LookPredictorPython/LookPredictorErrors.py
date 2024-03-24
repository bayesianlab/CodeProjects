
class LookPredictorTunerError(Exception):
    def __init__(self, message) -> None:
        super().__init__(message)

class PrepareLookPredictorDataError(Exception):
    def __init__(self, message) -> None:
        self.message = message 
        
class SummarizeResultsError(Exception):
    def __init__(self, message) -> None:
        self.message = message 
        
class ModelError(Exception):
    def __init__(self, message) -> None:
        self.message = message
        
if __name__=='__main__':
    print('Errors')