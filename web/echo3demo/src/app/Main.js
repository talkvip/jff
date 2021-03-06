MyApp = Core.extend(Echo.Application, {

    $static: {

        /**
         * Global initialization method.  Creates/starts client/application in "rootArea" element of document.
         */
        init: function() {
            Core.Web.init();
            if (Echo.DebugConsole) {
                Echo.DebugConsole.install();
            }

            var app = new MyApp();
            var client = new Echo.FreeClient(app, document.getElementById("rootArea"));

            app.setStyleSheet(MyApp.StyleSheet);
            client.addResourcePath("Echo", "lib/echo/");
            client.addResourcePath("Extras", "lib/extras/");

            client.init();

            Core.Debug.consoleWrite("MyApp is started successfully!");
        },

        /** Required JavaScript module URLs for "About" dialog. */
        MODULE_ABOUT: [
            "lib/extras/Application.TabPane.js",
            "lib/extras/Sync.TabPane.js",
            "app/About.js",
        ],

        /**
         * Set of available locale modules.
         */
        LOCALE_MODULES: {
            "zh": true,
        },
    },

    /** @see Echo.Application#init */
    init: function() {
        this._msg = this.getMessages();
        var label = new Echo.Label({
            text: this._msg["About.WindowTitle"],
        });
        this.rootComponent.add(label);
    },

    /**
     * Localized resource map.
     */
    _msg: null,

    /**
     * Retrieves resource map for current (globally configured) locale from resource bundle.
     */
    getMessages: function() {
        return MyApp.Messages.get(this.getLocale());
    },

    /**
     * User preference information.
     */
    pref: {

        /**
         * Flag indicating whether animated transition effects are enabled.
         * @type Boolean
         */
        transitionsEnabled: true,

        /**
         * Default WindowPane style name.
         * @type String
         */
        windowStyleName: "Default",
    },
});

