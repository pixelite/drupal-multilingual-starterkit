Multilingual Starterkit - Install Profile for Drupal
==============================

Comes with all the standard modules used for Drupal multilingual websites, along with the most common configuration settings. Entity translation is used for node and taxonomy term translation.

During the install process, choose which languages to install, and these will automatically be installed and translations imported from localize.drupal.org.

The install profile sets up article and event content types as examples. It also adds Views for these content types.

Usage
================================

Install Drush 5.8 or higher in your development environment
Ensure that you have git installed

Download the make files:
```bash
curl https://raw.githubusercontent.com/pixelite/drupal-multilingual-starterkit/master/build-mulitilingual-starterkit.make -o build-multilingual-starterkit.make
curl https://raw.githubusercontent.com/pixelite/drupal-multilingual-starterkit/master/drupal-org-core.make -o drupal-org-core.make
```

Run the make files using Drush: 

```bash
drush make build-multilingual-starterkit.make
```

This will download the install file and custom modules from this repo. It will also download Drupal core. The contrib modules required for this install profile will be downloaded to sites/all/modules/contrib.



