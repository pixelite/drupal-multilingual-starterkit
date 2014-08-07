<?php
/**
 * Implements hook_form_system_theme_settings_alter().
 *
 * @param $form
 *   Nested array of form elements that comprise the form.
 * @param $form_state
 *   A keyed array containing the current state of the form.
 */
function pixels_form_system_theme_settings_alter(&$form, &$form_state, $form_id = NULL)  {
  // Work-around for a core bug affecting admin themes. See issue #943212.
  if (isset($form_id)) {
    return;
  }

  $form['pixels_banner'] = array(
    '#type' => 'fieldset',
    '#title' => t('Homepage Banner Settings'),
  );
  $form['pixels_banner']['pixels_banner_title'] = array(
    '#type'          => 'textfield',
    '#title'         => t('Homepage Banner Title'),
    '#default_value' => theme_get_setting('pixels_banner_title'),
    '#description'   => t("The title that will appear below the banner image on the homepage."),
  );
  $form['pixels_banner']['pixels_banner_text'] = array(
    '#type'          => 'textfield',
    '#title'         => t('Homepage Banner Text'),
    '#default_value' => theme_get_setting('pixels_banner_text'),
    '#description'   => t("Longer text below the banner image on the homepage."),
  );
  $form['pixels_banner']['pixels_banner_image_upload'] = array(
    '#type'          => 'file',
    '#title'         => t('Homepage Banner Image'),
    '#default_value' => theme_get_setting('pixels_banner_image_upload'),
    '#upload_validators' => array(
      'file_validate_extensions' => array('gif png jpg jpeg'),
     ),
    '#description'   => t("Upload an image to replace the homepage banner image."),
  );
  $form['pixels_banner']['pixels_banner_image_path'] = array(
    '#type'          => 'hidden',
    '#title'         => t('Homepage Banner Image Path'),
    '#value'         => theme_get_setting('pixels_banner_image_path'),
  );
  $form['pixels_banner']['pixels_secondary_banner_image_upload'] = array(
    '#type'          => 'file',
    '#title'         => t('Secondary Banner Image'),
    '#default_value' => theme_get_setting('pixels_secondary_banner_image_upload'),
    '#upload_validators' => array(
      'file_validate_extensions' => array('gif png jpg jpeg'),
     ),
    '#description'   => t("Upload an image to replace the homepage banner image."),
  );
  $form['pixels_banner']['pixels_secondary_banner_image_path'] = array(
    '#type'          => 'hidden',
    '#title'         => t('Secondary Banner Image Path'),
    '#value'         => theme_get_setting('pixels_secondary_banner_image_path'),
  );
  $form['pixels_text'] = array(
    '#type' => 'fieldset',
    '#title' => t('Other Page Template Settings'),
  );
  $form['pixels_text']['pixels_footer_text'] = array(
    '#type'          => 'textfield',
    '#title'         => t('Footer Text'),
    '#default_value' => theme_get_setting('pixels_footer_text'),
    '#description'   => t('Enter some text for the footer of the website, such as your contact info.'),
  );

  unset($form['themedev']['zen_wireframes']); // We don't need to toggle wireframes on this site.

  $form['#validate'][] = 'pixels_theme_settings_validate';
  $form['#submit'][] = 'pixels_theme_settings_submit';
}

/*
 * Validation of the banner image.
 */
function pixels_theme_settings_validate(&$form, &$form_state) {
  $banner_images = array('pixels_banner_image_upload', 'pixels_secondary_banner_image_upload');
  foreach ($banner_images as $image) {
    // Check for a new uploaded banner image.
    $file = file_save_upload($image);
    if (isset($file)) {
      // File upload was attempted.
      if ($file) {
        // Put the temporary file in form_values so we can save it on submit.
        $form_state['values'][$image] = $file;
      }
      else {
        // File upload failed.
        form_set_error($image, t('The banner image could not be uploaded.'));
      }
    }
  }
}

/*
 * Submission of the theme settings, particularly the banner image path.
 */
function pixels_theme_settings_submit(&$form, &$form_state) {
  $banner_images = array('pixels_banner_image', 'pixels_secondary_banner_image');
  foreach ($banner_images as $image) {
    if ($file = $form_state['values'][$image . '_upload']) {
      $filename = file_unmanaged_copy($file->uri);
      $form_state['values'][$image . '_path'] = $filename;
    }
  }
}

