# Project 3 - *Twitter*

**Twitter** is a basic twitter app to read and compose tweets the [Twitter API](https://apps.twitter.com/).

Time spent: **18** hours spent in total

## User Stories

The following **required** functionality is completed:

- [X] See an app icon in the home screen and a styled launch screen
- [X] Be able to log in using their Twitter account
- [X] See at latest the latest 20 tweets for a Twitter account in a Table View
- [X] Be able to refresh data by pulling down on the Table View
- [X] Be able to like and retweet from their Timeline view
- [X] Only be able to access content if logged in
- [X] Each tweet should display user profile picture, username, screen name, tweet text, timestamp, as well as buttons and labels for favorite, reply, and retweet counts.
- [X] Compose and post a tweet from a Compose Tweet view, launched from a Compose button on the Nav bar.
- [X] See Tweet details in a Details view
- [X] App should render consistently all views and subviews in recent iPhone models and all orientations

The following **optional** features are implemented:

- [x] User can view their profile in a *profile tab*
- [x] Contains the user header view: picture and tagline
- [x] Contains a section with the users basic stats: # tweets, # following, # followers
- [x] Profile view should include that user's timeline
- [x] User should be able to unretweet and unfavorite and should decrement the retweet and favorite count. Refer to [[this guide|unretweeting]] for help on implementing unretweeting.
- [x] Links in tweets are clickable.
- [x] User can tap the profile image in any tweet to see another user's profile
- [x] Contains the user header view: picture and tagline
- [x] Contains a section with the users basic stats: # tweets, # following, # followers
- [ ] User can load more tweets once they reach the bottom of the feed using infinite loading similar to the actual Twitter client.
- [x] When composing, you should have a countdown for the number of characters remaining for the tweet (out of 280) (**1 point**)
- [x] After creating a new tweet, a user should be able to view it in the timeline immediately without refetching the timeline from the network.
- [x] User can reply to any tweet, and replies should be prefixed with the username and the reply_id should be set when posting the tweet (**2 points**)
- [x] User sees embedded images in tweet if available
- [x] User can switch between timeline, mentions, or profile view through a tab bar (**3 points**)
- [ ] Profile Page: pulling down the profile page should blur and resize the header image. (**4 points**)

- [x] Be able to unlike or un-retweet by tapping a liked or retweeted Tweet button, respectively. (Doing so will decrement the count for each)
- [x] Click on links that appear in Tweets
- [x] See embedded media in Tweets that contain images or videos
- [x] Reply to any Tweet. Replies should be prefixed with the username. The reply_id should be set when posting the tweet
- [x] See a character count when composing a Tweet (as well as a warning) (280 characters)
- [ ] Load more tweets once they reach the bottom of the feed using infinite loading similar to the actual Twitter client
- [x] Click on a Profile image to reveal another user’s profile page, including: Header view: picture and tagline and Basic stats: #tweets, #following, #followers
- [x] Switch between timeline, mentions, or profile view through a tab bar
- [ ] Profile Page: pulling down the profile page should blur and resize the header image.

The following **additional** features are implemented:

- [x] Can view the replies to a tweet
- [x] Can follow and unfollow users
- [x] Custom UI
- [x] Made it unable to send tweets if over 280 characters
- [x] Can switch between the users tweets, tweets & replies, and likes timelines on a users page

Please list two areas of the assignment you'd like to **discuss further with your peers** during the next class (examples include better ways to implement something, how to extend your app in certain ways, etc):

1. How to improve the smoothness of the app (scrolling, transitions, etc.)
2. How to test the app without continously calling the API (causing lockouts)

## Video Walkthrough

Here's a walkthrough of implemented user stories:

<img src='/twitterv2.gif' title='Video Walkthrough' width='' alt='Video Walkthrough' />

On a smaller device:

<img src='/twitter2.gif' title='Video Walkthrough' width='' alt='Video Walkthrough' />

GIF created with [Kap](https://getkap.co/).

## Notes

Describe any challenges encountered while building the app.

## Credits

List an 3rd party libraries, icons, graphics, or other assets you used in your app.

- [AFNetworking](https://github.com/AFNetworking/AFNetworking) - networking task library

## License

    Copyright [2021] [Pranitha Kona]

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
