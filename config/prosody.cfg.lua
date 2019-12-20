-- Prosody Configuration File

admins = { "focus@auth.{{ DOMAIN }}" }
modules_enabled = {
	"roster"; -- Allow users to have a roster. Recommended ;)
	"saslauth"; -- Authentication for clients and servers. Recommended if you want to log in.
	"disco"; -- Service discovery
	"private"; -- Private XML storage (for room bookmarks, etc.)
	"vcard"; -- Allow users to set vCards
	"version"; -- Replies to server version requests
	"uptime"; -- Report how long server has been running
	"time"; -- Let others know the time here on this server
	"ping"; -- Replies to XMPP pings with pongs
	"bosh"; -- Enable BOSH clients, aka "Jabber over HTTP"
	"http_files"; -- Serve static files from a directory over HTTP
	"posix"; -- POSIX functionality, sends server to background, enables syslog, etc.
	"admin_adhoc"; -- Allows administration via an XMPP client that supports ad-hoc commands

	"lastactivity";
	"offline";
	"pubsub";
	"adhoc";
};

-- These modules are auto-loaded, but should you want
-- to disable them then uncomment them here:
modules_disabled = {
};
certificates = "certs"
plugin_paths = { "/usr/share/jitsi-meet/prosody-plugins/" }

interfaces = { "*" }
allow_registration = false;
daemonize = true;
pidfile = "/var/run/prosody/prosody.pid";
c2s_require_encryption = false
authentication = "internal_plain"

log = {
	-- Log files (change 'info' to 'debug' for debug logs):
	info = "/var/log/prosody/prosody.log";
	error = "/var/log/prosody/prosody.err";
	-- Syslog:
	{ levels = { "error" }; to = "syslog";  };
}

VirtualHost "{{ DOMAIN }}"
        -- enabled = false -- Remove this line to enable this host
        -- authentication = "anonymous" -- not work ! use "memory"
	authentication = "{{ AUTH_TYPE }}";	-- comment to disable token
        app_id = "{{ JWT_APP_ID }}";          	-- application identifier
        app_secret = "{{ JWT_APP_SECRET }}";   	-- application secret known only to your token
        allow_empty_token = false;      -- tokens are verified only if they are supplied by the client
        modules_enabled = {
            "bosh";
            "pubsub";
            "ping"; -- Enable mod_ping
        }

        c2s_require_encryption = false

Component "conference.{{ DOMAIN }}" "muc"
    storage = "memory"
    modules_enabled = { "token_verification";
			"presence_identity";
			"token_moderation"; }

Component "jitsi-videobridge.{{ DOMAIN }}"
    component_secret = "{{ JVB_SECRET }}"

VirtualHost "auth.{{ DOMAIN }}"
    authentication = "internal_plain"

Component "focus.{{ DOMAIN }}"
    component_secret = "{{ JICOFO_SECRET }}"

-- internal muc component, meant to enable pools of jibri and jigasi clients
Component "internal.auth.{{ DOMAIN }}" "muc"
    modules_enabled = {
      "ping";
    }
    storage = "null"
    muc_room_cache_size = 1000

VirtualHost "recorder.{{ DOMAIN }}"
  modules_enabled = {
    "ping";
  }
  authentication = "internal_plain"