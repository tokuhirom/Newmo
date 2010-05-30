[% INCLUDE "include/header.xt" %]

<div class="title">[% feed.title %]</div>

<div class="feed">
<ul>
[% FOR entry IN entries %]
    <li><a href="[% uri_for("/entry/" _ entry.entry_id _ "/1") %]">[% entry.title %]</a>[% show_hatena_users_count(entry) %]</li>
[% END %]
</ul>
</div>

<hr class="hr" />

<div class="pager">
[% IF page == 1 %]
    前
[% ELSE %]
    <a href="[% uri_for("/feed/" _ feed.feed_id, { page => $page - 1 }) %]" rel="prev" accesskey="4">前</a>
[% END %]
|
[% IF has_next %]
    <a href="[% uri_for("/feed/" _ feed.feed_id, { page => page + 1 }) %]" rel="next" accesskey="6">次</a>
[% ELSE %]
    次
[% END %]
</div>

[% INCLUDE "include/footer.xt" %]
