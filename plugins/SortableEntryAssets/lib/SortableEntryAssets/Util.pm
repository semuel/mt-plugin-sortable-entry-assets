package SortableEntryAssets::Util;

use strict;

require MT;
require MT::Asset;
require MT::ObjectAsset;

sub MT::Asset::entryasset_order {
    my $self = shift;
    return 1 unless exists $self->{entryasset_order};
    return $self->{entryasset_order};
}

sub assets_tag {
    my ( $ctx, $args, $cond ) = @_;
    if (exists $args->{sort_by}) {
        my $result = $ctx->super_handler( $args, $cond );
        return $ctx->error( $ctx->errstr )
            unless defined $result;
        return $result;
    }

    my $e = $ctx->stash('entry')
        or return $ctx->_no_entry_error();
    require MT::ObjectAsset;
    my @assets = MT::Asset->load(
        { class => '*' },
        {   join => MT::ObjectAsset->join_on(
                undef,
                {   asset_id  => \'= asset_id',
                    object_ds => 'entry',
                    object_id => $e->id
                },
                {
                    sort      => 'order', # preserve custom sorting order
                    direction => 'ascend',
                }
            )
        }
    );
    return $ctx->_hdlr_pass_tokens_else(@_) unless @assets and $assets[0];
    local $args->{sort_by} = 'entryasset_order';
    $args->{sort_order} ||= 'ascend';
    local $ctx->{__stash}{assets} = \@assets;
    local $ctx->{__stash}{tag} = 'assets';
    my $order = 1;
    foreach my $asset (@assets) {
        $asset->{entryasset_order} = $order++;
    }

    my $result = $ctx->super_handler( $args, $cond );

    foreach my $asset (@assets) {
        delete $asset->{entryasset_order};
    }

    return $ctx->error( $ctx->errstr )
        unless defined $result;
    return $result;
}

1;
