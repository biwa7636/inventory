# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import models, migrations
import article.models


class Migration(migrations.Migration):

    dependencies = [
        ('article', '0001_initial'),
    ]

    operations = [
        migrations.AddField(
            model_name='article',
            name='thumbnail',
            field=models.FileField(default='default', upload_to=article.models.get_upload_file_name),
            preserve_default=False,
        ),
    ]
