[![Build Status](https://travis-ci.org/akretion/aktooor.png?branch=master)](https://travis-ci.org/akretion/aktooor)
[![Dependency Status](https://www.versioneye.com/ruby/aktooor/badge.png)](https://www.versioneye.com/ruby/aktooor)

Aktooor: OpenERP forms (via_simple_form) for your Ruby web app
--------------------------------------------------------------

Aktooor makes it straightforward to develop forms for OpenERP.
You can achieve the same kinds of forms as in OpenERP itself (same complexity) but with
more freedom as Rails allows you. And mostly these are forms that you can embed in your
Ruby web project, be it Rails or any other Rack framework (Sinatra etc..)


To do that, Aktooor extends simple_form with form builder methods that properly
introspect OpenERP meta-data (via Ooor) to make the right default decisions.

So first it's a good idea to learn [simple_form](https://github.com/plataformatec/simple_form) .
In a word, simple_form extends Rails form_for builder to support a higher level form modeling abstractions.
Also, simple_form integrates automatically with Twitter Bootstrap 3 and other CSS frameworks.

Aktooor works on Ooor objects, so you you should learn [Ooor](https://github.com/akretion/ooor) too.
Ooor objects are proxies to your OpenERP objects that use the OpenERP JSON API just like you would talk JSON with say MongoDB.
But with Ooor you also probably want to leave most of the business logic inside the OpenERP Python runtime and just call it
with the JSON API through Ooor. Eventually, you can still implement some business logic in Ruby, that allows you to leave it
unaffacted by the OpenER viral AGPL license, just like when you interract with AGPL MongoDB again.

Aktooor can work both on OpenERP mono-connection objects (like the ProductProduct constant) or multi-sessions objects that can
map OpenERP credentials to the specific web-app credentials of the user (TODO document that better). It integrates smoothly with
the [Ooorest](https://github.com/akretion/ooorest) actionpack layer to alliviate you from all this session mapping plumping.

So Aktooor extends simple_form further and provides an **ooor_form_for** helper instead.
Inside, fields that map to fields of an OpenERP Ooor::Base proxy object will need to use **ooor_input** instead of just **input**.

Aktooor also goes further by automatically generating proper dynamic association widgets using the [select2](http://ivaynberg.github.io/select2) JQuery
plugin.

Aktooor also supports nested forms (like a sale order and its order lines) using the [cocoon](https://github.com/nathanvda/cocoon) framework.


You may think that Aktooor can be made to look like the OpenERP web client. There is a wiki page talking about the similarities and differences with
the OpenERP web client https://github.com/akretion/aktooor/wiki/similarities-and-difference-between-Aktooor-and-OpenERP-web-client .


This project uses MIT-LICENSE.
