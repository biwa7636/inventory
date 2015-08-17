from django.db import models
from time import time

def get_upload_file_name(instance, filename):
	return "uploaded_files/{0}_{1}".format(str(time()).replace('.', '_'), filename)

class Article(models.Model):
    title = models.CharField(max_length=256)
    body = models.TextField()
    pub_date = models.DateTimeField('date published')
    likes = models.IntegerField()
    thumbnail = models.FileField(upload_to=get_upload_file_name)

    def __unicode__(self):
        return self.title 



