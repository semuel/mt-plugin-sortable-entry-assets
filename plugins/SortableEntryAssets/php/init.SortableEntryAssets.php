<?php

$mt = MT::get_instance();
$ctx = &$mt->context();

$ctx->add_container_tag('entryassets', 'sortable_entry_assets_tag');
$ctx->add_container_tag('pageassets', 'sortable_entry_assets_tag');

require_once("block.mtassets.php");
require_once('class.mt_asset.php');
$asset = new Asset;
$cls = strtolower(get_class($asset));
BaseObject::install_meta($cls, 'blog_id, objectasset_order', 'frog');

function sortable_entry_assets_tag(&$args, $content, &$ctx, &$repeat) {
    if (!isset($content) && !isset($args['sort_by'])) {
        $args['sort_by'] = 'blog_id, objectasset_order';
    }
    return smarty_block_mtassets($args, $content, $ctx, $repeat);
}

?>
