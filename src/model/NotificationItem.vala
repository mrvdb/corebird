/*  This file is part of corebird, a Gtk+ linux Twitter client.
 *  Copyright (C) 2013 Timm Bäder
 *
 *  corebird is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  corebird is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with corebird.  If not, see <http://www.gnu.org/licenses/>.
 */

public class NotificationItem : GLib.Object {
  public static int TYPE_RETWEET  = 1;
  public static int TYPE_FAVORITE = 2;
  public static int TYPE_FOLLOWED = 3;

  public signal void changed ();

  public int64 id;
  public int type = -1;
  public string heading;
  public string body;
}

public class MultipleUserNotificationItem : NotificationItem {
  public GLib.GenericArray<UserIdentity?> identities = new GLib.GenericArray<UserIdentity?> ();
  protected string[] headings = new string[4];

  public MultipleUserNotificationItem () {}


  protected string screen_name_link (int i) {
    return "<span underline='none'><a href='@%s'>@%s</a></span>"
           .printf (this.identities.get (i).id.to_string (),
                    this.identities.get (i).screen_name);
  }

  public virtual void build_text () {
    if (identities.length == 1) {
      this.heading = headings[0].printf (screen_name_link (0));
    } else if (identities.length == 2) {
      this.heading = headings[1].printf (screen_name_link (0),
                                         screen_name_link (1));
    } else if (identities.length == 3) {
      this.heading = headings[2].printf (screen_name_link (0),
                                         screen_name_link (1),
                                         screen_name_link (2));
    } else if (identities.length > 3) {
      this.heading = headings[3].printf (screen_name_link (identities.length - 1),
                                         screen_name_link (identities.length - 2),
                                         identities.length - 2);
    }

    this.changed ();
  }
}

public class RTNotificationItem : MultipleUserNotificationItem {
  public RTNotificationItem () {
    this.headings[0] = _("%s retweeted you");
    this.headings[1] = _("%s and %s retweeted you");
    this.headings[2] = _("%s, %s and %s retweeted you");
    this.headings[3] = _("%s, %s and %d others retweeted you");
  }
}

public class FavNotificationItem : MultipleUserNotificationItem {
  public FavNotificationItem () {
    this.headings[0] = _("%s favorited one of your tweets");
    this.headings[1] = _("%s and %s favorited one of your tweets");
    this.headings[2] = _("%s, %s and %s favorited one of your tweets");
    this.headings[3] = _("%s, %s and %d others favorited one of your tweets");
  }
}

public class FollowNotificationItem : MultipleUserNotificationItem {
  public override void build_text () {
    assert (this.identities.length > 0);

    this.heading = _("%s followed you").printf (screen_name_link (this.identities.length - 1));
    if (identities.length > 1) {
      var sb = new StringBuilder ();
      sb.append (_("Also: "))
        .append (screen_name_link (this.identities.length - 2));
      for (int i = identities.length - 3; i >= 0; i --) {
        sb.append (", ").append (screen_name_link (i));
      }

      this.body = sb.str;
    }

    this.changed ();
  }
}