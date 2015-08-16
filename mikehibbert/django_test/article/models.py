from django.db import models

class Article(models.Model):
    title = models.CharField(max_length=256)
    body = models.TextField()
    pub_date = models.DateTimeField('date published')
    likes = models.IntegerField()

    def __unicode__(self):
        return self.title 

    
