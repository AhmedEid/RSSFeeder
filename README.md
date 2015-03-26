# RSSFeeder
Swift + Core Data + Multi threading app

Build a simple RSS Reader application that lets the user browse through a predetermined set of RSS Feeds. The application should show the users a list of articles and upon selection, the article should be loaded in the main view. Users should be able to browse through the downloaded article list in offline mode as well.

Requirements:

Navigation View: RSS Feeds

* Shows one section for each feed

* Navigation View can be opened by clicking on the navigation button on the top left corner of the Main View.

* Navigation View can be hidden by clicking on the X button on the top left corner or by clicking anywhere outside of the view.

Main View: Story View

* When a story is selected in Navigation View, load the details in the Main view, and hide the Navigation View

* User can navigate to previous or next story by clicking on left or right arrow button in this view.

* User can jump to previous or next section by clicking on buttons in the bottom navigation bar.

RSS Feeds must be updated

* On launch

* Upon returning to foreground

* After every 300 seconds when in foreground

* Upon manual pull to refresh in Navigation View by the user

* Never more than once a minute unless initiated by user.

Restrictions and guidelines

* You can use third party RSS/XML Feed parsers

* You may NOT use third party RSS packages to store/manage feeds.

* Use Storyboard and auto layout as much as possible.

* For any local data storage, Core Data is preferred.

Stretch Goals

* Ability to search through story titles in Navigation View.

* Stories older than 3 days should be automatically deleted.

* Mark stories as read when opened. Provide visual treatment to highlight unread stories. Provide settings to only show unread stories.

List of RSS Feeds to fetch

Please pull data from these RSS feeds:

http://feeds.feedburner.com/TechCrunch/startups

http://feeds.feedburner.com/TechCrunch/fundings-exits

http://feeds.feedburner.com/TechCrunch/social

http://feeds.feedburner.com/Mobilecrunch

http://feeds.feedburner.com/crunchgear

http://feeds.feedburner.com/TechCrunch/gaming

http://feeds.feedburner.com/Techcrunch/europe

http://feeds.feedburner.com/TechCrunchIT

http://feeds.feedburner.com/TechCrunch/greentech