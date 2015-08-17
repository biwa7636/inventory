from django.db import models
from django.contrib.auth.models import User


class Zipcode(models.Model):
    my_zip = models.CharField(max_length=200)
    my_type = models.TextField()
    my_primary_city = models.TextField()
    my_state = models.TextField()
    my_county = models.TextField()

    def __unicode__(self):
        return self.my_zip
