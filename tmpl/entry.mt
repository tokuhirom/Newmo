[% INCLUDE "include/header.xt" %]

<div class="title">[% entry.title %]</div>
<div class="body">[% entry_page.body | mark_raw %]</div>
<div class="link">
    <a href="[% entry.link %]">[% $entry.link %]</a>
    <a href="http://mgw.hatena.ne.jp/?[% entry.link %]">[mgw]</a>
    modified: [% entry.modified %]
    issued: [% entry.issued %]
    [% IF (entry.hatenabookmark_users > 0) %][<a href="http://b.hatena.ne.jp/entry/[% entry.link %]" class="users">[% entry.hatenabookmark_users %]users</a>][% END %]
</div>

<hr class="hr" />

    <div class="pager">
    [% IF entry_page.page_no != 1 %]
        <a href="[% uri_for("/entry/" _ entry.entry_id _ "/" _ (entry_page.page_no-1)) %]" rel="prev" accesskey="4">&lt;前</a>
    [% ELSE %]
    &lt;前
    [% END %]
    |
    [% IF entry_page.page_no < entry_page_count %]
    <a href="[% uri_for("/entry/" _ entry.entry_id _ "/" _  (entry_page.page_no+1)) %]" rel="next" accesskey="6">次&gt;</a>
    [% ELSE %]
    次&gt;
    [% END %]
    ([% entry_page.page_no %]/[% $entry_page_count %])
    </div>

[% INCLUDE "include/footer.xt" %]
