api = 2
core = 7.x
; Include the definition for how to build Drupal core directly
includes[] = drupal-org-core.make

;Multilingual Starterkit Install Profile
projects[multilingual_starterkit][download][type] = "git"
projects[multilingual_starterkit][download][url] = "https://github.com/pixelite/drupal-multilingual-starterkit"
projects[multilingual_starterkit][download][branch] = "master"
projects[multilingual_starterkit][type] = "profile"
