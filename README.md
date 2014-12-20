# Dione #

This is a proof-of-concept CMS based on Rack and CouchDB, with the goal of being less annoying to use than most other CMS and blog systems for both programmers, designers, and users.

## How do I get started ##

 1. Install CouchDB 1.6.1 (or any other version probably)
 2. Install Ruby 2.1.5 (or any other modern version)
 3. Install Bundler 1.7.9 (or any version compatible with your Ruby).
 4. Download or check out Dione from here (https://github.com/jensnockert/dione)
 5. Run `bundle install` in the Dione directory
 6. `DIONE_DATABASE=http://localhost:5984/dione ./generate fixtures/test-blog` to fill the database with test data
 7. `DIONE_DATABASE=http://localhost:5984/dione DIONE_ENVIRONMENT=development shotgun dione.ru` to start a development server

Then you can play around with your new blog, well, my blog… but replace the style and content with something cool and you'll have your own blog. Then you can deploy it just like any other Rack app on… I don't know, Heroku or something.

## Do I need to modify the Couch database manually ##

Right now there's no admin interface, because Dione was written in a few hours on a monday morning. If there's a monday morning some other week, I might hack something up, or I might not. Until then, you'll probably need to modify the database yourself, or use something like the generate script.

## Can I use one server for testing and one for production ##

Glad you asked, set up two Dione instances, and when you're happy with your new content and layout then just use Couch replication to deploy from the testing to production.

## License ##

This is available under the EUPL, it's not that weird, OSI approved, created on the initiative of the European Commission, is copyleft, and you can read all about it here https://joinup.ec.europa.eu/software/page/eupl.

If you distribute plugins for Dione to people, they have the right to use them under the EUPL.