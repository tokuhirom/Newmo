[% INCLUDE "include/header.xt" %]

<div class="title"><img src="[% uri_for('/static/logo.png') %]" alt="newmo" /></div>

[% FOREACH feed IN feeds %]
<div class="feed">
    <div class="feed_title">[% feed.title %]</div>
    <ul>
    [% FOR entry IN feed.entries %]
        <li><a href="[% uri_for("/entry/" _ entry.entry_id _ "/1") %]">[% entry.title %]</a>[% show_hatena_users_count(entry) %]</li>
    [% END %]
    </ul>
    <div class="more"><a href="[% uri_for("/feed/" _ feed.feed_id) %]">more</a></div>
</div>
<hr size="1" />
[% END %]

[% INCLUDE "include/footer.xt" %]
