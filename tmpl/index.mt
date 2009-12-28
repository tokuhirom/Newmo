? my ($feeds, $feed2entries) = @_;
? extends('base.mt');
? block content => sub {

<div class="title"><img src="<?= uri_for('/static/logo.png') ?>" alt="newmo" /></div>

?   for my $feed (@$feeds) {
<div class="feed">
    <div class="feed_title"><?= $feed->title ?></div>
    <ul>
    <? for my $entry (@{$feed2entries->{$feed->feed_id}}) { ?>
        <li><a href="<?= uri_for("/entry/@{[ $entry->entry_id ]}/1") ?>"><?= $entry->title ?></a><?= show_hatena_users_count($entry) ?></li>
    <? } ?>
    </ul>
    <div class="more"><a href="<?= uri_for("/feed/@{[ $feed->feed_id ]}") ?>">more</a></div>
</div>
<hr size="1" />
?   }

? }
