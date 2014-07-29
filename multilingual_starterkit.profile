<?php
/**
 * Implements hook_form_FORM_ID_alter() for install_configure_form().
 *
 * Allows the profile to alter the site configuration form.
 */
function multilingual_starterkit_form_install_configure_form_alter(&$form, $form_state) {
  // Pre-populate the site name with the server name. 
  // Skip this step in the UI. We will override this with i18n variables later.
  $form['site_information']['site_name']['#default_value'] = $_SERVER['SERVER_NAME'];
  $form['site_information']['site_name']['#access'] = FALSE;
}

/**
 * Implement hook_install_tasks().
 *
 * Add steps to the intall tasks to choose languages and provide translations.
 */
function multilingual_starterkit_install_tasks($install_state) {
  return array(
    'multilingual_starterkit_select_languages' => array(
      'display_name' => st('Choose languages'),
      'display' => TRUE,
      'run' => INSTALL_TASK_RUN_IF_NOT_COMPLETED,
      'type' => 'form',
    ),
    'multilingual_starterkit_import_translation' => array(
      'display_name' => st('Set up translations'),
      'display' => TRUE,
      'run' => INSTALL_TASK_RUN_IF_NOT_COMPLETED,
      'type' => 'batch',
    ),
    'multilingual_starterkit_site_info' => array(
      'display_name' => st('Multilingual site info'),
      'display' => TRUE,
      'run' => INSTALL_TASK_RUN_IF_NOT_COMPLETED,
      'type' => 'form',
    ),
    'multilingual_starterkit_sample_content' => array(
      'display_name' => st('Add sample content'),
      'display' => TRUE,
      'run' => INSTALL_TASK_RUN_IF_NOT_COMPLETED,
      'type' => 'normal',
    ),
  );
}

/**
 * Implement hook_install_tasks_alter().
 *
 * Perform actions to set up the site for this profile.
 */
function multilingual_starterkit_install_tasks_alter(&$tasks, $install_state) {
  // Remove core steps for translation imports.
  unset($tasks['install_import_locales']);
  unset($tasks['install_import_locales_remaining']);
}


/**
* Installation step callback.
*
* Provides a form for selecting multiple languages to install.
*
* @param $install_state
*   An array of information about the current installation state.
*/
function multilingual_starterkit_select_languages($form, &$form_state, &$install_state) {
  include_once DRUPAL_ROOT . '/includes/iso.inc';
  $languages = _locale_get_predefined_list();
  $languages_processed = array();
  foreach ($languages as $langcode => $language) {
    $languages_processed[$langcode] = $language[0];
  }

  $form = array();
  $form['multilingual_starterkit_languages'] = array(
    '#title' => t('Choose a language'),
    '#type' => 'checkboxes',
    '#required' => TRUE,
    '#options' => $languages_processed,
  );
  $form['actions'] = array(
    '#type' => 'actions'
  );
  $form['actions']['submit'] = array(
    '#type' => 'submit',
    '#value' => st('Select'),
  );
  return $form;
}


/**
 * Task callback: Choose languages submit.
 *
 * Submit handler for the language selection form. 
 * Adds the languages that were selected using the locale module.
 *
 */

function multilingual_starterkit_select_languages_submit($form, &$form_state) {
  $selected_languages = $form_state['values']['multilingual_starterkit_languages'];

  //List of all the languages that Drupal knows about.
  include_once DRUPAL_ROOT . '/includes/iso.inc';
  $all_languages = _locale_get_predefined_list();

  //List of languages that are already installed.
  include_once DRUPAL_ROOT . '/includes/locale.inc';
  $installed_languages = locale_language_list();

  foreach($selected_languages as $language) {
    if ($language && empty($installed_languages[$language])) {
      $name = isset($all_languages[$language][0]) ? $all_languages[$language][0] : $language;
      $native = isset($all_languages[$language][1]) ? $all_languages[$language][1] : $language;
      $direction = isset($all_languages[$language][2]) ? $all_languages[$language][2] : LANGUAGE_LTR;
      locale_add_language($language, $name, $native, $direction, '', $language, TRUE, FALSE);
    }
  }
}

/**
* Installation step callback.
*
* Imports translations for these from localize.drupal.org using l10n_update.
*
* @param $install_state
*   An array of information about the current installation state.
*/
function multilingual_starterkit_import_translation(&$install_state) {
  // Build batch with l10n_update module.
  $history = l10n_update_get_history();
  module_load_include('check.inc', 'l10n_update');
  $available = l10n_update_available_releases();
  $updates = l10n_update_build_updates($history, $available);

  module_load_include('batch.inc', 'l10n_update');
  $updates = _l10n_update_prepare_updates($updates, NULL, array());
  $batch = l10n_update_batch_multiple($updates, LOCALE_IMPORT_KEEP);
  return $batch;
}

