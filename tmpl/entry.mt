? my ($entry, $entry_page, $entry_page_count) = @_;
? extends('base.mt');

? block content => sub {

<div class="title"><?= $entry->title ?></div>
<div class="body"><?= encoded_string($entry_page->body) ?></div>
<div class="link">
    <a href="<?= $entry->link ?>"><?= $entry->link ?></a>
    <a href="http://mgw.hatena.ne.jp/?<?= $entry->link ?>">[mgw]</a>
    <? if ($entry->hatenabookmark_users) { ?>[<a href="http://b.hatena.ne.jp/entry/<?= $entry->link ?>" class="users"><?= $entry->hatenabookmark_users ?>users</a>]<? } ?>
</div>

<hr class="hr" />

    <div class="pager">
    <? if ($entry_page->page_no != 1) { ?>
        <a href="<?= uri_for("/entry/@{[ $entry->entry_id ]}/@{[ $entry_page->page_no-1 ]}") ?>" rel="prev" accesskey="4">&lt;前</a>
    <? } else { ?>
    &lt;前
    <? } ?>
    |
    <? if ($entry_page->page_no < $entry_page_count) { ?>
    <a href="<?= uri_for("/entry/@{[ $entry->entry_id ]}/@{[ $entry_page->page_no+1 ]}") ?>" rel="next" accesskey="6">次&gt;</a>
    <? } else { ?>
    次&gt;
    <? } ?>
    (<?= $entry_page->page_no ?>/<?= $entry_page_count ?>)
    </div>

    <hr class="hr" />

? };
