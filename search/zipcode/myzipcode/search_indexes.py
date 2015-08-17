import datetime
from haystack import indexes
from myzipcode.models import Zipcode


class ZipcodeIndex(indexes.SearchIndex, indexes.Indexable):
    my_zip = indexes.CharField(document=True, use_template=True)

    content_auto = indexes.EdgeNgramField(model_attr='my_zip')

    def get_model(self):
        return Zipcode

    def index_queryset(self, using=None):
        """Used when the entire index for model is updated."""
        return self.get_model().objects.all()
