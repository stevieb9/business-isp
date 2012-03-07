Clients sent Notices:

[% FOREACH item IN notices %]
[%item.username%]: [%item.hours%]
[% END %]

Clients sent Renewals:

[% FOREACH item IN renewals %]
[%item.username%]: [%item.hours%]
[% END %]
