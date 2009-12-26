? my ($feed, $entries, $page, $has_next) = @_;
? extends('base.mt');

? block content => sub {


<div class="title"><?= $feed->title ?></div>

<ul>
<? for my $entry (@{$entries}) { ?>
    <li><?= $entry->content =~ /<html/ ? '*' : '' ?><a href="<?= uri_for("/entry/@{[ $entry->entry_id ]}/1") ?>"><?= $entry->title ?></a><? if ($entry->{hatena_bookmark_count}) { ?>[<?= $entry->{hatena_bookmark_count} ?>users]<? } ?></li>
<? } ?>
</ul>

<hr class="hr" />

<div class="pager">
? if ($page == 1) {
    前
? } else {
    <a href="<?= uri_for("/feed/@{[ $feed->feed_id ]}", { page => $page - 1 }) ?>" rel="prev" accesskey="4">前</a>
? }
|
? if ($has_next) {
    <a href="<?= uri_for("/feed/@{[ $feed->feed_id ]}", { page => $page + 1 }) ?>" rel="next" accesskey="6">次</a>
? } else {
    次
? }
</div>

? };
