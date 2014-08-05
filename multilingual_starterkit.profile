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
    'multilingual_starterkit_sample_content' => array(
      'display_name' => st('Add sample content'),
      'display' => TRUE,
      'run' => INSTALL_TASK_RUN_IF_NOT_COMPLETED,
      'type' => 'normal',
    ),
    'multilingual_starterkit_site_info' => array(
      'display_name' => st('Multilingual site info'),
      'display' => TRUE,
      'run' => INSTALL_TASK_RUN_IF_NOT_COMPLETED,
      'type' => 'form',
    ),
    'multilingual_starterkit_sample_webforms' => array(
      'display_name' => st('Multilingual webforms'),
      'display' => TRUE,
      'run' => INSTALL_TASK_RUN_IF_NOT_COMPLETED,
      'type' => 'form',
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
      '#default_value' => st('!language website', array('%language' => $language)),
      '#required' => TRUE,
    );
    $form[$langcode]['site_slogan_' . $langcode] = array(
      '#title' => $language . ' ' . st('Site slogan'),
      '#type' => 'textfield',
      '#default_value' => st('!language multilingual slogan', array('%language' => $language)),
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

    //Set up URL aliases for the Views
    _multilingual_starterkit_create_url_alias('articles', strtolower(transliteration_get($article_label)), $langcode);
    _multilingual_starterkit_create_url_alias('events', strtolower(transliteration_get($event_label)), $langcode);

    //Add menu items for 'articles' and 'events' Views. It's not possible to
    //use the alias for these menu items due to issue:
    //https://api.drupal.org/api/drupal/includes%21menu.inc/function/menu_link_save/7
    _multilingual_starterkit_create_menu_item($langcode, 'articles', $article_label, 0, 0);
    _multilingual_starterkit_create_menu_item($langcode, 'events', $event_label, 0, 0);

    // Update the menu router information.
    menu_rebuild();
  }

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
function multilingual_starterkit_sample_webforms($form, &$form_state, &$install_state) {
  $form = array();

  include_once DRUPAL_ROOT . '/includes/locale.inc';
  $installed_languages = locale_language_list('name');

  foreach ($installed_languages as $langcode => $language) {
    $form[$langcode] = array(
      '#type' => 'fieldset',
      '#title' => st('%language Webform Settings', array('%language' => $language)),
    );
    $form[$langcode]['contact_form_title_' . $langcode] = array(
      '#title' => st('Translation of "Contact Us" in %language', array('%language' => $language)),
      '#type' => 'textfield',
      '#default_value' => st('Contact Us'),
      '#required' => TRUE,
    );
    $form[$langcode]['contact_form_name_label_' . $langcode] = array(
      '#title' => st('Translation of "Your name" in %language', array('%language' => $language)),
      '#type' => 'textfield',
      '#default_value' => st('Your name'),
      '#required' => TRUE,
    );
    $form[$langcode]['contact_form_email_label_' . $langcode] = array(
      '#title' => st('Translation of "Your email" in %language', array('%language' => $language)),
      '#type' => 'textfield',
      '#default_value' => st('Your email'),
      '#required' => TRUE,
    );
    $form[$langcode]['contact_form_message_label_' . $langcode] = array(
      '#title' => st('Translation of "Message" in %language', array('%language' => $language)),
      '#type' => 'textfield',
      '#default_value' => st('Message'),
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
function multilingual_starterkit_sample_webforms_submit($form, &$form_state) {
  include_once DRUPAL_ROOT . '/includes/locale.inc';

  //Create a webform in each language (this uses content translation)
  $installed_languages = locale_language_list();
  $default_language =  language_default()->language;

  //Create the webform in the default language
  $default_webform = _multilingual_starterkit_create_webform($default_language, $form_state['values']);
  node_save($default_webform);

  //Set the translation node ID (tnid) to be the same as the node ID.
  //Running node_save again here causes an issue with webform components not having the correct ID set.
  db_update('node')
    ->fields(array(
      'tnid' => $default_webform->nid
      ))
    ->condition('nid', $default_webform->nid)
    ->execute();

  //Create a path translation set between the webform paths. TODO: Figure out why this doesn't work.
  db_insert('i18n_translation_set')
    ->fields(array(
      'type' => 'menu_link',
      'created' => time(),
      'changed' => time(),
      'status' => 0,
      ))
    ->execute();

  _multilingual_starterkit_create_menu_item($default_language, 'node/' . $default_webform->nid, $form_state['values']['contact_form_title_' . $default_language], 10, 1);

  //Create webform translation nodes
  foreach ($installed_languages as $langcode => $language) {
    if ($langcode != $default_language) {
      $webform = _multilingual_starterkit_create_webform($langcode, $form_state['values']);
      $webform->tnid = $default_webform->nid;
      node_save($webform);
      _multilingual_starterkit_create_menu_item($langcode, 'node/' . $webform->nid, $form_state['values']['contact_form_title_' . $langcode], 10, 1);
    }
  }
  menu_rebuild();

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
  //Create a page and set it to be the homepage of the website
  if ($welcome_node = _multilingual_starterkit_create_node('page')) {
    variable_set('site_frontpage', 'node/' . $welcome_node->nid);
  }

  //Create an article and event node
  $article_node = _multilingual_starterkit_create_node('article');
  $event_node = _multilingual_starterkit_create_node('event');

}

/**
 * Helper function to create a multilingual node using entity translation.
 *
 * @param $page_type
 *   The type of node to create.
 */
function _multilingual_starterkit_create_node($page_type) {

  $installed_languages = locale_language_list('native');
  $default_language =  language_default()->language;

  $node = new stdClass();
  $node->uid = 1;
  $node->type = $page_type;
  $node->status = 1;

  foreach ($installed_languages as $langcode => $language) {
    $node->title_field[$langcode][0]['value'] = 'Title of the ' . $page_type . ' in ' . $language;
    $node->body[$langcode][0]['value'] = 'The body of the node in ' . $language;
    $node->body[$langcode][0]['value'] = 'The body of the node in ' . $language;
    $node->body[$langcode][0]['format'] = 'full_html';

    $handler = entity_translation_get_handler('node', $node);

    //Set the source language to the default language, unless the content is in the default language
    $source = ($default_language == $langcode) ? '' : $default_language;

    $translation = array(
      'translate' => 0,
      'status' => 1,
      'language' => $langcode,
      'source' => $source,
    );
    $handler->setTranslation($translation, $node);
  }

  if ($page_type == 'event') {
    // Set the event date to be one week from now
    $node->field_date['und'][0]['value'] = time() + 604800;
  }

  node_save($node);
  return $node;
}

function _multilingual_starterkit_create_webform($langcode, $values) {
  $title = $values['contact_form_title_' . $langcode];
  $name = $values['contact_form_name_label_' . $langcode];
  $email = $values['contact_form_email_label_' . $langcode];
  $message = $values['contact_form_message_label_' . $langcode];

  $node = new stdClass();
  $node->uid = 1;
  $node->type = 'webform';
  $node->status = 1;
  $node->title = $title;
  $node->language = $langcode;

  //Add name, email, message fields
  $components = array(
    array(
      'form_key' => 'your_name',
      'name' => $name,
      'type' => 'textfield',
    ),
    array(
      'form_key' => 'your_email',
      'name' => $email,
      'type' => 'email',
    ),
    array(
      'form_key' => 'message',
      'name' => $message,
      'type' => 'textarea',
    ),
  );
  include_once DRUPAL_ROOT . '/sites/all/modules/contrib/webform/includes/webform.components.inc';
  foreach($components as &$component) {
      webform_component_defaults($component);
  }
  // Setup notification email.
  $emails = array(
    array(
      'email' => variable_get('site_mail', ''),
      'subject' => 'default',
      'from_name' => 'default',
      'from_address' => 'default',
      'template' => 'default',
      'excluded_components' => array(),
    ),
  );
  // Attach the webform to the node.
  $node->webform = array(
    'confirmation' => '',
    'confirmation_format' => NULL,
    'redirect_url' => '<confirmation>',
    'status' => '1',
    'block' => '0',
    'teaser' => '0',
    'allow_draft' => '0',
    'auto_save' => '0',
    'submit_notice' => '1',
    'submit_text' => '',
    'submit_limit' => '-1', // User can submit more than once.
    'submit_interval' => '-1',
    'total_submit_limit' => '-1',
    'total_submit_interval' => '-1',
    'record_exists' => TRUE,
    'roles' => array(
      0 => '1', // Anonymous user can submit this webform.
    ),
    'emails' => $emails,
    'components' => $components,
  );
  return $node;
}

/*
 * Helper function to set up menu links for articles and events Views
 */
function _multilingual_starterkit_create_menu_item($langcode, $link_path, $link_title, $weight, $tsid) {

  $item = array(
    'link_path' => $link_path,
    'link_title' => $link_title,
    'menu_name' => 'main-menu',
    'language' => $langcode,
    'customized' => 1,
    'weight' => $weight,
    'i18n_tsid' => $tsid,
  );
  menu_link_save($item);

}

/*
 * Helper function to set up url aliases.
 */
function _multilingual_starterkit_create_url_alias($source, $alias, $langcode) {

  db_insert('url_alias')
    ->fields(array(
      'source' => $source, 
      'alias' => $alias,
      'language' => $langcode,
    ))
    ->execute();

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