/**
* Installation step callback.
* 
* Allows site admin to enter basic info for the website in each chosen language.
*
* @param $install_state
*   An array of information about the current installation state.
*
*/
function multilingual_starterkit_site_info($form, &$form_state, &$install_state) {
  $form = array();

  include_once DRUPAL_ROOT . '/includes/locale.inc';
  $installed_languages = locale_language_list('name');

  foreach ($installed_languages as $langcode => $language) {
    $form[$langcode] = array(
      '#type' => 'fieldset',
      '#title' => st('%language Info', array('%language' => $language)),
    );
    $form[$langcode]['site_name_' . $langcode] = array(
      '#title' => $language . ' ' . st('Site name'),
      '#type' => 'textfield',
      '#default_value' => st('%language website', array('%language' => $language)),
      '#required' => TRUE,
    );
    $form[$langcode]['site_slogan_' . $langcode] = array(
      '#title' => $language . ' ' . st('Site slogan'),
      '#type' => 'textfield',
      '#default_value' => st('%language multilingual slogan', array('%language' => $language)),
      '#required' => TRUE,
    );
    $form[$langcode]['article_label_' . $langcode] = array(
      '#title' => st('Word for Articles in %language', array('%language' => $language)),
      '#type' => 'textfield',
      '#default_value' => st('Articles'),
      '#required' => TRUE,
    );
    $form[$langcode]['event_label_' . $langcode] = array(
      '#title' => st('Word for Events in %language', array('%language' => $language)),
      '#type' => 'textfield',
      '#default_value' => st('Events'),
      '#required' => TRUE,
    );
  }
  $form['actions'] = array(
    '#type' => 'actions'
  );
  $form['actions']['submit'] = array(
    '#type' => 'submit',
    '#value' => st('Select'),
  );
  return $form;
}


/**
 * Task callback: Multilingual Info Submit
 *
 * Submit handler for the multilingual info form.
 * Assigns multilingual info to variables, and creates translations.
 *
 */
function multilingual_starterkit_site_info_submit($form, &$form_state) {
  include_once DRUPAL_ROOT . '/includes/locale.inc';
  include_once drupal_get_path('module', 'transliteration') . '/transliteration.module';
  $installed_languages = locale_language_list('name');

  foreach ($installed_languages as $langcode => $language) {
    $site_name = $form_state['values']['site_name_' . $langcode];
    $site_slogan = $form_state['values']['site_slogan_' . $langcode];
    $event_label = $form_state['values']['event_label_' . $langcode];
    $article_label = $form_state['values']['article_label_' . $langcode];

    //Set up site name and slogan, which are i18n variables
    variable_realm_set('language', $langcode, 'site_name', $site_name);
    variable_realm_set('language', $langcode, 'site_slogan', $site_slogan);

    //Set up pathauto settings for this language
    variable_set('pathauto_node_article_' . $langcode . '_pattern', strtolower(transliteration_get($article_label)) . '/[node:title]');
    variable_set('pathauto_node_event_' . $langcode . '_pattern', strtolower(transliteration_get($event_label)) . '/[node:title]');

    //Set up translations for 'Articles' and 'Events'
    _multilingual_starterkit_translate_string($langcode, '', 'Articles', $article_label, 'default');
    _multilingual_starterkit_translate_string($langcode, '', 'Events', $event_label, 'default');
  }
}
/**
* Installation step callback.
*
* Adds sample content for each content type.
* Assigns the page to be the front page of the website.
*
* @param $install_state
*   An array of information about the current installation state.
*/
function multilingual_starterkit_sample_content(&$install_state) {
  if ($welcome_node = _multilingual_starterkit_create_node('page')) {
    node_save($welcome_node);
    variable_set('site_frontpage', 'node/' . $welcome_node->nid);
  }
  if ($article_node = _multilingual_starterkit_create_node('article')) {
    node_save($article_node);
  }
  if ($event_node = _multilingual_starterkit_create_node('event')) {
    node_save($event_node);
  }
  _multilingual_starterkit_create_menu_items();
}

/**
 * Helper function to create a multilingual node using entity translation.
 *
 * @param $page_type
 *   The type of node to create.
 */
function _multilingual_starterkit_create_node($page_type) {

  include_once DRUPAL_ROOT . '/includes/locale.inc';
  $installed_languages = locale_language_list('native');

  $node = new stdClass();
  foreach ($installed_languages as $langcode => $language) {
    $node->title_field[$langcode][0]['value'] = 'Title of the ' . $page_type . ' in ' . $language;
    $node->body[$langcode][0]['value'] = 'The body of the node in ' . $language;
    $node->body[$langcode][0]['value'] = 'The body of the node in ' . $language;
    $node->body[$langcode][0]['format'] = 'full_html';
  }
  $node->uid = 1;
  $node->type = $page_type;
  $node->status = 1;
  return $node;
}

/*
 * Helper function to set up menu paths for articles and events Views
 */
function _multilingual_starterkit_create_menu_items() {
  $items = array(
    array(
      'link_title' => st('Home'),
      'link_path' => '<front>',
      'menu_name' => 'main-menu',
      'weight' => 0,
    ),
    array(
      'link_path' => drupal_get_normal_path('articles'),
      'link_title' => st('Articles'),
      'menu_name' => 'main-menu',
      'weight' => 1,
    ),
    array(
      'link_path' => drupal_get_normal_path('events'),
      'link_title' => st('Events'),
      'menu_name' => 'main-menu',
      'weight' => 2,
    ),
  );

  //Create menu items
  foreach ($items as $item) {
    menu_link_save($item);
  }

  // Update the menu router information.
  menu_rebuild();
}

/*
 * Helper function to translate a single string.
 */
function _multilingual_starterkit_translate_string($langcode, $context, $source, $translation, $textgroup) {
  $report = array(
    'skips'=>0,
    'updates'=>0,
    'deletes'=>0,
    'additions'=>0
  ); 
  $mode = LOCALE_IMPORT_OVERWRITE; 
  $location = ''; 

  _locale_import_one_string_db($report, $langcode, $context, $source, $translation, $textgroup, $location, $mode);
            
  // Clear locale cache.
  cache_clear_all('locale:', 'cache', TRUE);
}
