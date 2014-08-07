<?php

/**
* Implementation of hook_default_page_manager_pages().
*/
function multilingual_starterkit_defaults_default_page_manager_pages() {
  $pages = array();
  $page = new stdClass();
  $page->disabled = FALSE; /* Edit this to true to make a default page disabled initially */
  $page->api_version = 1;
  $page->name = 'homepage';
  $page->task = 'page';
  $page->admin_title = 'Homepage';
  $page->admin_description = '';
  $page->path = 'homepage';
  $page->access = array();
  $page->menu = array();
  $page->arguments = array();
  $page->conf = array(
    'admin_paths' => FALSE,
  );
  $page->default_handlers = array();
  $handler = new stdClass();
  $handler->disabled = FALSE; /* Edit this to true to make a default handler disabled initially */
  $handler->api_version = 1;
  $handler->name = 'page_homepage_panel_context';
  $handler->task = 'page';
  $handler->subtask = 'homepage';
  $handler->handler = 'panel_context';
  $handler->weight = 0;
  $handler->conf = array(
    'title' => 'Homepage Panel',
    'no_blocks' => 0,
    'pipeline' => 'ipe',
    'body_classes_to_remove' => '',
    'body_classes_to_add' => '',
    'css_id' => '',
    'css' => '',
    'contexts' => array(),
    'relationships' => array(),
  );
  $display = new panels_display();
  $display->layout = 'threecol_33_34_33_stacked';
  $display->layout_settings = array();
  $display->panel_settings = array(
    'style_settings' => array(
      'default' => NULL,
      'top' => NULL,
      'left' => NULL,
      'middle' => NULL,
      'right' => NULL,
      'bottom' => NULL,
    ),
  );
  $display->cache = array();
  $display->title = '<none>';
  $display->uuid = '4aa2b3ac-a174-4ca3-b260-eb4de2c7a6c7';
  $display->content = array();
  $display->panels = array();
    $pane = new stdClass();
    $pane->pid = 'new-a8700615-71db-4435-af17-946e032668fc';
    $pane->panel = 'left';
    $pane->type = 'views_panes';
    $pane->subtype = 'articles-panel_pane_1';
    $pane->shown = TRUE;
    $pane->access = array();
    $pane->configuration = array();
    $pane->cache = array();
    $pane->style = array(
      'settings' => NULL,
    );
    $pane->css = array();
    $pane->extras = array();
    $pane->position = 0;
    $pane->locks = array();
    $pane->uuid = 'a8700615-71db-4435-af17-946e032668fc';
    $display->content['new-a8700615-71db-4435-af17-946e032668fc'] = $pane;
    $display->panels['left'][0] = 'new-a8700615-71db-4435-af17-946e032668fc';
    $pane = new stdClass();
    $pane->pid = 'new-e5a83f79-0da9-446d-970e-2bf0c2d90b22';
    $pane->panel = 'middle';
    $pane->type = 'views_panes';
    $pane->subtype = 'events-panel_pane_1';
    $pane->shown = TRUE;
    $pane->access = array();
    $pane->configuration = array();
    $pane->cache = array();
    $pane->style = array(
      'settings' => NULL,
    );
    $pane->css = array();
    $pane->extras = array();
    $pane->position = 0;
    $pane->locks = array();
    $pane->uuid = 'e5a83f79-0da9-446d-970e-2bf0c2d90b22';
    $display->content['new-e5a83f79-0da9-446d-970e-2bf0c2d90b22'] = $pane;
    $display->panels['middle'][0] = 'new-e5a83f79-0da9-446d-970e-2bf0c2d90b22';
    $pane = new stdClass();
    $pane->pid = 'new-bfae1101-cd1f-44b5-bd49-97b90630ec9b';
    $pane->panel = 'right';
    $pane->type = 'custom';
    $pane->subtype = 'custom';
    $pane->shown = TRUE;
    $pane->access = array();
    $pane->configuration = array(
      'admin_title' => '',
      'title' => '',
      'body' => '<p><iframe frameborder="0" height="300" src="https://www.google.com/maps/embed?pb=!1m14!1m8!1m3!1d1398.1997841435052!2d-73.5571629!3d45.5020346!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x4cc91a59a404ed59%3A0xfc7cfd3cf1cb6c33!2s300+Rue+du+Saint+Sacrement%2C+Montr%C3%A9al%2C+QC+H2Y+1X4%2C+Canada!5e0!3m2!1sen!2s!4v1407358796892" width="400"></iframe></p>
    ',
      'format' => 'full_html',
      'substitute' => TRUE,
    );
    $pane->cache = array();
    $pane->style = array(
      'settings' => NULL,
    );
    $pane->css = array();
    $pane->extras = array();
    $pane->position = 0;
    $pane->locks = array();
    $pane->uuid = 'bfae1101-cd1f-44b5-bd49-97b90630ec9b';
    $display->content['new-bfae1101-cd1f-44b5-bd49-97b90630ec9b'] = $pane;
    $display->panels['right'][0] = 'new-bfae1101-cd1f-44b5-bd49-97b90630ec9b';
  $display->hide_title = PANELS_TITLE_FIXED;
  $display->title_pane = '0';
  $handler->conf['display'] = $display;
  $page->default_handlers[$handler->name] = $handler;

  $pages['homepage'] = $page;

  return $pages;
}

