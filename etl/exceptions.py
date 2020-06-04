class Error(Exception):
    """Base class for other exceptions"""
    pass

class AlreadyProcessedError(Error):
    """File Already Processed"""
    pass
